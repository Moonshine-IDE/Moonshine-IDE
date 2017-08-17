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
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import mx.resources.ResourceManager;
	
	import __AS3__.vec.Vector;
	
	import actionScripts.events.AddTabEvent;
	import actionScripts.events.EditorPluginEvent;
	import actionScripts.events.NewFileEvent;
	import actionScripts.events.NewProjectEvent;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.TreeMenuItemEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.IMenuPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.StaticLabelSetting;
	import actionScripts.plugin.templating.event.RequestTemplatesEvent;
	import actionScripts.plugin.templating.event.TemplateEvent;
	import actionScripts.plugin.templating.settings.NewTemplateSetting;
	import actionScripts.plugin.templating.settings.TemplateSetting;
	import actionScripts.plugin.templating.settings.renderer.NewTemplateRenderer;
	import actionScripts.plugin.templating.settings.renderer.TemplateRenderer;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.menu.vo.MenuItem;
	import actionScripts.utils.TextUtil;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.AS3ClassAttributes;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.FileWrapper;
	import actionScripts.valueObjects.ProjectVO;
	
	import components.popup.NewASFilePopup;
	import components.popup.NewCSSFilePopup;
	import components.popup.NewFilePopup;
	import components.popup.NewMXMLFilePopup;

	/*
		Templating plugin
		
		Provides templates & possibility to customize them
		
		Standard templates ship in the app-dir, but since we can't change those files once installed 
		we override them by copying them to app-storage-dir & let the user modify them there.
	*/
	
	public class TemplatingPlugin extends PluginBase implements ISettingsProvider,IMenuPlugin
	{
		override public function get name():String 			{return "Templating Plugin";}
		override public function get author():String 		{return "Moonshine Project Team";}
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
		protected var newCSSComponentPopup:NewCSSFilePopup;
		protected var newFilePopup:NewFilePopup;
		
		public function TemplatingPlugin()
		{
			super();
			
			if (ConstantsCoreVO.IS_AIR)
			{
				templatesDir = model.fileCore.resolveApplicationDirectoryPath("elements/templates");
				customTemplatesDir = model.fileCore.resolveApplicationStorageDirectoryPath("templates");
				readTemplates();
			}
		}
		
		override public function activate():void
		{
			super.activate();
			
			dispatcher.addEventListener(RequestTemplatesEvent.EVENT_REQUEST_TEMPLATES, handleTemplateRequest);
			dispatcher.addEventListener(TemplateEvent.CREATE_NEW_FILE, handleCreateFileTemplate);
			
			// For web Moonshine, we won't depend on getMenu()
			// getMenu() exclusively calls for desktop Moonshine
			if (!ConstantsCoreVO.IS_AIR)
			{
				for each (var m:FileLocation in ConstantsCoreVO.TEMPLATES_FILES)
				{
					var fileName:String = m.fileBridge.name.substring(0,m.fileBridge.name.lastIndexOf("."))
					dispatcher.addEventListener(fileName, handleNewTemplateFile);
				}
				
				for each (var project:FileLocation in ConstantsCoreVO.TEMPLATES_PROJECTS)
				{
					dispatcher.addEventListener(project.fileBridge.name, handleNewProjectFile);
				}
			}
		}
		
		protected function readTemplates():void
		{
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
			
			// Just to generate a divider in relevant UI
			ConstantsCoreVO.TEMPLATES_MXML_COMPONENTS.addItem("NOTHING");
			
			files = templatesDir.resolvePath("files/mxml/flexjs");
			list = files.fileBridge.getDirectoryListing();
			for each (file in list)
			{
				if (!file.isHidden && !file.isDirectory)
					ConstantsCoreVO.TEMPLATES_MXML_COMPONENTS.addItem(file);
			}
			
			var projects:FileLocation = templatesDir.resolvePath("projects");
			list = projects.fileBridge.getDirectoryListing();
			for each (file in list)
			{
				if (!file.isHidden && file.isDirectory)
					projectTemplates.push(new FileLocation(file.nativePath));
			}
				
			// Find user-added custom templates
			if (!customTemplatesDir.fileBridge.exists) customTemplatesDir.fileBridge.createDirectory();
			
			files = customTemplatesDir.resolvePath("files");
			if (!files.fileBridge.exists) files.fileBridge.createDirectory();
			var fileList:Array = files.fileBridge.getDirectoryListing();
			
			for each (file in fileList)
			{
				if (getOriginalFileForCustom(new FileLocation(file.nativePath)).fileBridge.exists == false
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
				if (getOriginalFileForCustom(new FileLocation(file.nativePath)).fileBridge.exists == false
					&& !file.isHidden && file.isDirectory)
				{
					projectTemplates.push(new FileLocation(file.nativePath));
				}
			}
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
			newFileTemplateSetting.renderer.addEventListener('create', handleFileTemplateCreate);
			
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
			newProjectTemplateSetting.renderer.addEventListener('create', handleProjectTemplateCreate);
			
			settings.push(newProjectTemplateSetting);
			
			settingsList = settings;
			return settings;
		}
		
		public function getMenu():MenuItem
		{	
			var newFileMenu:MenuItem = new MenuItem('New');
			newFileMenu.parents = ["File", "New"];
			newFileMenu.items = new Vector.<MenuItem>();
			
			for each (var fileTemplate:FileLocation in fileTemplates)
			{
				if (fileTemplate.fileBridge.isHidden) continue;
				var lbl:String = TemplatingHelper.getTemplateLabel(fileTemplate);
				
				// TODO: Do MenuEvent and have data:* for this kind of thing
				var eventType:String = "eventNewFileFromTemplate"+lbl;
				
				dispatcher.addEventListener(eventType, handleNewTemplateFile);
				
				var menuItem:MenuItem = new MenuItem(lbl, null, eventType);
				menuItem.data = fileTemplate; 
				
				newFileMenu.items.push(menuItem);
			}
			
			var separator:MenuItem = new MenuItem(null);
			newFileMenu.items.push(separator);
			
			for each (var projectTemplate:FileLocation in projectTemplates)
			{
				if (projectTemplate.fileBridge.isHidden) continue;
				lbl = TemplatingHelper.getTemplateLabel(projectTemplate);
				
				eventType = "eventNewProjectFromTemplate"+lbl;
				
				dispatcher.addEventListener(eventType, handleNewProjectFile)
				
				menuItem = new MenuItem(lbl, null, eventType);
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
				customTemplate = getCustomFileFor(template);
			}
			
			var setting:TemplateSetting = new TemplateSetting(originalTemplate, customTemplate, template.fileBridge.name);
			setting.renderer.addEventListener(TemplateRenderer.EVENT_MODIFY, handleTemplateModify, false, 0, true);
			setting.renderer.addEventListener(TemplateRenderer.EVENT_RESET, handleTemplateReset, false, 0, true);
			setting.renderer.addEventListener(TemplateRenderer.EVENT_REMOVE, handleTemplateReset, false, 0, true);
			
			return setting;
		}
		
		
		protected function handleFileTemplateCreate(event:Event):void
		{
			// Create new file
			var newTemplate:FileLocation = this.customTemplatesDir.resolvePath("files/New file template.txt");
			newTemplate.fileBridge.createFile();
			
			// Add setting for it so we can remove it
			var t:TemplateSetting = new TemplateSetting(null, newTemplate, newTemplate.fileBridge.name);
			t.renderer.addEventListener(TemplateRenderer.EVENT_MODIFY, handleTemplateModify);
			t.renderer.addEventListener(TemplateRenderer.EVENT_REMOVE, handleTemplateReset);
			var newPos:int = this.settingsList.indexOf(newFileTemplateSetting);
			settingsList.splice(newPos, 0, t);
			
			// Force settings view to redraw
			NewTemplateRenderer(event.target).dispatchEvent(new Event('refresh'));
			
			// Add to project view so user can rename it
			dispatcher.dispatchEvent(
				new ProjectEvent(ProjectEvent.ADD_PROJECT, new ProjectVO(newTemplate))
			);
						
			
			// Update internal template list
			readTemplates();
		}
		
		protected function handleProjectTemplateCreate(event:Event):void
		{
			var newTemplate:FileLocation = this.customTemplatesDir.resolvePath("projects/New Project Template/");
			newTemplate.fileBridge.createDirectory();
			
			var t:TemplateSetting = new TemplateSetting(null, newTemplate, newTemplate.fileBridge.name);
			t.renderer.addEventListener(TemplateRenderer.EVENT_MODIFY, handleTemplateModify);
			t.renderer.addEventListener(TemplateRenderer.EVENT_REMOVE, handleTemplateReset);
			var newPos:int = this.settingsList.indexOf(newProjectTemplateSetting);
			settingsList.splice(newPos, 0, t);
			
			dispatcher.dispatchEvent(
				new ProjectEvent(ProjectEvent.ADD_PROJECT, new ProjectVO(newTemplate))
			);
			
			NewTemplateRenderer(event.target).dispatchEvent(new Event('refresh'));
			
			readTemplates();
		}
		
		protected function handleTemplateModify(event:Event):void
		{
			var rdr:TemplateRenderer = TemplateRenderer(event.target);
			var original:FileLocation = rdr.setting.originalTemplate;
			var custom:FileLocation = rdr.setting.customTemplate;
			
			var p:ProjectVO;
			
			if (!original || !original.fileBridge.exists)
			{
				p = new ProjectVO(custom)
			}
			else if (!custom.fileBridge.exists)
			{
				// Copy to app-storage so we can edit
				original.fileBridge.copyTo(custom);
				p = new ProjectVO(original);
			}
			
			// If project or custom, show in Project View so user can rename it
			if (custom.fileBridge.isDirectory || !original || !original.fileBridge.exists)
			{
				dispatcher.dispatchEvent(
					new ProjectEvent(ProjectEvent.ADD_PROJECT, p)
				);
			}
			
			// If not a project, open the template for editing
			if (!custom.fileBridge.isDirectory)
			{
				dispatcher.dispatchEvent(
					new OpenFileEvent(OpenFileEvent.OPEN_FILE, custom)
				);
			}
		}
		
		protected function getCustomFileFor(template:FileLocation):FileLocation
		{
			var appDirPath:String = template.fileBridge.resolveApplicationDirectoryPath(null).fileBridge.nativePath;
			var appStorageDirPath:String = template.fileBridge.resolveApplicationStorageDirectoryPath(null).fileBridge.nativePath;

			var customTemplatePath:String = template.fileBridge.nativePath.substr(appDirPath.length+1);
			var customTemplate:FileLocation = template.fileBridge.resolveApplicationStorageDirectoryPath(customTemplatePath);
			
			return customTemplate;
		}
		
		protected function getOriginalFileForCustom(template:FileLocation):FileLocation
		{
			var appDirPath:String = template.fileBridge.resolveApplicationDirectoryPath(null).fileBridge.nativePath;
			var appStorageDirPath:String = template.fileBridge.resolveApplicationStorageDirectoryPath(null).fileBridge.nativePath;

			var originalTemplatePath:String = template.fileBridge.nativePath.substr(appStorageDirPath.length+1);
			var originalTemplate:FileLocation = template.fileBridge.resolveApplicationDirectoryPath(originalTemplatePath);
			
			return originalTemplate;
		}
		
		protected function handleTemplateReset(event:Event):void
		{
			// Resetting a template just removes it from app-storage
			var rdr:TemplateRenderer = TemplateRenderer(event.target);
			var original:FileLocation = rdr.setting.originalTemplate;
			var custom:FileLocation = rdr.setting.customTemplate;
			
			if (custom.fileBridge.isDirectory) custom.fileBridge.deleteDirectory(true);
			else custom.fileBridge.deleteFile();
			
			if (!original)
			{
				var idx:int = settingsList.indexOf(rdr.setting);
				settingsList.splice(idx, 1);
				rdr.dispatchEvent(new Event('refresh'));
				
				readTemplates();	
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
					new OpenFileEvent(OpenFileEvent.OPEN_FILE, event.location)
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
						return;
					case "AS3 Class":
						openAS3ComponentTypeChoose(event, false);
						return;
					case "AS3 Interface":
						openAS3ComponentTypeChoose(event, true);
						return;
					case "CSS File":
						openCSSComponentTypeChoose(event);
						return;
					case "XML File":
						openNewComponentTypeChoose(event, NewFilePopup.AS_XML);
						return;
					case "File":
						openNewComponentTypeChoose(event, NewFilePopup.AS_PLAIN_TEXT);
						return;
				}
				
				for (i = 0; i < fileTemplates.length; i++)
				{
					fileTemplate = fileTemplates[i];
					if ( TemplatingHelper.getTemplateLabel(fileTemplate) == eventName )
					{
						var customTemplate:FileLocation = getCustomFileFor(fileTemplate);
						if (customTemplate.fileBridge.exists)
						{
							fileTemplate = customTemplate;
						}
							
						createFile(fileTemplate);
						return;
					}
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
		
		protected function openNewComponentTypeChoose(event:Event, openType:String):void
		{
			if (!newFilePopup)
			{
				newFilePopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, NewFilePopup, true) as NewFilePopup;
				newFilePopup.addEventListener(CloseEvent.CLOSE, handleFilePopupClose);
				newFilePopup.addEventListener(NewFileEvent.EVENT_NEW_FILE, onFileCreateRequest);
				newFilePopup.openType = openType;
				
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
		
		protected function onNewAS3FileCreateRequest(event:NewFileEvent):void
		{
			if (event.fromTemplate.fileBridge.exists)
			{
				var content:String = String(event.fromTemplate.fileBridge.read());
				var pattern:RegExp = new RegExp(TextUtil.escapeRegex("$fileName"), "g");
				content = content.replace(pattern, event.fileName);
				
				var packagePath:String = UtilsCore.getPackageReferenceByProjectPath((event.ofProject as AS3ProjectVO).classpaths[0].fileBridge.nativePath, event.insideLocation.nativePath, null, null, false);
				if (packagePath != "") packagePath = packagePath.substr(1, packagePath.length); // removing . at index 0
				content = content.replace("$packageName", packagePath);
				content = content.replace("$modifierA", (event.extraParameters[0] as AS3ClassAttributes).modifierA);
				
				var tmpModifierBData:String = (event.extraParameters[0] as AS3ClassAttributes).getModifiersB();
				content = content.replace(((tmpModifierBData != "") ? "$modifierB" : "$modifierB "), tmpModifierBData);
				
				var fileToSave:FileLocation = new FileLocation(event.insideLocation.nativePath + event.fromTemplate.fileBridge.separator + event.fileName +".as");
				fileToSave.fileBridge.save(content);
				
				// opens the file after writing done
				dispatcher.dispatchEvent(
					new OpenFileEvent(OpenFileEvent.OPEN_FILE, fileToSave)
				);
				
				// notify the tree view if it needs to refresh
				// the containing folder to make newly created file show
				if (event.insideLocation)
				{
					dispatcher.dispatchEvent(
						new TreeMenuItemEvent(TreeMenuItemEvent.NEW_FILE_CREATED, fileToSave.fileBridge.nativePath, event.insideLocation)
					);
				}
			}
		}
		
		protected function onNewInterfaceCreateRequest(event:NewFileEvent):void
		{
			if (event.fromTemplate.fileBridge.exists)
			{
				var content:String = String(event.fromTemplate.fileBridge.read());
				var pattern:RegExp = new RegExp(TextUtil.escapeRegex("$fileName"), "g");
				content = content.replace(pattern, event.fileName);
				
				var packagePath:String = UtilsCore.getPackageReferenceByProjectPath((event.ofProject as AS3ProjectVO).classpaths[0].fileBridge.nativePath, event.insideLocation.nativePath, null, null, false);
				if (packagePath != "") packagePath = packagePath.substr(1, packagePath.length); // removing . at index 0
				content = content.replace("$packageName", packagePath);
				content = content.replace("$modifierA", (event.extraParameters[0] as AS3ClassAttributes).modifierA);
				
				var fileToSave:FileLocation = new FileLocation(event.insideLocation.nativePath + event.fromTemplate.fileBridge.separator + event.fileName +".as");
				fileToSave.fileBridge.save(content);
				
				// opens the file after writing done
				dispatcher.dispatchEvent(
					new OpenFileEvent(OpenFileEvent.OPEN_FILE, fileToSave)
				);
				
				// notify the tree view if it needs to refresh
				// the containing folder to make newly created file show
				if (event.insideLocation)
				{
					dispatcher.dispatchEvent(
						new TreeMenuItemEvent(TreeMenuItemEvent.NEW_FILE_CREATED, fileToSave.fileBridge.nativePath, event.insideLocation)
					);
				}
			}
		}
		
		protected function onMXMLFileCreateRequest(event:NewFileEvent):void
		{
			if (event.fromTemplate.fileBridge.exists)
			{
				var content:String = String(event.fromTemplate.fileBridge.read());
				var fileToSave:FileLocation = new FileLocation(event.insideLocation.nativePath + event.fromTemplate.fileBridge.separator + event.fileName +".mxml");
				fileToSave.fileBridge.save(content);
				
				// opens the file after writing done
				dispatcher.dispatchEvent(
					new OpenFileEvent(OpenFileEvent.OPEN_FILE, fileToSave)
				);
				
				// notify the tree view if it needs to refresh
				// the containing folder to make newly created file show
				if (event.insideLocation)
				{
					dispatcher.dispatchEvent(
						new TreeMenuItemEvent(TreeMenuItemEvent.NEW_FILE_CREATED, fileToSave.fileBridge.nativePath, event.insideLocation)
						);
				}
			}
		}
		
		protected function onFileCreateRequest(event:NewFileEvent):void
		{
			if (event.fromTemplate.fileBridge.exists)
			{
				var content:String = String(event.fromTemplate.fileBridge.read());
				var fileToSave:FileLocation = new FileLocation(event.insideLocation.nativePath + event.fromTemplate.fileBridge.separator + event.fileName + ((event.fromTemplate == ConstantsCoreVO.TEMPLATE_XML) ? ".xml" : ""));
				fileToSave.fileBridge.save(content);
				
				// opens the file after writing done
				dispatcher.dispatchEvent(
					new OpenFileEvent(OpenFileEvent.OPEN_FILE, fileToSave)
				);
				
				// notify the tree view if it needs to refresh
				// the containing folder to make newly created file show
				if (event.insideLocation)
				{
					dispatcher.dispatchEvent(
						new TreeMenuItemEvent(TreeMenuItemEvent.NEW_FILE_CREATED, fileToSave.fileBridge.nativePath, event.insideLocation)
					);
				}
			}
		}
		
		protected function onCSSFileCreateRequest(event:NewFileEvent):void
		{
			if (event.fromTemplate.fileBridge.exists)
			{
				var content:String = String(event.fromTemplate.fileBridge.read());
				var fileToSave:FileLocation = new FileLocation(event.insideLocation.nativePath + event.fromTemplate.fileBridge.separator + event.fileName +".css");
				fileToSave.fileBridge.save(content);
				
				// opens the file after writing done
				dispatcher.dispatchEvent(
					new OpenFileEvent(OpenFileEvent.OPEN_FILE, fileToSave)
				);
				
				// notify the tree view if it needs to refresh
				// the containing folder to make newly created file show
				if (event.insideLocation)
				{
					dispatcher.dispatchEvent(
						new TreeMenuItemEvent(TreeMenuItemEvent.NEW_FILE_CREATED, fileToSave.fileBridge.nativePath, event.insideLocation)
					);
				}
			}
		}
		
		protected function handleNewProjectFile(event:Event):void
		{
			var eventName:String;
			if (ConstantsCoreVO.IS_AIR)
			{
				eventName = event.type.substr(27);
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
						var customTemplate:FileLocation = getCustomFileFor(projectTemplate);
						if (customTemplate.fileBridge.exists)
							projectTemplate = customTemplate;
							
						findSettingsFile(projectTemplate);
						break;
					}
				}	
			}
			else
			{
				eventName = event.type;
				dispatcher.dispatchEvent(
					new NewProjectEvent(NewProjectEvent.CREATE_NEW_PROJECT, eventName, null, null)
				);
			}
		}
		
		protected function findSettingsFile(projectDir:FileLocation):void
		{
			// TODO: If none is found, prompt user for location to save project & template it over
			var files:Array = projectDir.fileBridge.getDirectoryListing();
			
			for each (var file:Object in files)
			{
				if (!file.isDirectory)
				{
					if (file.name.indexOf("$Settings.") == 0)
					{
						file = new FileLocation(file.nativePath);
						var ext:String = TemplatingHelper.getExtension(file as FileLocation);
						dispatcher.dispatchEvent(
							new NewProjectEvent(NewProjectEvent.CREATE_NEW_PROJECT, ext, file as FileLocation, projectDir)
						);
						return;
					}
				}
			}
		}
		
		protected function handleTemplateRequest(event:RequestTemplatesEvent):void
		{
			event.fileTemplates = fileTemplates;
			event.projectTemplates = projectTemplates;	
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
		
	}
}