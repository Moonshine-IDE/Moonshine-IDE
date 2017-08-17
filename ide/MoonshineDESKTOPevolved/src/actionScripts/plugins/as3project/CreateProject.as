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
package actionScripts.plugins.as3project
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.SharedObject;
	
	import mx.collections.ArrayCollection;
	
	import actionScripts.events.AddTabEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.NewProjectEvent;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.actionscript.as3project.AS3ProjectPlugin;
	import actionScripts.plugin.actionscript.as3project.settings.NewProjectSourcePathListSetting;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.actionscript.as3project.vo.SWFOutputVO;
	import actionScripts.plugin.settings.SettingsView;
	import actionScripts.plugin.settings.vo.BooleanSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.ListSetting;
	import actionScripts.plugin.settings.vo.MultiOptionSetting;
	import actionScripts.plugin.settings.vo.NameValuePair;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	import actionScripts.plugin.settings.vo.StaticLabelSetting;
	import actionScripts.plugin.settings.vo.StringSetting;
	import actionScripts.plugin.templating.TemplatingHelper;
	import actionScripts.plugins.as3project.exporter.FlashDevelopExporter;
	import actionScripts.plugins.as3project.importer.FlashDevelopImporter;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.TemplateVO;
	
	public class CreateProject
	{
		public var activeType:uint = AS3ProjectPlugin.AS3PROJ_AS_AIR;
		
		private var newProjectSourcePathSetting:NewProjectSourcePathListSetting;
		private var newProjectNameSetting:StringSetting;
		private var newProjectPathSetting:PathSetting;
		private var newProjectTypeSetting:MultiOptionSetting;
		private var cookie:SharedObject;
		private var templateLookup:Object = {};
		private var project:AS3ProjectVO;
		private var allProjectTemplates:ArrayCollection;
		private var model:IDEModel = IDEModel.getInstance();
		private var isActionScriptProject:Boolean;
		private var isMobileProject:Boolean;
		private var isOpenProjectCall:Boolean;
		private var isFeathersProject:Boolean;
		
		private var _isProjectFromExistingSource:Boolean;
		private var _projectTemplateType:String;
		
		public function CreateProject(event:NewProjectEvent)
		{
			if (!allProjectTemplates)
			{
				allProjectTemplates = new ArrayCollection();
				allProjectTemplates.addAll(ConstantsCoreVO.TEMPLATES_PROJECTS);
				allProjectTemplates.addAll(ConstantsCoreVO.TEMPLATES_PROJECTS_SPECIALS);
			}
			
			createAS3Project(event);
		}
		
		public function get isProjectFromExistingSource():Boolean
		{
			return _isProjectFromExistingSource;
		}
		public function set isProjectFromExistingSource(value:Boolean):void
		{
			_isProjectFromExistingSource = project.isProjectFromExistingSource = value;
			if (_isProjectFromExistingSource)
			{
				///project.projectFolder = null;
				project.projectName = newProjectNameSetting.stringValue;
				project.folderLocation = new FileLocation(newProjectPathSetting.stringValue);
				
				newProjectSourcePathSetting.project = project;
				newProjectPathSetting.addEventListener(PathSetting.PATH_SELECTED, onProjectPathChanged);
			}
			else
			{
				newProjectPathSetting.removeEventListener(PathSetting.PATH_SELECTED, onProjectPathChanged);
			}
			
			newProjectSourcePathSetting.visible = _isProjectFromExistingSource;
			/*newProjectNameSetting.isEditable = newProjectPathSetting.isEditable = !_isProjectFromExistingSource;
			if (newProjectTypeSetting) newProjectTypeSetting.isEditable = !_isProjectFromExistingSource;*/
		}
		
		public function set projectTemplateType(value:String):void
		{
			_projectTemplateType = value;
		}
		public function get projectTemplateType():String
		{
			return _projectTemplateType;
		}
		
		private function createAS3Project(event:NewProjectEvent):void
		{
			// Only template for those we can handle
			if (event.projectFileEnding != "as3proj") return;
			
			cookie = SharedObject.getLocal("moonshine-ide-local");
			//Read recent project path from shared object
			
			// if opened by Open project, event.settingsFile will be false
			// and event.templateDir will be open folder location
			isOpenProjectCall = !event.settingsFile;
			
			project = isOpenProjectCall ? new AS3ProjectVO(event.templateDir, null, false) : FlashDevelopImporter.parse(event.settingsFile, null, null, false);
			
			if (cookie.data.hasOwnProperty('recentProjectPath'))
			{
				model.recentSaveProjectPath.source = cookie.data.recentProjectPath;
			}
			else
			{
				project.folderLocation = new FileLocation(File.documentsDirectory.nativePath);
				if (!model.recentSaveProjectPath.contains(project.folderLocation.fileBridge.nativePath)) model.recentSaveProjectPath.addItem(project.folderLocation.fileBridge.nativePath);
			}
			
			// remove any ( or ) stuff
			if (!isOpenProjectCall)
			{
				var tempName: String = event.templateDir.fileBridge.name.substr(0, event.templateDir.fileBridge.name.indexOf("("));
				if (event.templateDir.fileBridge.name.indexOf("FlexJS") != -1) project.projectName = "NewFlexJSBrowserProject";
				else project.projectName = "New"+tempName;
			}
			
			if (isOpenProjectCall)
			{
				if (!model.recentSaveProjectPath.contains(event.templateDir.fileBridge.nativePath)) model.recentSaveProjectPath.addItem(event.templateDir.fileBridge.nativePath);
				project.projectName = "ExternalProject";
				project.isProjectFromExistingSource = true;
			}
				
			project.folderLocation = new FileLocation(model.recentSaveProjectPath.source[model.recentSaveProjectPath.length - 1]);
			
			var settingsView:SettingsView = new SettingsView();
			settingsView.Width = 150;
			settingsView.defaultSaveLabel = "Create";
			settingsView.isNewProjectSettings = true;
			
			settingsView.addCategory("");
			// Remove spaces from project name
			project.projectName = project.projectName.replace(/ /g, "");
			
			var nvps:Vector.<NameValuePair> = Vector.<NameValuePair>([
				new NameValuePair("AIR", AS3ProjectPlugin.AS3PROJ_AS_AIR),
				new NameValuePair("Web", AS3ProjectPlugin.AS3PROJ_AS_WEB)
			]);
			
			newProjectNameSetting = new StringSetting(project, 'projectName', 'Project name', 'a-zA-Z0-9._');
			newProjectPathSetting = new PathSetting(project, 'folderPath', 'Project directory', true, null, false, true);
			newProjectSourcePathSetting = new NewProjectSourcePathListSetting(project, "projectWithExistingSourcePaths", "Main source folder");
			newProjectSourcePathSetting.visible = project.isProjectFromExistingSource;
			if (isOpenProjectCall) isProjectFromExistingSource = project.isProjectFromExistingSource;
			
			var settings:SettingsWrapper = new SettingsWrapper("Name & Location", Vector.<ISetting>([
				new StaticLabelSetting('New '+ event.templateDir.fileBridge.name),
				newProjectNameSetting, // No space input either plx
				newProjectPathSetting,
				new BooleanSetting(this, "isProjectFromExistingSource", "Project with existing source", true),
				newProjectSourcePathSetting
			]));
			
			if (event.templateDir.fileBridge.name.indexOf("Feathers") != -1) isFeathersProject = true;
			if (event.templateDir.fileBridge.name.indexOf("Actionscript Project") != -1)
			{
				isActionScriptProject = true;
				newProjectTypeSetting = new MultiOptionSetting(this, "activeType", "Select project type", nvps);
				settings.getSettingsList().splice(3, 0, newProjectTypeSetting);
			}
			else if (event.templateDir.fileBridge.name.indexOf("Mobile Project") != -1)
			{
				isMobileProject = true;
			}
			else
			{
				isActionScriptProject = false;
			}
			
			if (isOpenProjectCall)
			{
				settings.getSettingsList().splice(3, 0, new ListSetting(this, "projectTemplateType", "Select Template Type", allProjectTemplates, "title"));
			}
			
			settingsView.addEventListener(SettingsView.EVENT_SAVE, createSave);
			settingsView.addEventListener(SettingsView.EVENT_CLOSE, createClose);
			settingsView.addSetting(settings, "");
			
			settingsView.label = "New Project";
			settingsView.associatedData = project;
			
			GlobalEventDispatcher.getInstance().dispatchEvent(
				new AddTabEvent(settingsView)
			);
			
			templateLookup[project] = event.templateDir;
		}
		
		private function swap(fromIndex:int, toIndex:int,myArray:Array):void
		{
			var temp:* = myArray[toIndex];
			myArray[toIndex] = myArray[fromIndex];
			myArray[fromIndex] = temp;	
		}
		
		//--------------------------------------------------------------------------
		//
		//  PRIVATE LISTENERS
		//
		//--------------------------------------------------------------------------
		
		private function onProjectPathChanged(event:Event):void
		{
			project.projectFolder = null;
			project.folderLocation = new FileLocation(newProjectPathSetting.stringValue);
			newProjectSourcePathSetting.project = project;
		}
		
		private function createClose(event:Event):void
		{
			var settings:SettingsView = event.target as SettingsView;
			
			settings.removeEventListener(SettingsView.EVENT_CLOSE, createClose);
			settings.removeEventListener(SettingsView.EVENT_SAVE, createSave);
			newProjectPathSetting.removeEventListener(PathSetting.PATH_SELECTED, onProjectPathChanged);
			
			delete templateLookup[settings.associatedData];
			
			GlobalEventDispatcher.getInstance().dispatchEvent(
				new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, event.target as DisplayObject)
			);
		}
		
		private function createSave(event:Event):void
		{
			var view:SettingsView = event.target as SettingsView;
			var pvo:AS3ProjectVO = view.associatedData as AS3ProjectVO;
			var targetFolder:FileLocation = pvo.folderLocation;
			var comparePath:Boolean=false;
			
			//save  project path in shared object
			cookie = SharedObject.getLocal("moonshine-ide-local");
			var tmpParent:FileLocation;
			if (_isProjectFromExistingSource)
			{
				var tmpIndex:int = model.recentSaveProjectPath.getItemIndex(pvo.folderLocation.fileBridge.nativePath);
				if (tmpIndex != -1) model.recentSaveProjectPath.removeItemAt(tmpIndex);
				tmpParent = pvo.folderLocation.fileBridge.parent;
			}
			else
			{
				tmpParent = pvo.folderLocation;
			}
			if (!model.recentSaveProjectPath.contains(tmpParent.fileBridge.nativePath)) model.recentSaveProjectPath.addItem(tmpParent.fileBridge.nativePath);
			cookie.data["recentProjectPath"] = model.recentSaveProjectPath.source;
			cookie.flush();
			
			pvo = createFileSystemBeforeSave(pvo);
			
			if (!_isProjectFromExistingSource) targetFolder = targetFolder.resolvePath(pvo.projectName);
			
			GlobalEventDispatcher.getInstance().dispatchEvent(
				new ProjectEvent(ProjectEvent.ADD_PROJECT, pvo)
			);
			
			// Close settings view
			createClose(event);
			// Open main file for editing
			GlobalEventDispatcher.getInstance().dispatchEvent( 
				new OpenFileEvent(OpenFileEvent.OPEN_FILE, pvo.targets[0])
			);
		}
		
		private function createFileSystemBeforeSave(pvo:AS3ProjectVO):AS3ProjectVO
		{
			// in case of create new project through Open Project option
			// we'll need to get the template project directory by it's name
			if (isOpenProjectCall && projectTemplateType)
			{
				for each (var i:TemplateVO in allProjectTemplates)
				{
					if (i.title == projectTemplateType)
					{
						if (i.title.indexOf("Feathers") != -1) isFeathersProject = true;
						if (i.title.indexOf("Actionscript Project") != -1) isActionScriptProject = true;
						else if (i.title.indexOf("Mobile Project") != -1) isMobileProject = true;
						
						var tmpLocation:FileLocation = pvo.folderLocation;
						var tmpName:String = pvo.projectName;
						var tmpExistingSource:Vector.<FileLocation> = pvo.projectWithExistingSourcePaths;
						var tmpIsExistingProjectSource:Boolean = pvo.isProjectFromExistingSource;
						templateLookup[pvo] = i.file;
						pvo = FlashDevelopImporter.parse(i.file.fileBridge.resolvePath("$Settings.as3proj.template"));
						pvo.folderLocation = tmpLocation;
						pvo.projectName = tmpName;
						pvo.projectWithExistingSourcePaths = tmpExistingSource;
						pvo.isProjectFromExistingSource = tmpIsExistingProjectSource;
						break;
					}
				}
			}
			
			var templateDir:FileLocation = templateLookup[pvo];
			var projectName:String = pvo.projectName;
			var sourceFile:String = _isProjectFromExistingSource ? pvo.projectWithExistingSourcePaths[1].fileBridge.name.split(".")[0] : pvo.projectName;
			var sourceFileWithExtension:String = _isProjectFromExistingSource ? pvo.projectWithExistingSourcePaths[1].fileBridge.name : pvo.projectName + ((isActionScriptProject || isFeathersProject) ? ".as" : ".mxml");
			var sourcePath:String = _isProjectFromExistingSource ? pvo.folderLocation.fileBridge.getRelativePath(pvo.projectWithExistingSourcePaths[0]) : "src";
			var targetFolder:FileLocation = pvo.folderLocation;
			
			var movieVersion:String = "10.0";
			// lets load the target flash/air player version
			// since swf and air player both versioning same now,
			// we can load anyone's config file
			movieVersion = SWFOutputVO.getSDKSWFVersion().toString()+".0";
			
			// Create project root directory
			if (!_isProjectFromExistingSource)
			{
				targetFolder = targetFolder.resolvePath(projectName);
				targetFolder.fileBridge.createDirectory();
			}
			
			// Time to do the templating thing!
			var th:TemplatingHelper = new TemplatingHelper();
			th.isProjectFromExistingSource = _isProjectFromExistingSource;
			th.templatingData["$ProjectName"] = projectName;
			
			var pattern:RegExp = new RegExp(/(_)/g);
			th.templatingData["$ProjectID"] = projectName.replace(pattern, "");
			th.templatingData["$SourcePath"] = sourcePath;
			th.templatingData["$SourceFile"] = sourcePath + File.separator + sourceFileWithExtension;
			th.templatingData["$SourceNameOnly"] = sourceFile;
			th.templatingData["$ProjectSWF"] = sourceFile +".swf";
			th.templatingData["$ProjectFile"] = sourceFileWithExtension;
			th.templatingData["$DesktopDescriptor"] = sourceFile;
			th.templatingData["$Settings"] = projectName;
			th.templatingData["$Certificate"] = projectName +"Certificate";
			th.templatingData["$Password"] = projectName +"Certificate";
			th.templatingData["$FlexHome"] = (IDEModel.getInstance().defaultSDK) ? IDEModel.getInstance().defaultSDK.fileBridge.nativePath : "";
			th.templatingData["$MovieVersion"] = movieVersion;
			th.templatingData["${flexlib}"] = (IDEModel.getInstance().defaultSDK) ? IDEModel.getInstance().defaultSDK.fileBridge.nativePath : "${SDK_PATH}";
			th.projectTemplate(templateDir, targetFolder);
			
			// If this an ActionScript Project then we need to copy selective file/folders for web or desktop
			var descriptorFile:FileLocation;
			if (isActionScriptProject || pvo.air || isMobileProject)
			{
				if (activeType == AS3ProjectPlugin.AS3PROJ_AS_AIR)
				{
					// build folder modification
					th.projectTemplate(templateDir.resolvePath("build_air"), targetFolder.resolvePath("build"));
					descriptorFile = targetFolder.resolvePath("build/"+ sourceFile +"-app.xml");
					try
					{
						descriptorFile.fileBridge.moveTo(targetFolder.resolvePath(sourcePath + File.separator + sourceFile +"-app.xml"), true);
					}
					catch(e:Error)
					{
						descriptorFile.fileBridge.moveToAsync(targetFolder.resolvePath(sourcePath + File.separator + sourceFile +"-app.xml"), true);
					}
				}
				else
				{
					th.projectTemplate(templateDir.resolvePath("build_web"), targetFolder.resolvePath("build"));
					th.projectTemplate(templateDir.resolvePath("bin-debug_web"), targetFolder.resolvePath("bin-debug"));
				}
				
				// we also needs to delete unnecessary folders
				var folderToDelete1:FileLocation = targetFolder.resolvePath("build_air");
				var folderToDelete2:FileLocation = targetFolder.resolvePath("build_web");
				var folderToDelete3:FileLocation = targetFolder.resolvePath("bin-debug_web");
				try
				{
					folderToDelete1.fileBridge.deleteDirectory(true);
					if (isActionScriptProject)
					{
						folderToDelete2.fileBridge.deleteDirectory(true);
						folderToDelete3.fileBridge.deleteDirectory(true);
					}
				} catch (e:Error)
				{
					folderToDelete1.fileBridge.deleteDirectoryAsync(true);
					if (isActionScriptProject)
					{
						folderToDelete2.fileBridge.deleteDirectoryAsync(true);
						folderToDelete3.fileBridge.deleteDirectoryAsync(true);
					}
				}
			}
			
			// creating certificate conditional checks
			if (!descriptorFile || !descriptorFile.fileBridge.exists)
			{
				descriptorFile = targetFolder.resolvePath("application.xml");
				if (!descriptorFile.fileBridge.exists)
				{
					descriptorFile = targetFolder.resolvePath(sourcePath + File.separator + sourceFile +"-app.xml");
				}
			}
			
			if (descriptorFile.fileBridge.exists)
			{
				// lets update $SWFVersion with SWF version now
				var stringOutput:String = descriptorFile.fileBridge.read() as String;
				var firstNamespaceQuote:int = stringOutput.indexOf('"', stringOutput.indexOf("<application xmlns=")) + 1;
				var lastNamespaceQuote:int = stringOutput.indexOf('"', firstNamespaceQuote);
				var currentAIRNamespaceVersion:String = stringOutput.substring(firstNamespaceQuote, lastNamespaceQuote);
				
				stringOutput = stringOutput.replace(currentAIRNamespaceVersion, "http://ns.adobe.com/air/application/"+ movieVersion);
				descriptorFile.fileBridge.save(stringOutput);
			}
			
			// Figure out which one is the settings file
			var settingsFile:FileLocation = targetFolder.resolvePath(projectName+".as3proj");
			
			// Set some stuff to get the paths right
			pvo = FlashDevelopImporter.parse(settingsFile, projectName, (isMobileProject || (isActionScriptProject && activeType == AS3ProjectPlugin.AS3PROJ_AS_AIR)) ? new File(project.folderLocation.fileBridge.nativePath + File.separator + sourcePath + File.separator + sourceFile +"-app.xml") : null);
			pvo.projectName = projectName;
			
			// Write settings
			FlashDevelopExporter.export(pvo, settingsFile);
			
			return pvo;
		}
	}
}