////////////////////////////////////////////////////////////////////////////////
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
// 
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugin.templating
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import mx.resources.ResourceManager;
	import mx.utils.StringUtil;
	
	import __AS3__.vec.Vector;
	
	import actionScripts.events.AddTabEvent;
	import actionScripts.events.EditorPluginEvent;
	import actionScripts.events.ExportVisualEditorProjectEvent;
	import actionScripts.events.GeneralEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.NewFileEvent;
	import actionScripts.events.NewProjectEvent;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.RenameApplicationEvent;
	import actionScripts.events.TemplatingEvent;
	import actionScripts.events.TreeMenuItemEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.IMenuPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.StaticLabelSetting;
	import actionScripts.plugin.templating.event.TemplateEvent;
	import actionScripts.plugin.templating.settings.NewTemplateSetting;
	import actionScripts.plugin.templating.settings.TemplateSetting;
	import actionScripts.plugin.templating.settings.renderer.NewTemplateRenderer;
	import actionScripts.plugin.templating.settings.renderer.TemplateRenderer;
	import actionScripts.ui.IContentWindow;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.menu.vo.MenuItem;
	import actionScripts.ui.menu.vo.ProjectMenuTypes;
	import actionScripts.ui.renderers.FTETreeItemRenderer;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.utils.SerializeUtil;
	import actionScripts.utils.TextUtil;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.AS3ClassAttributes;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.FileWrapper;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.TemplateVO;
	
	import components.popup.newFile.NewASFilePopup;
	import components.popup.newFile.NewCSSFilePopup;
	import components.popup.newFile.NewFilePopup;
	import components.popup.newFile.NewGroovyFilePopup;
	import components.popup.newFile.NewJavaFilePopup;
	import components.popup.newFile.NewMXMLFilePopup;
	import components.popup.newFile.NewVisualEditorFilePopup;
	import components.popup.newFile.NewHaxeFilePopup;

    /*
    Templating plugin

    Provides templates & possibility to customize them

    Standard templates ship in the app-dir, but since we can't change those files once installed
    we override them by copying them to app-storage-dir & let the user modify them there.
    */
	
	public class TemplatingPlugin extends PluginBase implements ISettingsProvider,IMenuPlugin
	{
		override public function get name():String 			{return "Templating";}
		override public function get author():String 		{return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team";}
		override public function get description():String 	{return ResourceManager.getInstance().getString('resources','plugin.desc.templating');}
		
		public static var fileTemplates:Array = [];
		public static var projectTemplates:Array = [];
		
		protected var templatesDir:FileLocation;
		protected var customTemplatesDir:FileLocation;
		
		protected var settingsList:Vector.<ISetting>;
		protected var newFileTemplateSetting:NewTemplateSetting;
		protected var newProjectTemplateSetting:NewTemplateSetting;
		protected var newMXMLComponentPopup:NewMXMLFilePopup;
		protected var newAS3ComponentPopup:NewASFilePopup;
		protected var newJavaComponentPopup:NewJavaFilePopup;
		protected var newGroovyComponentPopup:NewGroovyFilePopup;
		protected var newHaxeComponentPopup:NewHaxeFilePopup;
		protected var newCSSComponentPopup:NewCSSFilePopup;
		protected var newVisualEditorFilePopup:NewVisualEditorFilePopup;
		protected var newFilePopup:NewFilePopup;
		
		private var resetIndex:int = -1;

		private var templateConfigs:Array;
		private var allLoadedTemplates:Array;

		public function TemplatingPlugin()
		{
			super();
			
			if (ConstantsCoreVO.IS_AIR)
			{
				templatesDir = model.fileCore.resolveApplicationDirectoryPath("elements".concat(model.fileCore.separator, "templates"));
				customTemplatesDir = model.fileCore.resolveApplicationStorageDirectoryPath("templates");
				readTemplates();
			}
		}
		
		override public function activate():void
		{
			super.activate();

			dispatcher.addEventListener(TemplateEvent.CREATE_NEW_FILE, handleCreateFileTemplate);
			
			// For web Moonshine, we won't depend on getMenu()
			// getMenu() exclusively calls for desktop Moonshine
			if (!ConstantsCoreVO.IS_AIR)
			{
				for each (var m:FileLocation in ConstantsCoreVO.TEMPLATES_FILES)
				{
					var fileName:String = m.fileBridge.name.substring(0,m.fileBridge.name.lastIndexOf("."));
					dispatcher.addEventListener(fileName, handleNewTemplateFile);
				}
				
				for each (var project:FileLocation in ConstantsCoreVO.TEMPLATES_PROJECTS)
				{
					dispatcher.addEventListener(project.fileBridge.name, handleNewProjectFile);
				}
			}
			else
			{
	            dispatcher.addEventListener(ExportVisualEditorProjectEvent.EVENT_EXPORT_VISUALEDITOR_PROJECT_TO_FLEX, handleExportNewProjectFromTemplate);
				dispatcher.addEventListener(NewFileEvent.EVENT_NEW_VISUAL_EDITOR_FILE, onVisualEditorFileCreateRequest, false, 0, true);
			}
		}
		
		override public function resetSettings():void
		{
			resetIndex = 0;
			for (resetIndex; resetIndex < settingsList.length; resetIndex++)
			{
				if (settingsList[resetIndex] is TemplateSetting) 
				{
					TemplateSetting(settingsList[resetIndex]).resetTemplate();
				}
			}
			
			readTemplates();
		}
		
		protected function readTemplates():void
		{
			fileTemplates = [];
			projectTemplates = [];
			
			// Find default templates
			var files:FileLocation = templatesDir.resolvePath("files");
			var list:Array = files.fileBridge.getDirectoryListing();
			for each (var file:Object in list)
			{
				if (!file.isHidden && !file.isDirectory)
					fileTemplates.push(new FileLocation(file.nativePath));
			}
			
			files = templatesDir.resolvePath("files/mxml/flex");
			list = files.fileBridge.getDirectoryListing();
			for each (file in list)
			{
				if (!file.isHidden && !file.isDirectory)
					ConstantsCoreVO.TEMPLATES_MXML_COMPONENTS.addItem(file);
			}

            files = templatesDir.resolvePath("files/visualeditor/flex");
            list = files.fileBridge.getDirectoryListing();
            for each (file in list)
            {
                if (!file.isHidden && !file.isDirectory)
                    ConstantsCoreVO.TEMPLATES_VISUALEDITOR_FILES_FLEX.addItem(file);
            }

            files = templatesDir.resolvePath("files/visualeditor/primeFaces");
            list = files.fileBridge.getDirectoryListing();
            for each (file in list)
            {
                if (!file.isHidden && !file.isDirectory)
                    ConstantsCoreVO.TEMPLATES_VISUALEDITOR_FILES_PRIMEFACES.addItem(file);
            }

			files = templatesDir.resolvePath("files/AS3 Class.as.template");
			if (!files.fileBridge.isHidden && !files.fileBridge.isDirectory)
				ConstantsCoreVO.TEMPLATE_AS3CLASS = files;
			
			files = templatesDir.resolvePath("files/AS3 Interface.as.template");
			if (!files.fileBridge.isHidden && !files.fileBridge.isDirectory)
				ConstantsCoreVO.TEMPLATE_AS3INTERFACE = files;
			
			files = templatesDir.resolvePath("files/CSS File.css.template");
			if (!files.fileBridge.isHidden && !files.fileBridge.isDirectory)
				ConstantsCoreVO.TEMPLATE_CSS = files;
			
			files = templatesDir.resolvePath("files/XML File.xml.template");
			if (!files.fileBridge.isHidden && !files.fileBridge.isDirectory)
				ConstantsCoreVO.TEMPLATE_XML = files;
			
			files = templatesDir.resolvePath("files/File.txt.template");
			if (!files.fileBridge.isHidden && !files.fileBridge.isDirectory)
				ConstantsCoreVO.TEMPLATE_TEXT = files;
			
			files = templatesDir.resolvePath("files/Java Class.java.template");
			if (!files.fileBridge.isHidden && !files.fileBridge.isDirectory)
				ConstantsCoreVO.TEMPLATE_JAVACLASS = files;
			
			files = templatesDir.resolvePath("files/Groovy Class.groovy.template");
			if (!files.fileBridge.isHidden && !files.fileBridge.isDirectory)
				ConstantsCoreVO.TEMPLATE_GROOVYCLASS = files;
			
			files = templatesDir.resolvePath("files/Haxe Class.hx.template");
			if (!files.fileBridge.isHidden && !files.fileBridge.isDirectory)
				ConstantsCoreVO.TEMPLATE_HAXECLASS = files;
			
			files = templatesDir.resolvePath("files/Haxe Interface.hx.template");
			if (!files.fileBridge.isHidden && !files.fileBridge.isDirectory)
				ConstantsCoreVO.TEMPLATE_HAXEINTERFACE = files;
			
			// Just to generate a divider in relevant UI
			//ConstantsCoreVO.TEMPLATES_MXML_COMPONENTS.addItem("NOTHING");
			
			files = templatesDir.resolvePath("files/mxml/flexjs");
			list = files.fileBridge.getDirectoryListing();
			for each (file in list)
			{
				if (!file.isHidden && !file.isDirectory)
					ConstantsCoreVO.TEMPLATES_MXML_FLEXJS_COMPONENTS.addItem(file);
			}

            files = templatesDir.resolvePath("files/mxml/royale");
            list = files.fileBridge.getDirectoryListing();
            for each (file in list)
            {
                if (!file.isHidden && !file.isDirectory)
                    ConstantsCoreVO.TEMPLATES_MXML_ROYALE_COMPONENTS.addItem(file);
            }

			var projects:FileLocation = templatesDir.resolvePath("projects");
			list = projects.fileBridge.getDirectoryListing();
			list = list.filter(function(item:Object, index:int, arr:Array):Boolean {
				return item.extension == "xml";
			});

			templateConfigs = [];

			for each (file in list)
			{
				if (!file.isHidden)
				{
					var projectTemplateConfigLocation:FileLocation = new FileLocation(file.nativePath);
					var projectTemplateConfig:XML = new XML(projectTemplateConfigLocation.fileBridge.read());
					var projectTemplateConfigs:XMLList = projectTemplateConfig.template;

					for each (var template:XML in projectTemplateConfigs)
					{
						var templateName:String = String(template.name);
						projectTemplates.push(projects.resolvePath(templateName));
						templateConfigs.push(template);
					}
				}
			}
			
			// Find user-added custom templates
			if (!customTemplatesDir.fileBridge.exists) customTemplatesDir.fileBridge.createDirectory();
			
			files = customTemplatesDir.resolvePath("files");
			if (!files.fileBridge.exists) files.fileBridge.createDirectory();
			var fileList:Array = files.fileBridge.getDirectoryListing();
			
			for each (file in fileList)
			{
				if (TemplatingHelper.getOriginalFileForCustom(new FileLocation(file.nativePath)).fileBridge.exists == false
					&& !file.isHidden)
				{
					fileTemplates.push(new FileLocation(file.nativePath));
				}
			}
			
			projects = customTemplatesDir.resolvePath("projects");
			if (!projects.fileBridge.exists) projects.fileBridge.createDirectory();
			var projectList:Array = projects.fileBridge.getDirectoryListing();
			
			for each (file in projectList)
			{
				if (TemplatingHelper.getOriginalFileForCustom(new FileLocation(file.nativePath)).fileBridge.exists == false
					&& !file.isHidden && file.isDirectory)
				{
					projectTemplates.push(new FileLocation(file.nativePath));
				}
			}

			generateTemplateProjects();
		}

        private function generateTemplateProjects():void
        {
            var projectTemplateCollection:ArrayCollection = new ArrayCollection();
            var feathersProjectTemplates:ArrayCollection = new ArrayCollection();
			var royaleProjectTemplates:ArrayCollection = new ArrayCollection();
			var javaProjectTemplates:ArrayCollection = new ArrayCollection();
			var grailsProjectTemplates:ArrayCollection = new ArrayCollection();
			var haxeProjectTemplates:ArrayCollection = new ArrayCollection();

			allLoadedTemplates = [];
            for each (var templateConfig:XML in templateConfigs)
            {
				var templateName:String = SerializeUtil.deserializeString(templateConfig.name);

				var projectsLocation:FileLocation = templatesDir.resolvePath("projects" + templatesDir.fileBridge.separator + templateName);
                if (projectsLocation.fileBridge.exists)
                {
                    var template:TemplateVO = new TemplateVO();
                    template.title = SerializeUtil.deserializeString(templateConfig.title);
					template.homeTitle = SerializeUtil.deserializeString(templateConfig.homeTitle);
					template.displayHome = SerializeUtil.deserializeBoolean(templateConfig.@displayHome);
                    template.file = projectsLocation;
                    template.description = String(templateConfig.description);

					var iconsLocation:FileLocation = projectsLocation.fileBridge.parent.resolvePath("icons");
					var iconFile:Object = iconsLocation.fileBridge.getFile.resolvePath(String(templateConfig.icon));
                    if (iconFile.exists)
					{
						template.logoImagePath = iconFile.url;
                    }

                    if (templateName.indexOf("Feathers") != -1 || templateName.indexOf("Away3D") != -1)
					{
						feathersProjectTemplates.addItem(template);
                    }
                    else
					{
						projectTemplateCollection.addItem(template);
                    }

					if (templateName.indexOf("Royale") != -1 && templateName.indexOf("FlexJS") == -1)
					{
                        royaleProjectTemplates.addItem(template);
					}

					if (templateName.indexOf("Java") != -1)
					{
                        javaProjectTemplates.addItem(template);
					}

					if (template.title.indexOf("Grails") != -1)
					{
                        grailsProjectTemplates.addItem(template);
					}

					if (template.title.indexOf("Haxe") != -1)
					{
                        haxeProjectTemplates.addItem(template);
					}

					allLoadedTemplates.push(template);
                }
            }

            ConstantsCoreVO.TEMPLATES_PROJECTS = projectTemplateCollection;
            ConstantsCoreVO.TEMPLATES_PROJECTS_SPECIALS = feathersProjectTemplates;
			royaleProjectTemplates.source = royaleProjectTemplates.source.reverse();
			ConstantsCoreVO.TEMPLATES_PROJECTS_ROYALE = royaleProjectTemplates;
			ConstantsCoreVO.TEMPLATES_PROJECTS_JAVA = javaProjectTemplates;
			ConstantsCoreVO.TEMPLATES_PROJECTS_GRAILS = grailsProjectTemplates;
			ConstantsCoreVO.TEMPLATES_PROJECTS_HAXE = haxeProjectTemplates;
        }
		
		public function getSettingsList():Vector.<ISetting>	
		{	
			// Build settings on each template (just a File object pointing to a directory)
			//  requires good names for the directories, but shouldn't be a problem
			var settings:Vector.<ISetting> = new Vector.<ISetting>();
			
			var fileLabel:StaticLabelSetting = new StaticLabelSetting("Files", 14);
			settings.push(fileLabel);
			
			var setting:TemplateSetting;
			for each (var t:FileLocation in fileTemplates)
			{
				if (t.fileBridge.isHidden) continue;
				setting = getTemplateSetting(t);
				settings.push(setting);
			}
			
			newFileTemplateSetting = new NewTemplateSetting("Add file template");
			newFileTemplateSetting.renderer.addEventListener('create', handleFileTemplateCreate, false, 0, true);
			
			settings.push(newFileTemplateSetting);
			
			var projectLabel:StaticLabelSetting = new StaticLabelSetting("Projects", 14);
			settings.push(projectLabel);
			
			for each (var p:FileLocation in projectTemplates)
			{
				if (p.fileBridge.isHidden) continue;
				setting = getTemplateSetting(p);				
				settings.push(setting);
			}
			
			newProjectTemplateSetting = new NewTemplateSetting("Add project template");
			newProjectTemplateSetting.renderer.addEventListener('create', handleProjectTemplateCreate, false, 0, true);
			
			settings.push(newProjectTemplateSetting);
			
			settingsList = settings;
			return settings;
		}
		
		public function getMenu():MenuItem
		{	
			var newFileMenu:MenuItem = new MenuItem('New');
			var enableTypes:Array;
			newFileMenu.parents = ["File", "New"];
			newFileMenu.items = new Vector.<MenuItem>();

			for each (var fileTemplate:FileLocation in fileTemplates)
			{
				if (fileTemplate.fileBridge.isHidden) continue;
				var lbl:String = TemplatingHelper.getTemplateLabel(fileTemplate);
				
				// TODO: Do MenuEvent and have data:* for this kind of thing
				var eventType:String = "eventNewFileFromTemplate"+lbl;
				
				dispatcher.addEventListener(eventType, handleNewTemplateFile);
				
				enableTypes = TemplatingHelper.getTemplateMenuType(lbl);
				
				var menuItem:MenuItem = new MenuItem(lbl, null, enableTypes, eventType);
				menuItem.data = fileTemplate; 
				
				newFileMenu.items.push(menuItem);
			}
			
			var separator:MenuItem = new MenuItem(null);
			newFileMenu.items.push(separator);

			var filteredProjectTemplatesToMenu:Array = allLoadedTemplates.filter(filterProjectsTemplates);

			for each (var projectTemplate:TemplateVO in filteredProjectTemplatesToMenu)
			{
				if (projectTemplate.file.fileBridge.isHidden)
				{
					continue;
				}

				eventType = "eventNewProjectFromTemplate" + TemplatingHelper.getTemplateLabel(projectTemplate.file);
				
				dispatcher.addEventListener(eventType, handleNewProjectFile);
				
				menuItem = new MenuItem(projectTemplate.homeTitle, null, null, eventType);
				menuItem.data = projectTemplate;
				
				newFileMenu.items.push(menuItem);	
			}
			
			return newFileMenu;
		}
		
		protected function getTemplateSetting(template:FileLocation):TemplateSetting
		{
			var originalTemplate:FileLocation;
			var customTemplate:FileLocation;
			
			if (isCustom(template))
			{
				originalTemplate = null;
				customTemplate = template;
			}
			else
			{
				originalTemplate = template;
				customTemplate = TemplatingHelper.getCustomFileFor(template);
			}
			
			var setting:TemplateSetting = new TemplateSetting(originalTemplate, customTemplate, template.fileBridge.name);
			setting.renderer.addEventListener(TemplateRenderer.EVENT_MODIFY, handleTemplateModify, false, 0, true);
			setting.renderer.addEventListener(TemplateRenderer.EVENT_RESET, handleTemplateReset, false, 0, true);
			setting.renderer.addEventListener(TemplateRenderer.EVENT_REMOVE, handleTemplateReset, false, 0, true);
			setting.renderer.addEventListener(GeneralEvent.DONE, onRenameDone, false, 0, true);
			
			return setting;
		}
		
		
		protected function handleFileTemplateCreate(event:Event):void
		{
			// Create new file
			var increamentalNumber:int = 1;
			var newTemplate:FileLocation = this.customTemplatesDir.resolvePath("files/New file template.txt.template");
			while (newTemplate.fileBridge.exists)
			{
				newTemplate = this.customTemplatesDir.resolvePath("files/New file template("+ increamentalNumber +").txt.template");
				increamentalNumber++;
			}
			
			newTemplate.fileBridge.save("");
			
			// Add setting for it so we can remove it
			var t:TemplateSetting = new TemplateSetting(null, newTemplate, newTemplate.fileBridge.name);
			t.renderer.addEventListener(TemplateRenderer.EVENT_MODIFY, handleTemplateModify, false, 0, true);
			t.renderer.addEventListener(TemplateRenderer.EVENT_REMOVE, handleTemplateReset, false, 0, true);
			t.renderer.addEventListener(TemplateRenderer.EVENT_RESET, handleTemplateReset, false, 0, true);
			t.renderer.addEventListener(GeneralEvent.DONE, onRenameDone, false, 0, true);
			var newPos:int = this.settingsList.indexOf(newFileTemplateSetting);
			settingsList.splice(newPos, 0, t);
			
			// Force settings view to redraw
			NewTemplateRenderer(event.target).dispatchEvent(new Event('refresh'));
			
			// Add to project view so user can rename it
			GlobalEventDispatcher.getInstance().dispatchEvent(
				new OpenFileEvent(OpenFileEvent.OPEN_FILE, [newTemplate])
			);
			
			// Update internal template list
			fileTemplates.push(newTemplate);
			
			// send event to get the new item added immediately to File/New menu
			var lbl:String = TemplatingHelper.getTemplateLabel(newTemplate);
			var eventType:String = "eventNewFileFromTemplate"+lbl;
			dispatcher.addEventListener(eventType, handleNewTemplateFile, false, 0, true);
			dispatcher.dispatchEvent(new TemplatingEvent(TemplatingEvent.ADDED_NEW_TEMPLATE, false, lbl, eventType));
		}
		
		protected function handleProjectTemplateCreate(event:Event):void
		{
			var increamentalNumber:int = 1;
			var newTemplate:FileLocation = this.customTemplatesDir.resolvePath("projects/New Project Template/");
			while (newTemplate.fileBridge.exists)
			{
				newTemplate = this.customTemplatesDir.resolvePath("projects/New Project Template("+ increamentalNumber +")/");
				increamentalNumber++;
			}
			
			newTemplate.fileBridge.createDirectory();
			
			var t:TemplateSetting = new TemplateSetting(null, newTemplate, newTemplate.fileBridge.name);
			t.renderer.addEventListener(TemplateRenderer.EVENT_MODIFY, handleTemplateModify, false, 0, true);
			t.renderer.addEventListener(TemplateRenderer.EVENT_REMOVE, handleTemplateReset, false, 0, true);
			t.renderer.addEventListener(GeneralEvent.DONE, onRenameDone, false, 0, true);
			var newPos:int = this.settingsList.indexOf(newProjectTemplateSetting);
			settingsList.splice(newPos, 0, t);
			
			var newProject:AS3ProjectVO = new AS3ProjectVO(newTemplate, newTemplate.fileBridge.name);
			newProject.classpaths[0] = newTemplate;
			newProject.projectFolder.projectReference.isTemplate = true;
			
			dispatcher.dispatchEvent(
				new ProjectEvent(ProjectEvent.ADD_PROJECT, newProject)
			);
			
			NewTemplateRenderer(event.target).dispatchEvent(new Event('refresh'));
			
			projectTemplates.push(newTemplate);
			
			// send event to get the new item added immediately to File/New menu
			// send event to get the new item added immediately to File/New menu
			var lbl:String = TemplatingHelper.getTemplateLabel(newTemplate);
			var eventType:String = "eventNewProjectFromTemplate"+lbl;
			dispatcher.addEventListener(eventType, handleNewProjectFile, false, 0, true);
			dispatcher.dispatchEvent(new TemplatingEvent(TemplatingEvent.ADDED_NEW_TEMPLATE, true, lbl, eventType));
		}
		
		protected function handleTemplateModify(event:Event):void
		{
			var rdr:TemplateRenderer = TemplateRenderer(event.target);
			var original:FileLocation = rdr.setting.originalTemplate;
			var custom:FileLocation = rdr.setting.customTemplate;
			
			var p:AS3ProjectVO;
			
			if ((!original || !original.fileBridge.exists) && custom.fileBridge.isDirectory)
			{
				p = new AS3ProjectVO(custom, custom.fileBridge.name)
			}
			else if (!custom.fileBridge.exists && (original && original.fileBridge.exists && original.fileBridge.isDirectory))
			{
				// Copy to app-storage so we can edit
				original.fileBridge.copyTo(custom);
				p = new AS3ProjectVO(custom, custom.fileBridge.name);
			}
			else if (!custom.fileBridge.exists && original && original.fileBridge.exists && !original.fileBridge.isDirectory)
			{
				original.fileBridge.copyTo(custom);
			}
			else if (custom && custom.fileBridge.exists && custom.fileBridge.isDirectory)
			{
				p = new AS3ProjectVO(custom, custom.fileBridge.name);
			}
			
			// If project or custom, show in Project View so user can rename it
			if (p)
			{
				p.classpaths[0] = p.folderLocation;
				p.projectFolder.projectReference.isTemplate = true;
				p.menuType = ProjectMenuTypes.TEMPLATE;
				dispatcher.dispatchEvent(
					new ProjectEvent(ProjectEvent.ADD_PROJECT, p)
				);
			}
				
				// If not a project, open the template for editing
			else if (!custom.fileBridge.isDirectory)
			{
				dispatcher.dispatchEvent(
					new OpenFileEvent(OpenFileEvent.OPEN_FILE, [custom])
				);
			}
		}
		
		protected function handleTemplateReset(event:Event):void
		{
			// Resetting a template just removes it from app-storage
			var rdr:TemplateRenderer = TemplateRenderer(event.target);
			var original:FileLocation = rdr.setting.originalTemplate;
			var custom:FileLocation = rdr.setting.customTemplate;
			var lbl:String = TemplatingHelper.getTemplateLabel(custom);
			
			if (custom.fileBridge.exists)
			{
				if (custom.fileBridge.isDirectory) 
				{
					var isProjectOpen:Boolean = false;
					for each (var i:ProjectVO in model.projects)
					{
						if (i.folderLocation.fileBridge.nativePath == custom.fileBridge.nativePath)
						{
							isProjectOpen = true;
							i.projectFolder.isRoot = true;
							model.mainView.getTreeViewPanel().tree.dispatchEvent(new TreeMenuItemEvent(TreeMenuItemEvent.RIGHT_CLICK_ITEM_SELECTED, FTETreeItemRenderer.DELETE_PROJECT, i.projectFolder, false));
							break;
						}
					}
					
					if (!isProjectOpen) 
					{
						custom.fileBridge.deleteDirectory(true);
					}
				}
				else 
				{
					// if the template file is already opened to an editor
					for each (var tab:IContentWindow in model.editors)
					{
						var ed:BasicTextEditor = tab as BasicTextEditor;
						if (ed 
							&& ed.currentFile
							&& ed.currentFile.fileBridge.nativePath == custom.fileBridge.nativePath)
						{
							// close the tab
							GlobalEventDispatcher.getInstance().dispatchEvent(
								new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, ed, true)
							);
						}
					}
					
					// deletes the file
					custom.fileBridge.deleteFile();
				}
				
				resetIndex --;
			}
			
			if (!original)
			{
				var idx:int = settingsList.indexOf(rdr.setting);
				settingsList.splice(idx, 1);
				rdr.dispatchEvent(new Event('refresh'));
				
				//readTemplates();
				if (custom.fileBridge.isDirectory) 
				{
					// remove the item from New/File menu
					dispatcher.dispatchEvent(new TemplatingEvent(TemplatingEvent.REMOVE_TEMPLATE, true, lbl));
					
					projectTemplates.splice(projectTemplates.indexOf(custom), 1);
				}
				else 
				{
					// remove the item from New/File menu
					dispatcher.dispatchEvent(new TemplatingEvent(TemplatingEvent.REMOVE_TEMPLATE, false, lbl));
					
					fileTemplates.splice(fileTemplates.indexOf(custom), 1);
				}
			}
		}
		
		protected function onRenameDone(event:GeneralEvent):void
		{
			// Resetting a template just removes it from app-storage
			var rdr:TemplateRenderer = TemplateRenderer(event.target);
			var custom:FileLocation = rdr.setting.customTemplate;
			var tmpOldIndex:int;
			var oldFileName:String = TemplatingHelper.getTemplateLabel(custom);
			var newFileNameWithExtension:String = event.value as String;
			var newFileName:String = newFileNameWithExtension.split(".")[0];
			
			if (custom.fileBridge.exists)
			{
				var customNewLocation:FileLocation = custom.fileBridge.parent.resolvePath(newFileNameWithExtension +(!custom.fileBridge.isDirectory ? ".template" : ""));
				// check if no duplicate naming happens
				if (customNewLocation.fileBridge.exists)
				{
					Alert.show(newFileNameWithExtension +" is already available.", "!Error");
					return;
				}
				
				var isDirectory:Boolean = custom.fileBridge.isDirectory; // detect this before moveTo else it'll always return false to older file instance
				custom.fileBridge.moveTo(customNewLocation, true);
				
				if (!isDirectory)
				{
					// we need to update file location of the (if any) opened instance 
					// of the file template
					for each (var tab:IContentWindow in model.editors)
					{
						var ed:BasicTextEditor = tab as BasicTextEditor;
						if (ed 
							&& ed.currentFile
							&& ed.currentFile.fileBridge.nativePath == custom.fileBridge.nativePath)
						{
							ed.currentFile = customNewLocation;
						}
					}
					
					// remove the existing File/New listener
					dispatcher.removeEventListener("eventNewFileFromTemplate"+ oldFileName, handleNewTemplateFile);
					dispatcher.addEventListener("eventNewFileFromTemplate"+ newFileName, handleNewTemplateFile);
					
					// update file list
					tmpOldIndex = fileTemplates.indexOf(custom);
					if (tmpOldIndex != -1) fileTemplates[tmpOldIndex] = customNewLocation;
					
					// updating file/new menu
					dispatcher.dispatchEvent(new TemplatingEvent(TemplatingEvent.RENAME_TEMPLATE, false, oldFileName, null, newFileName, customNewLocation));
				}
				else 
				{
					dispatcher.dispatchEvent(new RenameApplicationEvent(RenameApplicationEvent.RENAME_APPLICATION_FOLDER, custom, customNewLocation));
					
					// remove the existing File/New listener
					dispatcher.removeEventListener("eventNewProjectFromTemplate"+ oldFileName, handleNewProjectFile);
					dispatcher.addEventListener("eventNewProjectFromTemplate"+ newFileName, handleNewProjectFile);
					
					// update file list
					tmpOldIndex = projectTemplates.indexOf(custom);
					if (tmpOldIndex != -1) projectTemplates[tmpOldIndex] = customNewLocation;
					
					// updating file/new menu
					dispatcher.dispatchEvent(new TemplatingEvent(TemplatingEvent.RENAME_TEMPLATE, true, oldFileName, null, newFileName, customNewLocation));
				}
				
				rdr.setting.customTemplate = customNewLocation;
				rdr.setting.label = rdr.setting.customTemplate.fileBridge.name;
				rdr.dispatchEvent(new Event('refresh'));
			}
		}
		
		protected function handleCreateFileTemplate(event:TemplateEvent):void
		{
			// If we know where to place it we replace strings inside it
			if (event.location)
			{
				// Request additional data for templating
				var event:TemplateEvent = new TemplateEvent(TemplateEvent.REQUEST_ADDITIONAL_DATA, event.template, event.location);
				dispatcher.dispatchEvent(event);
				
				var helper:TemplatingHelper = new TemplatingHelper();
				helper.templatingData = event.templatingData;
				helper.fileTemplate(event.template, event.location);
				
				dispatcher.dispatchEvent(
					new OpenFileEvent(OpenFileEvent.OPEN_FILE, [event.location])
				);
			}
			else
			{
				// Otherwise we just create the file
				createFile(event.template);
			}
		}
		
		protected function handleNewTemplateFile(event:Event):void
		{
			var eventName:String;
			var i:int;
			var fileTemplate:FileLocation;
			if (ConstantsCoreVO.IS_AIR)
			{
				eventName = event.type.substr(24);
				
				// MXML type choose
				switch (eventName)
				{
					case "MXML File":
						openMXMLComponentTypeChoose(event);
                        break;
					case "AS3 Class":
						openAS3ComponentTypeChoose(event, false);
                        break;
					case "AS3 Interface":
						openAS3ComponentTypeChoose(event, true);
                        break;
					case "CSS File":
						openCSSComponentTypeChoose(event);
                        break;
					case "XML File":
						openNewComponentTypeChoose(event, NewFilePopup.AS_XML);
                        break;
					case "File":
						openNewComponentTypeChoose(event, NewFilePopup.AS_PLAIN_TEXT);
                        break;
					case "Visual Editor Flex File":
					case "Visual Editor PrimeFaces File":
						openVisualEditorComponentTypeChoose(event);
						break;
					case "Java Class":
						openJavaTypeChoose(event, false);
						break;
					case "Groovy Class":
						openGroovyTypeChoose(event, false);
						break;
					case "Haxe Class":
						openHaxeTypeChoose(event, false);
						break;
					case "Haxe Interface":
						openHaxeTypeChoose(event, true);
						break;
					default:
						for (i = 0; i < fileTemplates.length; i++)
						{
							fileTemplate = fileTemplates[i];
							if ( TemplatingHelper.getTemplateLabel(fileTemplate) == eventName )
							{
								if (fileTemplate.fileBridge.exists)
								{
									openNewComponentTypeChoose(event, NewFilePopup.AS_CUSTOM, fileTemplate);
									break;
								}
							}
						}
						break;
				}
			}
			else
			{
				eventName = event.type;
				// Figure out which menu item was clicked (add extra data var to MenuPlugin/event dispatching?)
				for (i = 0; i < ConstantsCoreVO.TEMPLATES_FILES.length; i++)
				{
					fileTemplate = ConstantsCoreVO.TEMPLATES_FILES[i];
					if ( TemplatingHelper.getTemplateLabel(fileTemplate) == eventName )
					{
						createFile(fileTemplate);
						return;
					}
				}
			}
		}
		
		protected function createFile(template:FileLocation):void
		{
			var editor:BasicTextEditor = new BasicTextEditor();
			
			// Let plugins hook in syntax highlighters & other functionality
			var editorEvent:EditorPluginEvent = new EditorPluginEvent(EditorPluginEvent.EVENT_EDITOR_OPEN);
			editorEvent.editor = editor.getEditorComponent();
			editorEvent.newFile = true;
			editorEvent.fileExtension = TemplatingHelper.getExtension(template);
			dispatcher.dispatchEvent(editorEvent);
			
			editor.defaultLabel = "New " + TemplatingHelper.stripTemplate(template.fileBridge.name);
			
			// Read file data
			var content:String = ConstantsCoreVO.IS_AIR ? String(template.fileBridge.read()) : String(template.fileBridge.data);
			
			// Request additional data for templating
			var event:TemplateEvent = new TemplateEvent(TemplateEvent.REQUEST_ADDITIONAL_DATA, template);
			dispatcher.dispatchEvent(event);
			
			// Replace content if any
			content = TemplatingHelper.replace(content, event.templatingData);
			
			// Set content to editor
			editor.setContent(content);
			
			// Remove empty editor if one is focused
			if (model.activeEditor.isEmpty())
			{
				model.editors.removeItemAt(model.editors.getItemIndex(model.activeEditor));
			}
			
			dispatcher.dispatchEvent(
				new AddTabEvent(editor)
			);
		}
		
		protected function openMXMLComponentTypeChoose(event:Event):void
		{
			if (!newMXMLComponentPopup)
			{
				newMXMLComponentPopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, NewMXMLFilePopup, true) as NewMXMLFilePopup;
				newMXMLComponentPopup.addEventListener(CloseEvent.CLOSE, handleMXMLPopupClose);
				newMXMLComponentPopup.addEventListener(NewFileEvent.EVENT_NEW_FILE, onMXMLFileCreateRequest);
				
				// newFileEvent sends by TreeView when right-clicked 
				// context menu
				if (event is NewFileEvent) 
				{
					newMXMLComponentPopup.folderLocation = new FileLocation((event as NewFileEvent).filePath);
					newMXMLComponentPopup.wrapperOfFolderLocation = (event as NewFileEvent).insideLocation;
					newMXMLComponentPopup.wrapperBelongToProject = UtilsCore.getProjectFromProjectFolder((event as NewFileEvent).insideLocation);
				}
				else
				{
					// try to check if there is any selection in 
					// TreeView item
					var treeSelectedItem:FileWrapper = model.mainView.getTreeViewPanel().tree.selectedItem as FileWrapper;
					if (treeSelectedItem)
					{
						var creatingItemIn:FileWrapper = (treeSelectedItem.file.fileBridge.isDirectory) ? treeSelectedItem : FileWrapper(model.mainView.getTreeViewPanel().tree.getParentItem(treeSelectedItem));
						newMXMLComponentPopup.folderLocation = creatingItemIn.file;
						newMXMLComponentPopup.wrapperOfFolderLocation = creatingItemIn;
						newMXMLComponentPopup.wrapperBelongToProject = UtilsCore.getProjectFromProjectFolder(creatingItemIn);
					}
				}
				
				PopUpManager.centerPopUp(newMXMLComponentPopup);
			}
		}

        protected function openVisualEditorComponentTypeChoose(event:Event):void
        {
            if (!newVisualEditorFilePopup)
            {
                newVisualEditorFilePopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, NewVisualEditorFilePopup, true) as NewVisualEditorFilePopup;
                newVisualEditorFilePopup.addEventListener(CloseEvent.CLOSE, handleNewVisualEditorFilePopupClose);

                // newFileEvent sends by TreeView when right-clicked
                // context menu
                if (event is NewFileEvent)
                {
                    newVisualEditorFilePopup.folderLocation = new FileLocation((event as NewFileEvent).filePath);
                    newVisualEditorFilePopup.wrapperOfFolderLocation = (event as NewFileEvent).insideLocation;
                    newVisualEditorFilePopup.wrapperBelongToProject = UtilsCore.getProjectFromProjectFolder((event as NewFileEvent).insideLocation);
                }
                else
                {
                    // try to check if there is any selection in
                    // TreeView item
                    var treeSelectedItem:FileWrapper = model.mainView.getTreeViewPanel().tree.selectedItem as FileWrapper;
                    if (treeSelectedItem)
                    {
                        var creatingItemIn:FileWrapper = (treeSelectedItem.file.fileBridge.isDirectory) ? treeSelectedItem : FileWrapper(model.mainView.getTreeViewPanel().tree.getParentItem(treeSelectedItem));
                        newVisualEditorFilePopup.folderLocation = creatingItemIn.file;
                        newVisualEditorFilePopup.wrapperOfFolderLocation = creatingItemIn;
                        newVisualEditorFilePopup.wrapperBelongToProject = UtilsCore.getProjectFromProjectFolder(creatingItemIn);
                    }
                }

                PopUpManager.centerPopUp(newVisualEditorFilePopup);
            }
        }

		protected function openCSSComponentTypeChoose(event:Event):void
		{
			if (!newCSSComponentPopup)
			{
				newCSSComponentPopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, NewCSSFilePopup, true) as NewCSSFilePopup;
				newCSSComponentPopup.addEventListener(CloseEvent.CLOSE, handleCSSPopupClose);
				newCSSComponentPopup.addEventListener(NewFileEvent.EVENT_NEW_FILE, onCSSFileCreateRequest);
				
				// newFileEvent sends by TreeView when right-clicked 
				// context menu
				if (event is NewFileEvent) 
				{
					newCSSComponentPopup.folderLocation = new FileLocation((event as NewFileEvent).filePath);
					newCSSComponentPopup.wrapperOfFolderLocation = (event as NewFileEvent).insideLocation;
					newCSSComponentPopup.wrapperBelongToProject = UtilsCore.getProjectFromProjectFolder((event as NewFileEvent).insideLocation);
				}
				else
				{
					// try to check if there is any selection in 
					// TreeView item
					var treeSelectedItem:FileWrapper = model.mainView.getTreeViewPanel().tree.selectedItem as FileWrapper;
					if (treeSelectedItem)
					{
						var creatingItemIn:FileWrapper = (treeSelectedItem.file.fileBridge.isDirectory) ? treeSelectedItem : FileWrapper(model.mainView.getTreeViewPanel().tree.getParentItem(treeSelectedItem));
						newCSSComponentPopup.folderLocation = creatingItemIn.file;
						newCSSComponentPopup.wrapperOfFolderLocation = creatingItemIn;
						newCSSComponentPopup.wrapperBelongToProject = UtilsCore.getProjectFromProjectFolder(creatingItemIn);
					}
				}
				
				PopUpManager.centerPopUp(newCSSComponentPopup);
			}
		}
		
		protected function openNewComponentTypeChoose(event:Event, openType:String, fileTemplate:FileLocation=null):void
		{
			if (!newFilePopup)
			{
				newFilePopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, NewFilePopup, true) as NewFilePopup;
				newFilePopup.addEventListener(CloseEvent.CLOSE, handleFilePopupClose);
				newFilePopup.addEventListener(NewFileEvent.EVENT_NEW_FILE, onFileCreateRequest);
				newFilePopup.openType = openType;
				newFilePopup.fileTemplate = fileTemplate;
				
				// newFileEvent sends by TreeView when right-clicked 
				// context menu
				if (event is NewFileEvent) 
				{
					newFilePopup.wrapperOfFolderLocation = (event as NewFileEvent).insideLocation;
					newFilePopup.wrapperBelongToProject = UtilsCore.getProjectFromProjectFolder((event as NewFileEvent).insideLocation);
				}
				else
				{
					// try to check if there is any selection in 
					// TreeView item
					var treeSelectedItem:FileWrapper = model.mainView.getTreeViewPanel().tree.selectedItem as FileWrapper;
					if (treeSelectedItem)
					{
						var creatingItemIn:FileWrapper = (treeSelectedItem.file.fileBridge.isDirectory) ? treeSelectedItem : FileWrapper(model.mainView.getTreeViewPanel().tree.getParentItem(treeSelectedItem));
						newFilePopup.wrapperOfFolderLocation = creatingItemIn;
						newFilePopup.wrapperBelongToProject = UtilsCore.getProjectFromProjectFolder(creatingItemIn);
					}
				}
				
				PopUpManager.centerPopUp(newFilePopup);
			}
		}
		
		protected function handleFilePopupClose(event:CloseEvent):void
		{
			newFilePopup.removeEventListener(CloseEvent.CLOSE, handleFilePopupClose);
			newFilePopup.removeEventListener(NewFileEvent.EVENT_NEW_FILE, onFileCreateRequest);
			newFilePopup = null;
		}
		
		protected function handleCSSPopupClose(event:CloseEvent):void
		{
			newCSSComponentPopup.removeEventListener(CloseEvent.CLOSE, handleCSSPopupClose);
			newCSSComponentPopup.removeEventListener(NewFileEvent.EVENT_NEW_FILE, onCSSFileCreateRequest);
			newCSSComponentPopup = null;
		}
		
		protected function handleMXMLPopupClose(event:CloseEvent):void
		{
			newMXMLComponentPopup.removeEventListener(CloseEvent.CLOSE, handleMXMLPopupClose);
			newMXMLComponentPopup.removeEventListener(NewFileEvent.EVENT_NEW_FILE, onMXMLFileCreateRequest);
			newMXMLComponentPopup = null;
		}

        protected function handleNewVisualEditorFilePopupClose(event:CloseEvent):void
        {
            newVisualEditorFilePopup.removeEventListener(CloseEvent.CLOSE, handleNewVisualEditorFilePopupClose);
            newVisualEditorFilePopup = null;
        }

		protected function openAS3ComponentTypeChoose(event:Event, isInterfaceDialog:Boolean):void
		{
			if (!newAS3ComponentPopup)
			{
				newAS3ComponentPopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, NewASFilePopup, true) as NewASFilePopup;
				newAS3ComponentPopup.addEventListener(CloseEvent.CLOSE, handleAS3PopupClose);
				newAS3ComponentPopup.addEventListener(NewFileEvent.EVENT_NEW_FILE, isInterfaceDialog ? onNewInterfaceCreateRequest : onNewAS3FileCreateRequest);
				newAS3ComponentPopup.isInterfaceDialog = isInterfaceDialog;
				
				// newFileEvent sends by TreeView when right-clicked 
				// context menu
				if (event is NewFileEvent) 
				{
					newAS3ComponentPopup.folderLocation = new FileLocation((event as NewFileEvent).filePath);
					newAS3ComponentPopup.wrapperOfFolderLocation = (event as NewFileEvent).insideLocation;
					newAS3ComponentPopup.wrapperBelongToProject = UtilsCore.getProjectFromProjectFolder((event as NewFileEvent).insideLocation);
				}
				else
				{
					// try to check if there is any selection in 
					// TreeView item
					var treeSelectedItem:FileWrapper = model.mainView.getTreeViewPanel().tree.selectedItem as FileWrapper;
					if (treeSelectedItem)
					{
						var creatingItemIn:FileWrapper = (treeSelectedItem.file.fileBridge.isDirectory) ? treeSelectedItem : FileWrapper(model.mainView.getTreeViewPanel().tree.getParentItem(treeSelectedItem));
						newAS3ComponentPopup.folderLocation = creatingItemIn.file;
						newAS3ComponentPopup.wrapperOfFolderLocation = creatingItemIn;
						newAS3ComponentPopup.wrapperBelongToProject = UtilsCore.getProjectFromProjectFolder(creatingItemIn);
					}
				}
				
				PopUpManager.centerPopUp(newAS3ComponentPopup);
			}
		}
		
		protected function handleAS3PopupClose(event:CloseEvent):void
		{
			newAS3ComponentPopup.removeEventListener(CloseEvent.CLOSE, handleAS3PopupClose);
			newAS3ComponentPopup.removeEventListener(NewFileEvent.EVENT_NEW_FILE, onNewAS3FileCreateRequest);
			newAS3ComponentPopup.removeEventListener(NewFileEvent.EVENT_NEW_FILE, onNewInterfaceCreateRequest);
			newAS3ComponentPopup = null;
		}

		protected function handleJavaPopupClose(event:CloseEvent):void
		{
			newJavaComponentPopup.removeEventListener(CloseEvent.CLOSE, handleJavaPopupClose);
			newJavaComponentPopup.removeEventListener(NewFileEvent.EVENT_NEW_FILE, onNewAS3FileCreateRequest);
			newJavaComponentPopup.removeEventListener(NewFileEvent.EVENT_NEW_FILE, onNewInterfaceCreateRequest);
			newJavaComponentPopup = null;
		}

		protected function handleGroovyPopupClose(event:CloseEvent):void
		{
			newGroovyComponentPopup.removeEventListener(CloseEvent.CLOSE, handleGroovyPopupClose);
			newGroovyComponentPopup.removeEventListener(NewFileEvent.EVENT_NEW_FILE, onNewAS3FileCreateRequest);
			newGroovyComponentPopup.removeEventListener(NewFileEvent.EVENT_NEW_FILE, onNewInterfaceCreateRequest);
			newGroovyComponentPopup = null;
		}

		protected function handleHaxePopupClose(event:CloseEvent):void
		{
			newHaxeComponentPopup.removeEventListener(CloseEvent.CLOSE, handleHaxePopupClose);
			newHaxeComponentPopup.removeEventListener(NewFileEvent.EVENT_NEW_FILE, onNewAS3FileCreateRequest);
			newHaxeComponentPopup.removeEventListener(NewFileEvent.EVENT_NEW_FILE, onNewInterfaceCreateRequest);
			newHaxeComponentPopup = null;
		}

		protected function openJavaTypeChoose(event:Event, isInterfaceDialog:Boolean):void
		{
			if (!newJavaComponentPopup)
			{
				newJavaComponentPopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, NewJavaFilePopup, true) as NewJavaFilePopup;
				newJavaComponentPopup.addEventListener(CloseEvent.CLOSE, handleJavaPopupClose);
				newJavaComponentPopup.addEventListener(NewFileEvent.EVENT_NEW_FILE, isInterfaceDialog ? onNewInterfaceCreateRequest : onNewAS3FileCreateRequest);
				newJavaComponentPopup.isInterfaceDialog = isInterfaceDialog;

				// newFileEvent sends by TreeView when right-clicked
				// context menu
				if (event is NewFileEvent)
				{
					newJavaComponentPopup.folderLocation = new FileLocation((event as NewFileEvent).filePath);
					newJavaComponentPopup.wrapperOfFolderLocation = (event as NewFileEvent).insideLocation;
					newJavaComponentPopup.wrapperBelongToProject = UtilsCore.getProjectFromProjectFolder((event as NewFileEvent).insideLocation);
				}
				else
				{
					// try to check if there is any selection in
					// TreeView item
					var treeSelectedItem:FileWrapper = model.mainView.getTreeViewPanel().tree.selectedItem as FileWrapper;
					if (treeSelectedItem)
					{
						var creatingItemIn:FileWrapper = (treeSelectedItem.file.fileBridge.isDirectory) ? treeSelectedItem : FileWrapper(model.mainView.getTreeViewPanel().tree.getParentItem(treeSelectedItem));
						newJavaComponentPopup.folderLocation = creatingItemIn.file;
						newJavaComponentPopup.wrapperOfFolderLocation = creatingItemIn;
						newJavaComponentPopup.wrapperBelongToProject = UtilsCore.getProjectFromProjectFolder(creatingItemIn);
					}
				}

				PopUpManager.centerPopUp(newJavaComponentPopup);
			}
		}
		
		protected function checkAndUpdateIfTemplateModified(event:NewFileEvent):void
		{
			var modifiedTemplate:FileLocation = TemplatingHelper.getCustomFileFor(event.fromTemplate);
			if (modifiedTemplate.fileBridge.exists) event.fromTemplate = modifiedTemplate;
		}

		protected function openGroovyTypeChoose(event:Event, isInterfaceDialog:Boolean):void
		{
			if (!newGroovyComponentPopup)
			{
				newGroovyComponentPopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, NewGroovyFilePopup, true) as NewGroovyFilePopup;
				newGroovyComponentPopup.addEventListener(CloseEvent.CLOSE, handleGroovyPopupClose);
				newGroovyComponentPopup.addEventListener(NewFileEvent.EVENT_NEW_FILE, isInterfaceDialog ? onNewInterfaceCreateRequest : onNewAS3FileCreateRequest);
				newGroovyComponentPopup.isInterfaceDialog = isInterfaceDialog;

				// newFileEvent sends by TreeView when right-clicked
				// context menu
				if (event is NewFileEvent)
				{
					newGroovyComponentPopup.folderLocation = new FileLocation((event as NewFileEvent).filePath);
					newGroovyComponentPopup.wrapperOfFolderLocation = (event as NewFileEvent).insideLocation;
					newGroovyComponentPopup.wrapperBelongToProject = UtilsCore.getProjectFromProjectFolder((event as NewFileEvent).insideLocation);
				}
				else
				{
					// try to check if there is any selection in
					// TreeView item
					var treeSelectedItem:FileWrapper = model.mainView.getTreeViewPanel().tree.selectedItem as FileWrapper;
					if (treeSelectedItem)
					{
						var creatingItemIn:FileWrapper = (treeSelectedItem.file.fileBridge.isDirectory) ? treeSelectedItem : FileWrapper(model.mainView.getTreeViewPanel().tree.getParentItem(treeSelectedItem));
						newGroovyComponentPopup.folderLocation = creatingItemIn.file;
						newGroovyComponentPopup.wrapperOfFolderLocation = creatingItemIn;
						newGroovyComponentPopup.wrapperBelongToProject = UtilsCore.getProjectFromProjectFolder(creatingItemIn);
					}
				}

				PopUpManager.centerPopUp(newGroovyComponentPopup);
			}
		}

		protected function openHaxeTypeChoose(event:Event, isInterfaceDialog:Boolean):void
		{
			if (!newHaxeComponentPopup)
			{
				newHaxeComponentPopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, NewHaxeFilePopup, true) as NewHaxeFilePopup;
				newHaxeComponentPopup.addEventListener(CloseEvent.CLOSE, handleHaxePopupClose);
				newHaxeComponentPopup.addEventListener(NewFileEvent.EVENT_NEW_FILE, isInterfaceDialog ? onNewInterfaceCreateRequest : onNewAS3FileCreateRequest);
				newHaxeComponentPopup.isInterfaceDialog = isInterfaceDialog;

				// newFileEvent sends by TreeView when right-clicked
				// context menu
				if (event is NewFileEvent)
				{
					newHaxeComponentPopup.folderLocation = new FileLocation((event as NewFileEvent).filePath);
					newHaxeComponentPopup.wrapperOfFolderLocation = (event as NewFileEvent).insideLocation;
					newHaxeComponentPopup.wrapperBelongToProject = UtilsCore.getProjectFromProjectFolder((event as NewFileEvent).insideLocation);
				}
				else
				{
					// try to check if there is any selection in
					// TreeView item
					var treeSelectedItem:FileWrapper = model.mainView.getTreeViewPanel().tree.selectedItem as FileWrapper;
					if (treeSelectedItem)
					{
						var creatingItemIn:FileWrapper = (treeSelectedItem.file.fileBridge.isDirectory) ? treeSelectedItem : FileWrapper(model.mainView.getTreeViewPanel().tree.getParentItem(treeSelectedItem));
						newHaxeComponentPopup.folderLocation = creatingItemIn.file;
						newHaxeComponentPopup.wrapperOfFolderLocation = creatingItemIn;
						newHaxeComponentPopup.wrapperBelongToProject = UtilsCore.getProjectFromProjectFolder(creatingItemIn);
					}
				}

				PopUpManager.centerPopUp(newHaxeComponentPopup);
			}
		}

		protected function onNewAS3FileCreateRequest(event:NewFileEvent):void
		{
			checkAndUpdateIfTemplateModified(event);
			if (event.fromTemplate.fileBridge.exists)
			{
				var content:String = String(event.fromTemplate.fileBridge.read());
				var pattern:RegExp = new RegExp(TextUtil.escapeRegex("$fileName"), "g");
				var as3FileAttributes:AS3ClassAttributes = event.extraParameters[0] as AS3ClassAttributes;

				content = content.replace(pattern, event.fileName);
				
				var packagePath:String = UtilsCore.getPackageReferenceByProjectPath(event.ofProject["classpaths"], event.insideLocation.nativePath, null, null, false);
				if (packagePath != "")
				{
					packagePath = packagePath.substr(1, packagePath.length);
				} // removing . at index 0
				else
				{
					if (event.fileExtension == ".java")
					{
						content = content.replace("package", "");
						content = content.replace(";", "");
					}
					if (event.fileExtension == ".groovy")
					{
						content = content.replace("package", "");
					}
					if (event.fileExtension == ".hx")
					{
						content = content.replace("package", "");
						content = content.replace(";", "");
					}
				}

				content = content.replace("$packageName", packagePath);
				content = content.replace("$imports", as3FileAttributes.getImports());
				content = content.replace("$modifierA", as3FileAttributes.modifierA);

				var tmpModifierBData:String = as3FileAttributes.getModifiersB();
				content = content.replace(((tmpModifierBData != "") ? "$modifierB" : "$modifierB "), tmpModifierBData);

				var extendClass:String = as3FileAttributes.extendsClassInterface;
				content = content.replace("$extends", extendClass ? "extends " + extendClass : "");

                var implementsInterface:String = as3FileAttributes.implementsInterface;
                content = content.replace("$implements", implementsInterface ? "implements " + implementsInterface : "");

                content = StringUtil.trim(content);

				var fileToSave:FileLocation = new FileLocation(event.insideLocation.nativePath + event.fromTemplate.fileBridge.separator + event.fileName + event.fileExtension);
				fileToSave.fileBridge.save(content);

                notifyNewFileCreated(event.insideLocation, fileToSave);
			}
		}
		
		protected function onNewInterfaceCreateRequest(event:NewFileEvent):void
		{
			checkAndUpdateIfTemplateModified(event);
			if (event.fromTemplate.fileBridge.exists)
			{
				var content:String = String(event.fromTemplate.fileBridge.read());
				var pattern:RegExp = new RegExp(TextUtil.escapeRegex("$fileName"), "g");
                var as3InterfaceAttributes:AS3ClassAttributes = event.extraParameters[0] as AS3ClassAttributes;

				content = content.replace(pattern, event.fileName);
				
				var packagePath:String = UtilsCore.getPackageReferenceByProjectPath(event.ofProject["classpaths"], event.insideLocation.nativePath, null, null, false);
				if (packagePath != "") packagePath = packagePath.substr(1, packagePath.length); // removing . at index 0
				content = content.replace("$packageName", packagePath);
                content = content.replace("$imports", as3InterfaceAttributes.getImports());
				content = content.replace("$modifierA", as3InterfaceAttributes.modifierA);

                var extendClass:String = as3InterfaceAttributes.implementsInterface;
                content = content.replace("$extends", extendClass ? "extends " + extendClass : "");

				var fileToSave:FileLocation = new FileLocation(event.insideLocation.nativePath + event.fromTemplate.fileBridge.separator + event.fileName + event.fileExtension);
				fileToSave.fileBridge.save(content);

                notifyNewFileCreated(event.insideLocation, fileToSave);
			}
		}

		protected function onMXMLFileCreateRequest(event:NewFileEvent):void
		{
			checkAndUpdateIfTemplateModified(event);
			if (event.fromTemplate.fileBridge.exists)
			{
				var content:String = String(event.fromTemplate.fileBridge.read());
				var fileToSave:FileLocation = new FileLocation(event.insideLocation.nativePath + event.fromTemplate.fileBridge.separator + event.fileName +".mxml");
				fileToSave.fileBridge.save(content);

                notifyNewFileCreated(event.insideLocation, fileToSave);
			}
		}
		
		protected function onFileCreateRequest(event:NewFileEvent):void
		{
			checkAndUpdateIfTemplateModified(event);
			if (event.fromTemplate.fileBridge.exists)
			{
				var isCustomExtension:Boolean = newFilePopup.openType == NewFilePopup.AS_PLAIN_TEXT;
				
				var content:String = String(event.fromTemplate.fileBridge.read());
				var tmpArr:Array = event.fromTemplate.fileBridge.name.split(".");
				var fileToSave:FileLocation = new FileLocation(event.insideLocation.nativePath + event.fromTemplate.fileBridge.separator + event.fileName + 
					(isCustomExtension ? "" : "."+ tmpArr[tmpArr.length - 2]));
				fileToSave.fileBridge.save(content);

                notifyNewFileCreated(event.insideLocation, fileToSave);
			}
		}

        protected function onVisualEditorFileCreateRequest(event:NewFileEvent):void
        {
			checkAndUpdateIfTemplateModified(event);
            if (event.fromTemplate.fileBridge.exists)
            {
                var content:String = String(event.fromTemplate.fileBridge.read());
				var extension:String = ".mxml";
				var project:AS3ProjectVO = event.ofProject as AS3ProjectVO;
				var shallNotifyToTree:Boolean = true;
				
				// to handle event relay in custom way in case of
				// auto-xhtml-file-generation - this will not relay the
				// immediate event to treeview
				if (event.extraParameters.length != 0 && ('relayEvent' in event.extraParameters[0]))
				{
					shallNotifyToTree = event.extraParameters[0].relayEvent;
				}
				
				if (project && project.isPrimeFacesVisualEditorProject)
				{
                    extension = ".xhtml";
                    var fileToSave:FileLocation = new FileLocation(event.insideLocation.nativePath + event.fromTemplate.fileBridge.separator + event.fileName + extension);

                    var primeFacesXML:XML = new XML(content);
					var hNamespace:Namespace = primeFacesXML.namespace("h");
					var head:XMLList = primeFacesXML..hNamespace::["head"];
					if (head.length() > 0)
					{
						var headXML:XML = head[0];
                        var cssStyleSheetXml:XML = new XML("<link></link>");
                        cssStyleSheetXml.@rel = "stylesheet";
                        cssStyleSheetXml.@type = "text/css";
                        cssStyleSheetXml.@href = "resources/moonshine-layout-styles.css";

                        headXML.appendChild(cssStyleSheetXml);

                        var relativeFilePath:String = fileToSave.fileBridge.getRelativePath(project.folderLocation, true);
                        cssStyleSheetXml = new XML("<link></link>");
                        cssStyleSheetXml.@rel = "stylesheet";
                        cssStyleSheetXml.@type = "text/css";
                        cssStyleSheetXml.@href = relativeFilePath + "/assets/moonshine-layout-styles.css";

                        headXML.appendChild(cssStyleSheetXml);
                        var markAsXml:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";

						content = markAsXml + primeFacesXML.toXMLString();
					}
				}
				else
				{
                    fileToSave = new FileLocation(event.insideLocation.nativePath + event.fromTemplate.fileBridge.separator + event.fileName + extension);
				}

                fileToSave.fileBridge.save(content);
				if (shallNotifyToTree) notifyNewFileCreated(event.insideLocation, fileToSave, event.isOpenAfterCreate);
            }
        }

		protected function onCSSFileCreateRequest(event:NewFileEvent):void
		{
			checkAndUpdateIfTemplateModified(event);
			if (event.fromTemplate.fileBridge.exists)
			{
				var content:String = String(event.fromTemplate.fileBridge.read());
				var fileToSave:FileLocation = new FileLocation(event.insideLocation.nativePath + event.fromTemplate.fileBridge.separator + event.fileName +".css");
				fileToSave.fileBridge.save(content);

                notifyNewFileCreated(event.insideLocation, fileToSave);
			}
		}

		protected function handleNewProjectFile(event:Event):void
		{
            newProjectFromTemplate(event.type);
		}
		
		private function filterProjectsTemplates(item:TemplateVO, index:int, arr:Array):Boolean
		{
			return item.displayHome;
		}

        private function handleExportNewProjectFromTemplate(event:ExportVisualEditorProjectEvent):void
        {
			newProjectFromTemplate("eventNewProjectFromTemplateFlex Desktop Project (MacOS, Windows)", event.exportedProject);
        }

        private function newProjectFromTemplate(eventName:String, exportProject:AS3ProjectVO = null):void
        {
            if (ConstantsCoreVO.IS_AIR)
            {
                eventName = eventName.substr(27);
                if(eventName == "HaXe SWF Project")
                {
                    Alert.show("coming shortly");
                    return;
                }
                // Figure out which menu item was clicked (add extra data var to MenuPlugin/event dispatching?)
                for each (var projectTemplate:FileLocation in projectTemplates)
                {
                    if ( TemplatingHelper.getTemplateLabel(projectTemplate) == eventName )
                    {
                        var extension:String = null;
                        var settingsFile:FileLocation = null;

                        settingsFile = getSettingsTemplateFileLocation(projectTemplate);
                        extension = settingsFile ? TemplatingHelper.getExtension(settingsFile) : null;

                        dispatcher.dispatchEvent(new NewProjectEvent(NewProjectEvent.CREATE_NEW_PROJECT,
                                extension, settingsFile, projectTemplate, exportProject));
                        break;
                    }
                }
            }
            else
            {
                dispatcher.dispatchEvent(
                        new NewProjectEvent(NewProjectEvent.CREATE_NEW_PROJECT, eventName, null, null)
                );
            }
        }

        protected function getSettingsTemplateFileLocation(projectDir:FileLocation):FileLocation
        {
            // TODO: If none is found, prompt user for location to save project & template it over
            var files:Array = projectDir.fileBridge.getDirectoryListing();

            for each (var file:Object in files)
            {
                if (!file.isDirectory)
                {
                    if (file.name.indexOf("$Settings.") == 0)
                    {
                        return new FileLocation(file.nativePath);
                    }
                }
            }

            return null;
        }

		/*
		Silly little helper methods
		*/
		protected function isCustom(template:FileLocation):Boolean
		{
			if (template.fileBridge.nativePath.indexOf(template.fileBridge.resolveApplicationStorageDirectoryPath(null).fileBridge.nativePath) == 0)
			{
				return true;
			}
			
			return false;
		}

		private function notifyNewFileCreated(insideLocation:FileWrapper, fileToSave:FileLocation, isOpenAfterCreate:Boolean=true):void
		{
            // opens the file after writing done
			if (isOpenAfterCreate)
			{
	            dispatcher.dispatchEvent(
					new OpenFileEvent(OpenFileEvent.OPEN_FILE, [fileToSave], -1, [insideLocation])
	            );
			}

            // notify the tree view if it needs to refresh
            // the containing folder to make newly created file show
            if (insideLocation)
            {
				var treeEvent:TreeMenuItemEvent = new TreeMenuItemEvent(TreeMenuItemEvent.NEW_FILE_CREATED, fileToSave.fileBridge.nativePath, insideLocation);
				treeEvent.extra = fileToSave;
				dispatcher.dispatchEvent(treeEvent);
            }
		}
	}
}
