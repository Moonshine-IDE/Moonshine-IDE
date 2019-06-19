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
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	
	import actionScripts.events.AddTabEvent;
	import actionScripts.events.GeneralEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.NewProjectEvent;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.RefreshTreeEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.actionscript.as3project.settings.NewLibraryProjectSetting;
	import actionScripts.plugin.actionscript.as3project.settings.NewProjectSourcePathListSetting;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.actionscript.as3project.vo.LibrarySettingsVO;
	import actionScripts.plugin.groovy.grailsproject.exporter.GrailsExporter;
	import actionScripts.plugin.groovy.grailsproject.vo.GrailsProjectVO;
	import actionScripts.plugin.java.javaproject.exporter.JavaExporter;
	import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
	import actionScripts.plugin.project.ProjectTemplateType;
	import actionScripts.plugin.project.ProjectType;
	import actionScripts.plugin.project.vo.ProjectShellVO;
	import actionScripts.plugin.settings.SettingsView;
	import actionScripts.plugin.settings.vo.AbstractSetting;
	import actionScripts.plugin.settings.vo.BooleanSetting;
	import actionScripts.plugin.settings.vo.DropDownListSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.MultiOptionSetting;
	import actionScripts.plugin.settings.vo.NameValuePair;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	import actionScripts.plugin.settings.vo.StaticLabelSetting;
	import actionScripts.plugin.settings.vo.StringSetting;
	import actionScripts.plugin.templating.TemplatingHelper;
	import actionScripts.plugins.as3project.exporter.FlashDevelopExporter;
	import actionScripts.plugins.as3project.importer.FlashBuilderImporter;
	import actionScripts.plugins.as3project.importer.FlashDevelopImporter;
	import actionScripts.ui.menu.vo.ProjectMenuTypes;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.utils.OSXBookmarkerNotifiers;
	import actionScripts.utils.SDKUtils;
	import actionScripts.utils.SharedObjectConst;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.SDKReferenceVO;
	import actionScripts.valueObjects.SDKTypes;
	import actionScripts.valueObjects.TemplateVO;
	import actionScripts.plugin.haxe.hxproject.exporter.HaxeExporter;
	import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;
	
    public class CreateProject
	{
		public var activeType:uint = ProjectType.AS3PROJ_AS_AIR;
		
		private var newProjectWithExistingSourcePathSetting:NewProjectSourcePathListSetting;
		private var newLibrarySetting:NewLibraryProjectSetting;
		private var newProjectNameSetting:StringSetting;
		private var newProjectPathSetting:PathSetting;
		private var newProjectTypeSetting:MultiOptionSetting;
		private var customSdkPathSetting:PathSetting;
		private var projectTemplateTypeSetting:DropDownListSetting;
		private var projectWithExistingSourceSetting:BooleanSetting;

		private var cookie:SharedObject;
		private var templateLookup:Object = {};
		private var project:Object;
		private var model:IDEModel = IDEModel.getInstance();
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		
		private var isActionScriptProject:Boolean;
		private var isMobileProject:Boolean;
		private var isOpenProjectCall:Boolean;
		private var isFeathersProject:Boolean;
		private var isVisualEditorProject:Boolean;
		private var isAway3DProject:Boolean;
		private var isLibraryProject:Boolean;
		private var isCustomTemplateProject:Boolean;
		private var isFlexJSRoyalProject:Boolean;
		private var isJavaProject:Boolean;
		private var isGrailsProject:Boolean;
		private var isHaxeProject:Boolean;
		private var isInvalidToSave:Boolean;
		private var librarySettingObject:LibrarySettingsVO;
		private var filePathReg:RegExp = ConstantsCoreVO.IS_MACOS ? 
			new RegExp("^(?:[\w]\:|.*/)([^\|/]*)$", "i") : new RegExp(/^(?:[\w]\:|\\)(\\[a-z_\-\s0-9\.]+)+$/i);
		
		private var _allProjectTemplates:ArrayCollection;
		private var _isProjectFromExistingSource:Boolean;
		private var _projectTemplateType:String;
		private var _customSdk:String;
		private var _currentCauseToBeInvalid:String;

		private var projectFolder:FileLocation;

		public function CreateProject(event:NewProjectEvent)
		{

			// if opened by Open project, event.settingsFile will be false
			// and event.templateDir will be open folder location
			isOpenProjectCall = !event.settingsFile;

			if (isOpenProjectCall)
			{
				projectFolder = event.templateDir;
			}
			// update template path to custom in case
			// the original template have modified
			var modifiedTemplate:FileLocation = TemplatingHelper.getCustomFileFor(event.templateDir);
			if (modifiedTemplate.fileBridge.exists)
			{
				event.templateDir = modifiedTemplate;
				if (event.settingsFile)
				{
					event.settingsFile = modifiedTemplate.resolvePath(event.settingsFile.fileBridge.name);
				}
			}
			
			if (!allProjectTemplates)
			{
				_allProjectTemplates = new ArrayCollection();
				_allProjectTemplates.addAll(ConstantsCoreVO.TEMPLATES_PROJECTS);
				_allProjectTemplates.addAll(ConstantsCoreVO.TEMPLATES_PROJECTS_SPECIALS);
			}
			
			// determine if a given project is custom or Moonshine default
			var customTemplateDirectory:FileLocation = model.fileCore.resolveApplicationStorageDirectoryPath("templates/projects");
			if (event.templateDir.fileBridge.nativePath.indexOf(customTemplateDirectory.fileBridge.nativePath) != -1)
			{
				isCustomTemplateProject = true;
			}

            projectTemplateType = event.templateDir.name;
			if (isCustomTemplateProject)
			{
				createCustomOrAway3DProject(event);
			}
			else if (isAllowedTemplateFile(event.projectFileEnding))
			{
				createAS3Project(event);
            }
		}
		
		public function get allProjectTemplates():ArrayCollection
		{
			if (!isOpenProjectCall)
			{
				return _allProjectTemplates;
			}

			if (_allProjectTemplates)
			{
				return new ArrayCollection(_allProjectTemplates.source.filter(function(item:TemplateVO, index:int, arr:Array):Boolean {
					return item.title != ProjectTemplateType.LIBRARY_PROJECT
				}));
			}

			return null;
		}
		
		public function get isProjectFromExistingSource():Boolean
		{
			return _isProjectFromExistingSource;
		}
		
		public function set isProjectFromExistingSource(value:Boolean):void
		{
			_isProjectFromExistingSource = project.isProjectFromExistingSource = value;
			onProjectPathChanged(null, false);

			if (newProjectWithExistingSourcePathSetting)
			{
				newProjectWithExistingSourcePathSetting.editable = value;
			}

			// lets scroll-up the project creation dialog
			// so user can see changed project path clearly - if
			// s/he is working in a shorter frame where project path
			// may cut-off in displaying frame
			dispatcher.dispatchEvent(new GeneralEvent(GeneralEvent.SCROLL_TO_TOP));
		}
		
		public function set projectTemplateType(value:String):void
		{
			if (_projectTemplateType != value)
			{
				_projectTemplateType = value;

				setProjectType(projectTemplateType);
			}
		}
		public function get projectTemplateType():String
		{
			return _projectTemplateType;
		}

		public function get customSdk():String
		{
			return _customSdk;
		}

		public function set customSdk(value:String):void
		{
			if (filePathReg.test(value))
			{
				_customSdk = value;
			}
		}
		
		private function createAS3Project(event:NewProjectEvent):void
		{
			var lastSelectedProjectPath:String;

			setAutoSuggestSDKbyType();
			
			CONFIG::OSX
				{
					if (OSXBookmarkerNotifiers.availableBookmarkedPaths == "") OSXBookmarkerNotifiers.removeFlashCookies();
				}
			
            cookie = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);
			//Read recent project path from shared object

			if (isOpenProjectCall)
			{
				project = new ProjectShellVO(projectFolder ? projectFolder : event.templateDir, null);
			}
			else
			{
				project = FlashDevelopImporter.parse(event.settingsFile, null, null, false);
			}

			project.isLibraryProject = isLibraryProject;

			if (cookie.data.hasOwnProperty('recentProjectPath'))
			{
				model.recentSaveProjectPath.source = cookie.data.recentProjectPath;
				if (cookie.data.hasOwnProperty('lastSelectedProjectPath'))
				{
					lastSelectedProjectPath = cookie.data.lastSelectedProjectPath;
				}
			}
			else if (!isOpenProjectCall)
			{
				project.folderLocation = new FileLocation(File.documentsDirectory.nativePath);
				if (!model.recentSaveProjectPath.contains(project.folderLocation.fileBridge.nativePath)) 
				{
					model.recentSaveProjectPath.addItem(project.folderLocation.fileBridge.nativePath);
				}
			}
			
			// remove any ( or ) stuff
			if (!isOpenProjectCall)
			{
				var tempName: String = (event.templateDir.fileBridge.name.indexOf("(") != -1) ? event.templateDir.fileBridge.name.substr(0, event.templateDir.fileBridge.name.indexOf("(")) : event.templateDir.fileBridge.name;
				if (isFlexJSRoyalProject)
				{
					project.projectName = "NewJavaScriptBrowserProject";
                }
				else
				{
					project.projectName = event.exportProject ? event.exportProject.name + "_exported" : "New"+tempName;
                }
			}
			
			if (isOpenProjectCall)
			{
				if (!model.recentSaveProjectPath.contains(projectFolder.fileBridge.nativePath))
				{
					model.recentSaveProjectPath.addItem(projectFolder.fileBridge.nativePath);
                }
				project.projectName = "ExternalProject";
				project.isProjectFromExistingSource = true;
			}
			else
			{
				var tmpProjectSourcePath:String = (lastSelectedProjectPath && model.recentSaveProjectPath.getItemIndex(lastSelectedProjectPath) != -1) ? lastSelectedProjectPath : model.recentSaveProjectPath.source[model.recentSaveProjectPath.length - 1];
				project.folderLocation = new FileLocation(tmpProjectSourcePath);
			}
			
			var settingsView:SettingsView = new SettingsView();
			settingsView.exportProject = event.exportProject;
			settingsView.Width = 150;
			settingsView.defaultSaveLabel = event.isExport ? "Export" : "Create";
			settingsView.isNewProjectSettings = true;
			
			settingsView.addCategory("");
			// Remove spaces from project name
			project.projectName = project.projectName.replace(/ /g, "");
			
			var nvps:Vector.<NameValuePair> = Vector.<NameValuePair>([
				new NameValuePair("AIR", ProjectType.AS3PROJ_AS_AIR),
				new NameValuePair("Web", ProjectType.AS3PROJ_AS_WEB),
			    new NameValuePair("Visual Editor", ProjectType.VISUAL_EDITOR)
			]);

			var settings:SettingsWrapper = getProjectSettings(project, event);

			if (newProjectWithExistingSourcePathSetting)
            {
                if (isOpenProjectCall)
				{
					isProjectFromExistingSource = project.isProjectFromExistingSource;
				}
                newProjectWithExistingSourcePathSetting.editable = project.isProjectFromExistingSource;
            }
			
            if (isActionScriptProject)
			{
				isActionScriptProject = true;
				newProjectTypeSetting = new MultiOptionSetting(this, "activeType", "Select project type", nvps);
				settings.getSettingsList().splice(4, 0, newProjectTypeSetting);
			}

			if (isOpenProjectCall)
			{
				projectTemplateTypeSetting = new DropDownListSetting(this, "projectTemplateType", "Select Template Type", allProjectTemplates, "title");
				projectTemplateTypeSetting.addEventListener(Event.CHANGE, onProjectTemplateTypeChange);

				settings.getSettingsList().splice(3, 0, projectTemplateTypeSetting);
			}
			else if (isFlexJSRoyalProject)
			{
				projectTemplateTypeSetting = new DropDownListSetting(this, "projectTemplateType", "Select Template Type", ConstantsCoreVO.TEMPLATES_PROJECTS_ROYALE, "title");
				projectTemplateTypeSetting.addEventListener(Event.CHANGE, onProjectTemplateTypeChange);

				settings.getSettingsList().splice(3, 0, projectTemplateTypeSetting);
			}
			else if (isLibraryProject)
			{
				newLibrarySetting = new NewLibraryProjectSetting(this, "librarySettingObject");
				settings.getSettingsList().splice(3, 0, newLibrarySetting);
			}

			settingsView.addEventListener(SettingsView.EVENT_SAVE, onCreateProjectSave);
			settingsView.addEventListener(SettingsView.EVENT_CLOSE, onCreateProjectClose);
			settingsView.addSetting(settings, "");
			
			settingsView.label = "New Project";
			settingsView.associatedData = project;
			
			dispatcher.dispatchEvent(
				new AddTabEvent(settingsView)
			);
			
			templateLookup[project] = event.templateDir;
		}

		private function createCustomOrAway3DProject(event:NewProjectEvent):void
		{
			var lastSelectedProjectPath:String;
			var tempName: String = (event.templateDir.fileBridge.name.indexOf("(") != -1) ? event.templateDir.fileBridge.name.substr(0, event.templateDir.fileBridge.name.indexOf("(")) : event.templateDir.fileBridge.name;
			tempName = tempName.replace(/ /g, "");
			
			project = new AS3ProjectVO(model.fileCore.resolveDocumentDirectoryPath(), tempName, false);
			CONFIG::OSX
				{
					if (OSXBookmarkerNotifiers.availableBookmarkedPaths == "") OSXBookmarkerNotifiers.removeFlashCookies();
				}
				
			cookie = SharedObject.getLocal("moonshine-ide-local");
			
			if (cookie.data.hasOwnProperty('recentProjectPath'))
			{
				model.recentSaveProjectPath.source = cookie.data.recentProjectPath;
				if (cookie.data.hasOwnProperty('lastSelectedProjectPath')) lastSelectedProjectPath = cookie.data.lastSelectedProjectPath;
			}
			else
			{
				if (!model.recentSaveProjectPath.contains(project.folderLocation.fileBridge.nativePath)) model.recentSaveProjectPath.addItem(project.folderLocation.fileBridge.nativePath);
			}
			
			var tmpProjectSourcePath:String = (lastSelectedProjectPath && model.recentSaveProjectPath.getItemIndex(lastSelectedProjectPath) != -1) ? lastSelectedProjectPath : model.recentSaveProjectPath.source[model.recentSaveProjectPath.length - 1];
			project.folderLocation = new FileLocation(tmpProjectSourcePath);
			
			var settingsView:SettingsView = new SettingsView();
			settingsView.Width = 150;
			settingsView.defaultSaveLabel = "Create";
			settingsView.isNewProjectSettings = true;
			
			settingsView.addCategory("");
			
			var settings:SettingsWrapper = getProjectSettings(project, event);
			
			settingsView.addEventListener(SettingsView.EVENT_SAVE, onCreateProjectSave);
			settingsView.addEventListener(SettingsView.EVENT_CLOSE, onCreateProjectClose);
			settingsView.addSetting(settings, "");
			
			settingsView.label = "New Project";
			settingsView.associatedData = project;
			
			dispatcher.dispatchEvent(
				new AddTabEvent(settingsView)
			);
			
			templateLookup[project] = event.templateDir;
		}

        private function isAllowedTemplateFile(projectFileExtension:String):Boolean
        {
            return projectFileExtension != "as3proj" || projectFileExtension != "veditorproj" || !projectFileExtension;
        }

		private function getProjectSettings(project:Object, eventObject:NewProjectEvent):SettingsWrapper
		{
			var historyPaths:ArrayCollection = ObjectUtil.copy(model.recentSaveProjectPath) as ArrayCollection;
			if (historyPaths.length == 0)
			{
				historyPaths.addItem(project.folderPath);
			}
			
            newProjectNameSetting = new StringSetting(project, 'projectName', 'Project name', '^ ~`!@#$%\\^&*()\\-+=[{]}\\\\|:;\'",<.>/?');
			newProjectPathSetting = new PathSetting(project, 'folderPath', 'Parent directory', true, null, false, true);
			newProjectPathSetting.dropdownListItems = historyPaths;
			newProjectPathSetting.addEventListener(AbstractSetting.PATH_SELECTED, onProjectPathChanged);
			newProjectNameSetting.addEventListener(StringSetting.VALUE_UPDATED, onProjectNameChanged);

			if (eventObject.isExport)
			{
				//newProjectNameSetting.isEditable = false;
                return new SettingsWrapper("Name & Location", Vector.<ISetting>([
                    new StaticLabelSetting('New ' + eventObject.templateDir.fileBridge.name),
                    newProjectNameSetting, // No space input either plx
                    newProjectPathSetting
                ]));
			}

			if (isCustomTemplateProject)
            {
                return new SettingsWrapper("Name & Location", Vector.<ISetting>([
                    new StaticLabelSetting(isCustomTemplateProject ? 'New ' + eventObject.templateDir.fileBridge.name : 'New Away3D Project'),
                    newProjectNameSetting,
                    newProjectPathSetting
                ]));
            }
			
            if (project.isVisualEditorProject && !eventObject.isExport)
            {
                return new SettingsWrapper("Name & Location", Vector.<ISetting>([
                    new StaticLabelSetting('New ' + eventObject.templateDir.fileBridge.name),
                    newProjectNameSetting, // No space input either plx
                    newProjectPathSetting,
					new DropDownListSetting(this, "projectTemplateType", "Select Template Type", new ArrayCollection([ProjectTemplateType.VISUAL_EDITOR_FLEX, ProjectTemplateType.VISUAL_EDITOR_PRIMEFACES]))
                ]));
            }

			customSdkPathSetting = new PathSetting(this,'customSdk', 'Apache Flex®, Apache Royale® or Feathers SDK', true, customSdk, true);
			customSdkPathSetting.addEventListener(AbstractSetting.PATH_SELECTED, onCustomSDKPathChanged, false, 0, true);
			projectWithExistingSourceSetting = new BooleanSetting(this, "isProjectFromExistingSource", "Project with existing source", true);

			var settingsProject:Vector.<ISetting> = Vector.<ISetting>([
				new StaticLabelSetting('New '+ eventObject.templateDir.fileBridge.name),
				newProjectNameSetting, // No space input either plx
				newProjectPathSetting,
				customSdkPathSetting,
				projectWithExistingSourceSetting
			]);

			newProjectWithExistingSourcePathSetting = new NewProjectSourcePathListSetting(project,
					"projectWithExistingSourcePaths", "Main source folder");
			settingsProject.push(newProjectWithExistingSourcePathSetting);

			return new SettingsWrapper("Name & Location", settingsProject);
		}
		
		private function onCustomSDKPathChanged(event:Event):void
		{
			var sdkReference:SDKReferenceVO = SDKUtils.getSDKFromSavedList(customSdkPathSetting.stringValue);
			if (sdkReference)
			{
				customSdk = sdkReference.path;
			}
		}

		private function checkIfProjectDirectory(value:FileLocation):void
		{
			var tmpFile:FileLocation = FlashDevelopImporter.test(value.fileBridge.getFile as File);
			if (!tmpFile) tmpFile = FlashBuilderImporter.test(value.fileBridge.getFile as File);
			if (!tmpFile && !isProjectFromExistingSource && value.fileBridge.exists) tmpFile = value;
			
			if (tmpFile) 
			{
				newProjectPathSetting.setMessage((_currentCauseToBeInvalid = "Project can not be created to an existing project directory:\n"+ value.fileBridge.nativePath), AbstractSetting.MESSAGE_CRITICAL);
			}
			else if (isProjectFromExistingSource)
			{
				newProjectPathSetting.setMessage("(Note) Project with existing source directory is:\n"+ value.fileBridge.nativePath, AbstractSetting.MESSAGE_IMPORTANT);
			}
			else
			{
				newProjectPathSetting.setMessage(value.fileBridge.nativePath);
			}
			
			if (newProjectPathSetting.stringValue == "") 
			{
				isInvalidToSave = true;
				_currentCauseToBeInvalid = 'Unable to access Project Directory:\n'+ value.fileBridge.nativePath +'\nPlease try to create the project again and use the "Change" link to open the target directory again.';
			}
			else
			{
				isInvalidToSave = tmpFile ? true : false;
			}
		}

		//--------------------------------------------------------------------------
		//
		//  PRIVATE LISTENERS
		//
		//--------------------------------------------------------------------------
		
		private function onProjectPathChanged(event:Event, makeNull:Boolean=true):void
		{
			if (makeNull) project.projectFolder = null;
			project.folderLocation = new FileLocation(newProjectPathSetting.stringValue);
			if (isProjectFromExistingSource)
			{
				project.projectName = newProjectNameSetting.stringValue;
				if (newProjectWithExistingSourcePathSetting)
				{
					newProjectWithExistingSourcePathSetting.project = project;
				}

				newProjectPathSetting.label = "Existing Project Directory";
				checkIfProjectDirectory(project.folderLocation);
			}
			else
			{
				newProjectPathSetting.label = "Parent Directory";
				checkIfProjectDirectory(project.folderLocation.resolvePath(newProjectNameSetting.stringValue));
			}
		}
		
		private function onProjectNameChanged(event:Event):void
		{
			if (!isProjectFromExistingSource)
			{
				checkIfProjectDirectory(project.folderLocation.resolvePath(newProjectNameSetting.stringValue));
			}
		}
		
		private function onCreateProjectClose(event:Event):void
		{
			var settings:SettingsView = event.target as SettingsView;
			
			settings.removeEventListener(SettingsView.EVENT_CLOSE, onCreateProjectClose);
			settings.removeEventListener(SettingsView.EVENT_SAVE, onCreateProjectSave);
			if (newProjectPathSetting) 
			{
				newProjectPathSetting.removeEventListener(AbstractSetting.PATH_SELECTED, onProjectPathChanged);
				newProjectNameSetting.removeEventListener(StringSetting.VALUE_UPDATED, onProjectNameChanged);
			}

			if (projectTemplateTypeSetting)
			{
				projectTemplateTypeSetting.removeEventListener(Event.CHANGE, onProjectTemplateTypeChange);
			}
			
			if (customSdkPathSetting)
			{
				customSdkPathSetting.removeEventListener(AbstractSetting.PATH_SELECTED, onCustomSDKPathChanged);
			}

			delete templateLookup[settings.associatedData];
			
			dispatcher.dispatchEvent(
				new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, event.target as DisplayObject)
			);
		}

		private function onProjectTemplateTypeChange(event:Event):void
		{
			projectTemplateTypeSetting.commitChanges();
			
			var isSourceSettingsAvailable:Boolean = ((projectTemplateType.indexOf(ProjectTemplateType.JAVA) == -1) && 
														(projectTemplateType.indexOf(ProjectTemplateType.GRAILS) == -1));
			if (projectWithExistingSourceSetting)
			{
				customSdkPathSetting.editable = projectWithExistingSourceSetting.editable = isSourceSettingsAvailable;
			}
			if (newProjectWithExistingSourcePathSetting)
			{
				customSdkPathSetting.editable = newProjectWithExistingSourcePathSetting.editable = isSourceSettingsAvailable;
			}
		}

		private function onCreateProjectSave(event:Event):void
		{
			if (isInvalidToSave) 
			{
				throwError();
				return;
			}
			
			var view:SettingsView = event.target as SettingsView;
			var project:Object = view.associatedData;
			//var targetFolder:FileLocation = project.folderLocation = _isProjectFromExistingSource ? project.folderLocation.resolvePath(project.name) : project.folderLocation;
			var targetFolder:FileLocation = project.folderLocation;

			//save  project path in shared object
			cookie = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);
			var tmpParent:FileLocation;
			if (isProjectFromExistingSource && !isJavaProject && !isGrailsProject)
			{
				// validate if all requirement supplied
				if (newProjectWithExistingSourcePathSetting.stringValue == "")
				{
					event.target.removeEventListener(SettingsView.EVENT_CLOSE, onCreateProjectClose);
					var timeoutValue:uint = setTimeout(function():void
					{
						event.target.addEventListener(SettingsView.EVENT_CLOSE, onCreateProjectClose);
						clearTimeout(timeoutValue);
					}, 500);
					
					Alert.show(isLibraryProject ? "Please provide the source folder location to proceed." : "Please provide the source folder and application file location to proceed.", "Error!");
					return;
				}
				
				var tmpIndex:int = model.recentSaveProjectPath.getItemIndex(project.folderLocation.fileBridge.nativePath);
				if (tmpIndex != -1) model.recentSaveProjectPath.removeItemAt(tmpIndex);
				tmpParent = project.folderLocation.fileBridge.parent;
			}
			else
			{
				tmpParent = project.folderLocation;
			}

			if (!model.recentSaveProjectPath.contains(tmpParent.fileBridge.nativePath))
			{
				model.recentSaveProjectPath.addItem(tmpParent.fileBridge.nativePath);
            }
			
			// don't save this if from a open project call
			if (!isOpenProjectCall && !isProjectFromExistingSource)
			{
				cookie.data["lastSelectedProjectPath"] = project.folderLocation.fileBridge.nativePath;
				cookie.data["recentProjectPath"] = model.recentSaveProjectPath.source;
				cookie.flush();
			}

            project = createFileSystemBeforeSave(project, view.exportProject as AS3ProjectVO);
			if (!project) return;

            if (view.exportProject)
            {
                exportVisualEditorProject(project, view.exportProject as AS3ProjectVO);
            }

            if (!isProjectFromExistingSource) targetFolder = targetFolder.resolvePath(project.projectName);
			
			// Close settings view
			onCreateProjectClose(event);
			
			// Open main file for editing
			dispatcher.dispatchEvent(
				new ProjectEvent(ProjectEvent.ADD_PROJECT, project)
			);
			
			if (!isCustomTemplateProject && !isLibraryProject && !isJavaProject && !isGrailsProject)
			{
				dispatcher.dispatchEvent( 
					new OpenFileEvent(OpenFileEvent.OPEN_FILE, [project.targets[0]], -1, [project.projectFolder])
				);
			}

			if (view.exportProject)
			{
                dispatcher.dispatchEvent(new RefreshTreeEvent(project.folderLocation));
			}
		}

		private function exportVisualEditorProject(project:Object, exportProject:AS3ProjectVO):void
		{
			var mainExportedFile:FileLocation = exportProject.targets[0];
			var mainProjectFile:FileLocation = project.targets[0];

            mainExportedFile.fileBridge.copyTo(mainProjectFile, true);

			var filesForExport:Array = exportProject.sourceFolder.fileBridge.getDirectoryListing();
			var filesForExportCount:int = filesForExport.length;
			for (var i:int = 0; i < filesForExportCount; i++)
			{
				var fileForCopy:File = filesForExport[i];
				if (fileForCopy.name == mainExportedFile.fileBridge.name)
				{
					continue;
				}

				var destinationPath:String = UtilsCore.fixSlashes(project.sourceFolder.fileBridge.getFile.nativePath + "\\" + fileForCopy.name);
				var destination:File = new File(destinationPath);
				fileForCopy.copyTo(destination, true);
			}
		}

		private function createFileSystemBeforeSave(shell:Object, exportProject:AS3ProjectVO = null):Object
		{
			// in case of create new project through Open Project option
			// we'll need to get the template project directory by it's name
			var pvo:Object = getProjectWithTemplate(shell, exportProject);
			var templateDir:FileLocation = templateLookup[pvo];
			var projectName:String = pvo.projectName;
			var sourcePath:String = "src";
			if (!isProjectFromExistingSource && isVisualEditorProject && projectTemplateType == ProjectTemplateType.VISUAL_EDITOR_PRIMEFACES)
			{
				sourcePath = "src/main/webapp";
			}

			var targetFolder:FileLocation = pvo.folderLocation;
			// lets load the target flash/air player version
			// since swf and air player both versioning same now,
			// we can load anyone's config file
            var movieVersion:String = SDKUtils.getSdkSwfMajorVersion().toString()+".0";
			
			// Create project root directory
			if (!isProjectFromExistingSource)
			{
				CONFIG::OSX
					{
						if (!OSXBookmarkerNotifiers.isPathBookmarked(targetFolder.fileBridge.nativePath))
						{
							_currentCauseToBeInvalid = 'Unable to access Parent Directory:\n'+ targetFolder.fileBridge.nativePath +'\nPlease try to create the project again and use the "Change" link to open the target directory again.';
							throwError();
							return null;
						}
					}
				
				targetFolder = targetFolder.resolvePath(projectName);
				targetFolder.fileBridge.createDirectory();
			}

			var th:TemplatingHelper = new TemplatingHelper();
			var sourceFile:String = pvo.projectName;
			var sourceFileWithExtension:String = "";

			if (isProjectFromExistingSource && pvo.projectWithExistingSourcePaths)
			{
				sourcePath = pvo.folderLocation.fileBridge.getRelativePath(pvo.projectWithExistingSourcePaths[0])
			}

			if (isProjectFromExistingSource && !isLibraryProject)
			{
				if(pvo.projectWithExistingSourcePaths)
				{
					sourceFile = pvo.projectWithExistingSourcePaths[1].fileBridge.name.split(".")[0];
					th.templatingData["$SourceFile"] = pvo.projectWithExistingSourcePaths[1].fileBridge.nativePath;
				}
			}
			else if (isActionScriptProject || isFeathersProject || isAway3DProject)
			{
				sourceFileWithExtension = pvo.projectName + ".as";
				th.templatingData["$SourceFile"] = sourceFileWithExtension ? (sourcePath + File.separator + sourceFileWithExtension) : "";
			}
			else if (isLibraryProject)
			{
				// we creates library project without any default created file inside
				sourceFileWithExtension = null;
				th.templatingData["$SourceFile"] = sourceFileWithExtension ? (sourcePath + File.separator + sourceFileWithExtension) : "";
			}
			else if (isVisualEditorProject && projectTemplateType == ProjectTemplateType.VISUAL_EDITOR_PRIMEFACES)
			{
				sourceFileWithExtension = pvo.projectName + ".xhtml";
				th.templatingData["$SourceFile"] = sourceFileWithExtension ? (sourcePath + File.separator + sourceFileWithExtension) : "";
			}
			else
			{
				sourceFileWithExtension = pvo.projectName + ".mxml";
				th.templatingData["$SourceFile"] = sourceFileWithExtension ? (sourcePath + File.separator + sourceFileWithExtension) : "";
			}

			// Time to do the templating thing!
			th.isProjectFromExistingSource = isProjectFromExistingSource;
			th.templatingData["$ProjectName"] = projectName;
			
			var pattern:RegExp = new RegExp(/(_)/g);
			th.templatingData["$ProjectID"] = projectName.replace(pattern, "");
			th.templatingData["$SourcePath"] = sourcePath;
			th.templatingData["$SourceNameOnly"] = sourceFile;
			th.templatingData["$ProjectSWF"] = sourceFile +".swf";
			th.templatingData["$ProjectSWC"] = sourceFile +".swc";
			th.templatingData["$ProjectFile"] = sourceFileWithExtension ? sourceFileWithExtension : "";
			th.templatingData["$DesktopDescriptor"] = sourceFile;
			th.templatingData["$Settings"] = projectName;
			th.templatingData["$Certificate"] = projectName +"Certificate";
			th.templatingData["$Password"] = projectName +"Certificate";
			th.templatingData["$FlexHome"] = model.defaultSDK ? model.defaultSDK.fileBridge.nativePath : "";
			th.templatingData["$MovieVersion"] = movieVersion;
			th.templatingData["$pom"] = "pom";

			var excludeFiles:Array = null;
			if (isJavaProject)
			{
				excludeFiles = [];
				if (pvo.hasPom())
				{
					excludeFiles.push("pom.xml");
				}

				if (pvo.hasGradleBuild())
				{
					excludeFiles.push("build.gradle");
				}
			}

			if (_customSdk)
			{
				th.templatingData["${flexlib}"] = _customSdk;
            }
			else
			{
				th.templatingData["${flexlib}"] = (model.defaultSDK) ? model.defaultSDK.fileBridge.nativePath : "${SDK_PATH}";
            }

            th.projectTemplate(templateDir, targetFolder, excludeFiles);

			// we copy everything from template to target folder 
			// in case of custom project template and terminate
			if (isCustomTemplateProject)
			{
				// re-create the vo so all the requisite fields
				// updated with final target folder path
				pvo = new AS3ProjectVO(targetFolder, pvo.name);
				pvo.classpaths[0] = targetFolder;
				return pvo;
			}

			// If this an ActionScript Project then we need to copy selective file/folders for web or desktop
			var descriptorFileLocation:FileLocation;
			var isAIR:Boolean = templateDir.resolvePath("build_air").fileBridge.exists;
			if (isActionScriptProject || isAIR || isMobileProject)
			{
				if (activeType == ProjectType.AS3PROJ_AS_AIR)
				{
					// build folder modification
					th.projectTemplate(templateDir.resolvePath("build_air"), targetFolder.resolvePath("build"));
					if (isAway3DProject) th.projectTemplate(templateDir.resolvePath("libs"), targetFolder.resolvePath("libs"));
					descriptorFileLocation = targetFolder.resolvePath("build/"+ sourceFile +"-app.xml");
					try
					{
						descriptorFileLocation.fileBridge.moveTo(targetFolder.resolvePath(sourcePath + File.separator + sourceFile +"-app.xml"), true);
					}
					catch(e:Error)
					{
						try
						{
							descriptorFileLocation.fileBridge.moveToAsync(targetFolder.resolvePath(sourcePath + File.separator + sourceFile +"-app.xml"), true);
						}
						catch (e:Error)
						{}
					}
				}
				else
				{
					th.projectTemplate(templateDir.resolvePath("build_web"), targetFolder.resolvePath("build"));
					th.projectTemplate(templateDir.resolvePath("bin-debug_web"), targetFolder.resolvePath("bin-debug"));
					th.projectTemplate(templateDir.resolvePath("html-template_web"), targetFolder.resolvePath("html-template"));
				}
				
				// we also needs to delete unnecessary folders
				var folderToDelete1:FileLocation = targetFolder.resolvePath("build_air");
				var folderToDelete2:FileLocation = targetFolder.resolvePath("build_web");
				var folderToDelete3:FileLocation = targetFolder.resolvePath("bin-debug_web");
				var folderToDelete4:FileLocation = targetFolder.resolvePath("html-template_web");
				var folderToDelete5:FileLocation = targetFolder.resolvePath("build");
				
				if (folderToDelete1.fileBridge.exists) folderToDelete1.fileBridge.deleteDirectory(true);
				if (isActionScriptProject)
				{
					if (folderToDelete2.fileBridge.exists) folderToDelete2.fileBridge.deleteDirectory(true);
					if (folderToDelete3.fileBridge.exists) folderToDelete3.fileBridge.deleteDirectory(true);
					if (folderToDelete4.fileBridge.exists) folderToDelete4.fileBridge.deleteDirectory(true);
				}
				if (isAway3DProject)
				{
					if (folderToDelete5.fileBridge.exists) folderToDelete5.fileBridge.deleteDirectory(true);
				}

			}
			if (isVisualEditorProject)
			{
				if (projectTemplateType == ProjectTemplateType.VISUAL_EDITOR_FLEX)
				{
					th.projectTemplate(templateDir.resolvePath("src_flex"), targetFolder.resolvePath("src"));
				}
				else if (projectTemplateType == ProjectTemplateType.VISUAL_EDITOR_PRIMEFACES)
				{
					th.projectTemplate(templateDir.resolvePath("src_primeface"), targetFolder.resolvePath("src"));
				}
				
				var folderToDelete6:FileLocation = targetFolder.resolvePath("src_primeface");
				var folderToDelete7:FileLocation = targetFolder.resolvePath("src_flex");
					
				if (folderToDelete6.fileBridge.exists) folderToDelete6.fileBridge.deleteDirectory(true);
				if (folderToDelete7.fileBridge.exists) folderToDelete7.fileBridge.deleteDirectory(true);
			}
			if (isLibraryProject)
			{
				// get the configuration from the library settings component
				librarySettingObject = newLibrarySetting.librarySettingObject;
				
				var folderToCreate:FileLocation = targetFolder.resolvePath("src");
				if (!folderToCreate.fileBridge.exists) folderToCreate.fileBridge.createDirectory();
				folderToCreate = targetFolder.resolvePath("bin-debug");
				if (!folderToCreate.fileBridge.exists) folderToCreate.fileBridge.createDirectory();
			}
			
			// creating certificate conditional checks
			if (!descriptorFileLocation || !descriptorFileLocation.fileBridge.exists)
			{
				descriptorFileLocation = targetFolder.resolvePath("application.xml");
				if (!descriptorFileLocation.fileBridge.exists)
				{
					descriptorFileLocation = targetFolder.resolvePath(sourcePath + File.separator + sourceFile +"-app.xml");
				}
			}
			
			if (descriptorFileLocation.fileBridge.exists)
			{
				// lets update $SWFVersion with SWF version now
				var stringOutput:String = descriptorFileLocation.fileBridge.read() as String;
				var firstNamespaceQuote:int = stringOutput.indexOf('"', stringOutput.indexOf("<application xmlns=")) + 1;
				var lastNamespaceQuote:int = stringOutput.indexOf('"', firstNamespaceQuote);
				var currentAIRNamespaceVersion:String = stringOutput.substring(firstNamespaceQuote, lastNamespaceQuote);
				
				stringOutput = stringOutput.replace(currentAIRNamespaceVersion, "http://ns.adobe.com/air/application/"+ movieVersion);
				descriptorFileLocation.fileBridge.save(stringOutput);
			}

			var projectSettingsFile:String = projectName + ".as3proj";
			if (isVisualEditorProject && !exportProject)
			{
				projectSettingsFile = projectName+".veditorproj";
			}
			else if (isJavaProject)
			{
				projectSettingsFile = projectName+".javaproj";
			}
			else if (isGrailsProject)
			{
				projectSettingsFile = projectName+".grailsproj";
			}
			else if (isHaxeProject)
			{
				projectSettingsFile = projectName+".hxproj";
			}

			// Figure out which one is the settings file
			var settingsFile:FileLocation = targetFolder.resolvePath(projectSettingsFile);
            var descriptorFile:File = (isMobileProject || (isActionScriptProject && activeType == ProjectType.AS3PROJ_AS_AIR)) ?
                    new File(project.folderLocation.fileBridge.nativePath + File.separator + sourcePath + File.separator + sourceFile +"-app.xml") :
                    null;

			if (!isJavaProject && !isGrailsProject)
			{
				// Set some stuff to get the paths right
				pvo = FlashDevelopImporter.parse(settingsFile, projectName, descriptorFile, true, projectTemplateType);
				pvo.isLibraryProject = isLibraryProject;

				if (pvo.isLibraryProject)
				{
					pvo.air = librarySettingObject.includeAIR;
					pvo.isMobile = (librarySettingObject.type == LibrarySettingsVO.MOBILE_LIBRARY || librarySettingObject.output == LibrarySettingsVO.MOBILE);
					if (pvo.air) pvo.buildOptions.additional = "+configname=air";
					if (pvo.isMobile) pvo.buildOptions.additional = "+configname=airmobile";
					if (!pvo.air && !pvo.isMobile) pvo.buildOptions.additional = "+configname=flex";
				}

				pvo.buildOptions.customSDKPath = _customSdk;
				_customSdk = null;

				if (isVisualEditorProject)
				{
					pvo.isPrimeFacesVisualEditorProject = projectTemplateType == ProjectTemplateType.VISUAL_EDITOR_PRIMEFACES;
				}

				// in case of Flex project (where mx or spark controls can be included)
				// we need to populate the project's intrinsic libraries. this will also help
				// when next time project opens we can detect between pure AS and flex type of project
				if ((isLibraryProject && librarySettingObject.type != LibrarySettingsVO.ACTIONSCRIPT_LIBRARY) || (!isLibraryProject && !isActionScriptProject && !isFeathersProject))
				{
					pvo.intrinsicLibraries.push("Library\\AS3\\frameworks\\Flex4");
					pvo.isActionScriptOnly = false;
				}
			}

			pvo.projectName = projectName;
			pvo.menuType = getProjectMenuType(pvo);

			if (isJavaProject)
			{
				JavaExporter.export(pvo as JavaProjectVO, true);
			}
			else if (isGrailsProject)
			{
				GrailsExporter.export(pvo as GrailsProjectVO);
			}
			else if (isHaxeProject)
			{
				HaxeExporter.export(pvo as HaxeProjectVO);
			}
			else
			{
				// Write settings
				FlashDevelopExporter.export(pvo as AS3ProjectVO, settingsFile);
			}

            return pvo;
		}

		private function getProjectWithTemplate(pvo:Object, exportProject:AS3ProjectVO = null):Object
		{
			if (!projectTemplateType)
			{
				return pvo;
			}

			if (pvo is ProjectShellVO)
			{
				pvo = (pvo as ProjectShellVO).getProjectOutOfShell(projectTemplateType);
			}

            if (isOpenProjectCall || isFlexJSRoyalProject)
            {
				setProjectType(projectTemplateType);

				var projectsTemplates:ArrayCollection = isFlexJSRoyalProject ?
						ConstantsCoreVO.TEMPLATES_PROJECTS_ROYALE :
						allProjectTemplates;

				for each (var template:TemplateVO in projectsTemplates)
				{
					if(template.title == projectTemplateType)
					{
						if (isJavaProject || isGrailsProject)
						{
							templateLookup[pvo] = template.file;
							break;
						}
						else
						{
							var templateSettingsName:String = "$Settings.as3proj.template";
							if(isVisualEditorProject && !exportProject)
							{
								templateSettingsName = "$Settings.veditorproj.template";
							}

							var tmpLocation:FileLocation = pvo.folderLocation;
							var tmpName:String = pvo.projectName;
							var tmpExistingSource:Vector.<FileLocation> = pvo.projectWithExistingSourcePaths;
							var tmpIsExistingProjectSource:Boolean = pvo.isProjectFromExistingSource;
							templateLookup[pvo] = template.file;

							pvo = FlashDevelopImporter.parse(template.file.fileBridge.resolvePath(templateSettingsName), null, null, true, projectTemplateType);
							pvo.folderLocation = tmpLocation;
							pvo.projectName = tmpName;
							pvo.projectWithExistingSourcePaths = tmpExistingSource;
							pvo.isProjectFromExistingSource = tmpIsExistingProjectSource;
							break;
						}
					}
				}
            }

			return pvo;
		}
		
		private function setAutoSuggestSDKbyType():void
		{
			customSdk = null;
			
			var sdkReference:SDKReferenceVO;
			if (isFeathersProject)
			{
				sdkReference = SDKUtils.checkSDKTypeInSDKList(SDKTypes.FEATHERS);
			}
			else if (isFlexJSRoyalProject)
			{
				sdkReference = SDKUtils.checkSDKTypeInSDKList(SDKTypes.ROYALE);
			}
			else if (!isJavaProject && !isFlexJSRoyalProject)
			{
				sdkReference = SDKUtils.checkSDKTypeInSDKList(SDKTypes.FLEX);
			}
			
			if (sdkReference)
			{
				customSdk = sdkReference.path;

				if (customSdkPathSetting)
				{
					customSdkPathSetting.stringValue = sdkReference.name;
				}
			}
			else if (customSdkPathSetting)
			{
				customSdkPathSetting.stringValue = null;
				customSdkPathSetting.commitChanges();
			}
		}

        private function setProjectType(templateName:String):void
        {
			isJavaProject = false;
            isVisualEditorProject = false;
            isLibraryProject = false;
            isFeathersProject = false;
            isMobileProject = false;
            isAway3DProject = false;
            isFlexJSRoyalProject = false;
            isGrailsProject = false;
            isHaxeProject = false;

			if (templateName.indexOf(ProjectTemplateType.VISUAL_EDITOR) != -1)
			{
				isVisualEditorProject = true;
			}
			
			if (templateName.indexOf(ProjectTemplateType.LIBRARY_PROJECT) != -1)
			{
				isLibraryProject = true;
			}

            if (templateName.indexOf(ProjectTemplateType.FEATHERS) != -1)
            {
                isFeathersProject = true;
            }

            if (templateName.indexOf(ProjectTemplateType.ACTIONSCRIPT) != -1)
            {
                isActionScriptProject = true;
            }
            else if (templateName.indexOf(ProjectTemplateType.MOBILE) != -1)
            {
                isMobileProject = true;
            }
			else if (templateName.indexOf(ProjectTemplateType.AWAY3D) != -1)
			{
				isAway3DProject = true;
			}
			else if (templateName.indexOf("Royale") != -1 || templateName.indexOf("FlexJS") != -1)
			{
				isFlexJSRoyalProject = true;
			}
			else if (templateName.indexOf(ProjectTemplateType.JAVA) != -1)
			{
				isJavaProject = true;
			}
			else if (templateName.indexOf(ProjectTemplateType.GRAILS) != -1)
			{
				isGrailsProject = true;
			}
			else if (templateName.indexOf(ProjectTemplateType.HAXE) != -1)
			{
				isHaxeProject = true;
			}
            else
            {
                isActionScriptProject = false;
            }
        }
		
		private function getProjectMenuType(pvo:Object):String
		{
			if (pvo.hasOwnProperty("isPrimeFacesVisualEditorProject") && pvo.isPrimeFacesVisualEditorProject)
			{
				return ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES;
			}
			if (pvo.hasOwnProperty("isActionScriptOnly") && pvo.isActionScriptOnly)
			{
				return ProjectMenuTypes.PURE_AS;
			}
			if (isVisualEditorProject)
			{
				return ProjectMenuTypes.VISUAL_EDITOR_FLEX;
			}
			if (isLibraryProject)
			{
				return ProjectMenuTypes.LIBRARY_FLEX_AS;
			}
			if (isFlexJSRoyalProject)
			{
				return ProjectMenuTypes.JS_ROYALE;
			}
			if (isJavaProject)
			{
				return ProjectMenuTypes.JAVA;
			}
			if (isGrailsProject)
			{
				return ProjectMenuTypes.GRAILS;
			}
			if (isHaxeProject)
			{
				return ProjectMenuTypes.HAXE;
			}

			return ProjectMenuTypes.FLEX_AS;
		}

		private function throwError():void
		{
			Alert.show(_currentCauseToBeInvalid +" Project creation terminated.", "Error!");
		}
	}
}
