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
package actionScripts.plugin.groovy.grailsproject
{
	import actionScripts.plugin.java.javaproject.vo.JavaTypes;
	import actionScripts.utils.UtilsCore;

	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.net.SharedObject;
	import flash.utils.IDataInput;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	
	import actionScripts.events.AddTabEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.NewProjectEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.RefreshTreeEvent;
	import actionScripts.events.SettingsEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.plugin.groovy.grailsproject.exporter.GrailsExporter;
	import actionScripts.plugin.groovy.grailsproject.importer.GrailsImporter;
	import actionScripts.plugin.groovy.grailsproject.vo.GrailsProjectVO;
	import actionScripts.plugin.settings.SettingsView;
	import actionScripts.plugin.settings.vo.AbstractSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	import actionScripts.plugin.settings.vo.StaticLabelSetting;
	import actionScripts.plugin.settings.vo.StringSetting;
	import actionScripts.plugin.templating.TemplatingHelper;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.utils.SharedObjectConst;
	import actionScripts.valueObjects.EnvironmentExecPaths;
	import actionScripts.valueObjects.EnvironmentUtilsCusomSDKsVO;
	import actionScripts.valueObjects.Settings;
	import actionScripts.utils.CommandLineUtil;

	public class CreateGrailsProject extends ConsoleOutputter
	{
		public function CreateGrailsProject(event:NewProjectEvent)
		{
			createGrailsProject(event);
		}

		private var project:GrailsProjectVO;
		private var newProjectNameSetting:StringSetting;
		private var newProjectPathSetting:PathSetting;
		private var isInvalidToSave:Boolean;
		private var cookie:SharedObject;
		private var templateLookup:Object = {};

		private var model:IDEModel = IDEModel.getInstance();
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();

		private var _currentCauseToBeInvalid:String;

		private function createGrailsProject(event:NewProjectEvent):void
		{
            if (!model.grailsPath)
            {
                dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, "actionScripts.plugins.grails::GrailsBuildPlugin"));
                return;
            }
            if (!model.gradlePath)
            {
                dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, "actionScripts.plugins.gradle::GradleBuildPlugin"));
                return;
            }

			var lastSelectedProjectPath:String;
			
			CONFIG::OSX
				{
					if (model.osxBookmarkerCore.availableBookmarkedPaths == "") model.osxBookmarkerCore.removeFlashCookies();
				}
			
            cookie = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);
			if (cookie.data.hasOwnProperty('recentProjectPath'))
			{
				model.recentSaveProjectPath.source = cookie.data.recentProjectPath;
				if (cookie.data.hasOwnProperty('lastSelectedProjectPath')) lastSelectedProjectPath = cookie.data.lastSelectedProjectPath;
			}
			else
			{
				lastSelectedProjectPath = model.fileCore.documentsDirectory.nativePath;
				if (!model.recentSaveProjectPath.contains(lastSelectedProjectPath)) 
				{
					model.recentSaveProjectPath.addItem(lastSelectedProjectPath);
				}
			}

			// Remove spaces from project name
			var projectName:String = (event.templateDir.fileBridge.name.indexOf("(") != -1) ? event.templateDir.fileBridge.name.substr(0, event.templateDir.fileBridge.name.indexOf("(")) : event.templateDir.fileBridge.name;
			projectName = "New" + projectName.replace(/ /g, "");

			project = new GrailsProjectVO(event.templateDir, projectName);

			var tmpProjectSourcePath:String = (lastSelectedProjectPath && model.recentSaveProjectPath.getItemIndex(lastSelectedProjectPath) != -1) ?
					lastSelectedProjectPath : model.recentSaveProjectPath.source[model.recentSaveProjectPath.length - 1];
			project.folderLocation = new FileLocation(tmpProjectSourcePath);

			var settingsView:SettingsView = new SettingsView();
			settingsView.exportProject = event.exportProject;
			settingsView.Width = 150;
			settingsView.defaultSaveLabel = event.isExport ? "Export" : "Create";
			settingsView.isNewProjectSettings = true;
			
			settingsView.addCategory("");

			var settings:SettingsWrapper = getProjectSettings(project, event);

			settingsView.addEventListener(SettingsView.EVENT_SAVE, createSave);
			settingsView.addEventListener(SettingsView.EVENT_CLOSE, createClose);
			settingsView.addSetting(settings, "");
			
			settingsView.label = "New Project";
			settingsView.associatedData = project;
			
			dispatcher.dispatchEvent(new AddTabEvent(settingsView));
			
			templateLookup[project] = event.templateDir;
		}

		private function getProjectSettings(project:GrailsProjectVO, eventObject:NewProjectEvent):SettingsWrapper
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

            return new SettingsWrapper("Name & Location", Vector.<ISetting>([
				new StaticLabelSetting('New '+ eventObject.templateDir.fileBridge.name),
				newProjectNameSetting, // No space input either plx
				newProjectPathSetting,
			]));
		}
		
		private function checkIfProjectDirectory(value:FileLocation):void
		{
			var tmpFile:FileLocation = GrailsImporter.test(value.fileBridge.getFile);
			if (!tmpFile && value.fileBridge.exists)
			{
				tmpFile = value;
			}
			
			if (tmpFile) 
			{
				newProjectPathSetting.setMessage((_currentCauseToBeInvalid = "Project can not be created to an existing project directory:\n"+ value.fileBridge.nativePath), AbstractSetting.MESSAGE_CRITICAL);
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
		
		private function onProjectPathChanged(event:Event, makeNull:Boolean=true):void
		{
			if (makeNull) project.projectFolder = null;
			project.folderLocation = new FileLocation(newProjectPathSetting.stringValue);
			newProjectPathSetting.label = "Parent Directory";
			checkIfProjectDirectory(project.folderLocation.resolvePath(newProjectNameSetting.stringValue));
		}
		
		private function onProjectNameChanged(event:Event):void
		{
			checkIfProjectDirectory(project.folderLocation.resolvePath(newProjectNameSetting.stringValue));
		}
		
		private function createClose(event:Event):void
		{
			var view:SettingsView = event.target as SettingsView;

			view.removeEventListener(SettingsView.EVENT_CLOSE, createClose);
			view.removeEventListener(SettingsView.EVENT_SAVE, createSave);
			if (newProjectPathSetting) 
			{
				newProjectPathSetting.removeEventListener(AbstractSetting.PATH_SELECTED, onProjectPathChanged);
				newProjectNameSetting.removeEventListener(StringSetting.VALUE_UPDATED, onProjectNameChanged);
			}
			
			delete templateLookup[view.associatedData];
			
			dispatcher.dispatchEvent(
				new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, view as DisplayObject)
			);
		}
		
		private function createSave(event:Event):void
		{
			if (isInvalidToSave) 
			{
				throwError();
				return;
			}
			
			var view:SettingsView = event.target as SettingsView;
			var project:GrailsProjectVO = view.associatedData as GrailsProjectVO;

			//save project path in shared object
			cookie = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);
			var tmpParent:FileLocation = project.folderLocation;

			if (!model.recentSaveProjectPath.contains(tmpParent.fileBridge.nativePath))
			{
				model.recentSaveProjectPath.addItem(tmpParent.fileBridge.nativePath);
            }
			
			cookie.data["lastSelectedProjectPath"] = project.folderLocation.fileBridge.nativePath;
			cookie.data["recentProjectPath"] = model.recentSaveProjectPath.source;
			cookie.flush();

            project = createFileSystemBeforeSave(project, view.exportProject as GrailsProjectVO);
			if (!project)
			{
				return;
			}

			this.project = project;

			this.grailsCreateApp();

		}

		private var _shellInfo:NativeProcessStartupInfo;
		private var _nativeProcess:NativeProcess;

		private function grailsCreateApp():void
		{
			if (!model.flexCore.checkRequireJava(project))
			{
				clearOutput();
                var jdkName:String = (project.jdkType == JavaTypes.JAVA_8) ? "JDK 8" : "JDK";
                error("A valid " + jdkName + " path must be defined to build project \"" + project.name + "\".");
                dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, "actionScripts.plugins.as3project.mxmlc::MXMLCPlugin"));
				return;
			}

			var envCustomJava:EnvironmentUtilsCusomSDKsVO = new EnvironmentUtilsCusomSDKsVO();
			envCustomJava.jdkPath = (project.jdkType == JavaTypes.JAVA_8) ?
					model.java8Path.fileBridge.nativePath : model.javaPathForTypeAhead.fileBridge.nativePath;

			var createAppCommand:Vector.<String> = new <String>[
				EnvironmentExecPaths.GRAILS_ENVIRON_EXEC_PATH,
				"create-app",
				project.name,
				"--inplace"
			];
			model.flexCore.initCommandGenerationToSetLocalEnvironment(onEnvironmentPrepared, envCustomJava, [CommandLineUtil.joinOptions(createAppCommand)]);
			
			dispatcher.dispatchEvent(new StatusBarEvent(
				StatusBarEvent.PROJECT_BUILD_STARTED,
				project.projectName, "Creating ", false
			));
			warning("Creating Grails application " + project.name);
			
			/*
			* @local
			*/
			function onEnvironmentPrepared(value:String):void
			{
				var cmdFile:File;
				var processArgs:Vector.<String> = new Vector.<String>;
				
				if (Settings.os == "win")
				{
					cmdFile = new File("c:\\Windows\\System32\\cmd.exe");
					processArgs.push("/c");
					processArgs.push(value);
				}
				else
				{
					cmdFile = new File("/bin/bash");
					processArgs.push("-c");
					processArgs.push(value);
				}
				
				_shellInfo = new NativeProcessStartupInfo();
				_shellInfo.arguments = processArgs;
				_shellInfo.executable = cmdFile;
				_shellInfo.workingDirectory = project.folderLocation.fileBridge.getFile as File;
				
				_nativeProcess = new NativeProcess();
				_nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellDataOnGrailsCreateApp);
				_nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellErrorOnGrailsCreateApp);
				_nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, shellExitAfterGrailsCreateApp);
				_nativeProcess.start(_shellInfo);
			}
		}
		
		private function shellDataOnGrailsCreateApp(e:ProgressEvent):void 
		{
			if(!_nativeProcess)
			{
				return;
			}
			var output:IDataInput = _nativeProcess.standardOutput;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			print(data);
		}
		
		private function shellErrorOnGrailsCreateApp(e:ProgressEvent):void
		{
			if(!_nativeProcess)
			{
				return;
			}
			var output:IDataInput = _nativeProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			error(data);
		}
		
		private function shellExitAfterGrailsCreateApp(event:NativeProcessExitEvent):void
		{
			_nativeProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellErrorOnGrailsCreateApp);
			_nativeProcess.removeEventListener(NativeProcessExitEvent.EXIT, shellExitAfterGrailsCreateApp);
			_nativeProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellDataOnGrailsCreateApp);
			_nativeProcess.exit();
			_nativeProcess = null;
			
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
			if (event.exitCode == 0)
			{
				// Open main file for editing
				dispatcher.dispatchEvent(
					new ProjectEvent(ProjectEvent.ADD_PROJECT, project)
				);
				
				dispatcher.dispatchEvent(new RefreshTreeEvent(project.folderLocation));
			}
		}
		
		private function throwError():void
		{
			Alert.show(_currentCauseToBeInvalid +" Project creation terminated.", "Error!");
		}

		private function createFileSystemBeforeSave(pvo:GrailsProjectVO, exportProject:GrailsProjectVO = null):GrailsProjectVO
		{	
			var templateDir:FileLocation = templateLookup[pvo];
			var projectName:String = pvo.projectName;
			var sourceFileWithExtension:String = pvo.projectName + ".groovy";
			var sourcePath:String = "src" + File.separator + "main" + File.separator + "groovy";

			var targetFolder:FileLocation = pvo.folderLocation;
			
			// Create project root directory
			CONFIG::OSX
				{
					if (!model.osxBookmarkerCore.isPathBookmarked(targetFolder.fileBridge.nativePath))
					{
						_currentCauseToBeInvalid = 'Unable to access Parent Directory:\n'+ targetFolder.fileBridge.nativePath +'\nPlease try to create the project again and use the "Change" link to open the target directory again.';
						throwError();
						return null;
					}
				}
			
			targetFolder = targetFolder.resolvePath(projectName);
			targetFolder.fileBridge.createDirectory();
			
			// Time to do the templating thing!
			var th:TemplatingHelper = new TemplatingHelper();
			th.isProjectFromExistingSource = false;
			th.templatingData["$ProjectName"] = projectName;
			
			var pattern:RegExp = new RegExp(/(_)/g);
			th.templatingData["$ProjectID"] = projectName.replace(pattern, "");
			th.templatingData["$Settings"] = projectName;
			th.templatingData["$SourcePath"] = sourcePath;
			th.templatingData["$SourceFile"] = sourceFileWithExtension ? (sourcePath + File.separator + sourceFileWithExtension) : "";

            th.projectTemplate(templateDir, targetFolder);

			var projectSettingsFileName:String = projectName + ".grailsproj";
			var settingsFile:FileLocation = targetFolder.resolvePath(projectSettingsFileName);
			pvo = GrailsImporter.parse(targetFolder, projectName, settingsFile);

			GrailsExporter.export(pvo);

			return pvo;
		}
	}
}