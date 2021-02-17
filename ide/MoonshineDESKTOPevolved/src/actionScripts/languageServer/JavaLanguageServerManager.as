////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.languageServer
{
    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;
    import flash.utils.ByteArray;
    import flash.utils.IDataInput;

    import mx.core.FlexGlobals;
    import mx.managers.PopUpManager;
    import mx.utils.SHA256;

    import feathers.controls.Button;

    import actionScripts.events.ExecuteLanguageServerCommandEvent;
    import actionScripts.events.FilePluginEvent;
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.events.SaveFileEvent;
    import actionScripts.events.SettingsEvent;
    import actionScripts.events.StatusBarEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.languageServer.LanguageClient;
    import actionScripts.locator.IDEModel;
    import actionScripts.plugin.console.ConsoleOutputter;
    import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
    import actionScripts.ui.FeathersUIWrapper;
    import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.ui.editor.JavaTextEditor;
    import actionScripts.utils.CommandLineUtil;
    import actionScripts.utils.EnvironmentSetupUtils;
    import actionScripts.utils.UtilsCore;
    import actionScripts.utils.applyWorkspaceEdit;
    import actionScripts.utils.getProjectSDKPath;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.EnvironmentExecPaths;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.valueObjects.Settings;
    import actionScripts.valueObjects.WorkspaceEdit;

    import com.adobe.utils.StringUtil;

    import moonshine.components.StandardPopupView;
    import moonshine.theme.MoonshineTheme;

	[Event(name="init",type="flash.events.Event")]
	[Event(name="close",type="flash.events.Event")]

	public class JavaLanguageServerManager extends ConsoleOutputter implements ILanguageServerManager
	{
		//when updating the JDT language server, the name of this JAR file will
		//change, and Moonshine will automatically update the version that is
		//copied to File.applicationStorageDirectory
		private static const LANGUAGE_SERVER_JAR_FILE_NAME_PREFIX:String = "org.eclipse.equinox.launcher_";
		private static const LANGUAGE_SERVER_JAR_FOLDER_PATH:String = "plugins";
		private static const LANGUAGE_SERVER_WINDOWS_CONFIG_PATH:String = "config_win";
		private static const LANGUAGE_SERVER_MACOS_CONFIG_PATH:String = "config_mac";
		private static const PATH_WORKSPACE_STORAGE:String = "java/workspaces";
		private static const PATH_JDT_LANGUAGE_SERVER_APP:String = "elements/jdt-language-server";
		private static const PATH_JDT_LANGUAGE_SERVER_STORAGE:String = "java/jdt-language-server";
		
		private static const LANGUAGE_ID_JAVA:String = "java";
		
		private static const FILE_NAME_POM_XML:String = "pom.xml";
		private static const FILE_NAME_BUILD_GRADLE:String = "build.gradle";

		private static const METHOD_LANGUAGE__STATUS:String = "language/status";
		private static const METHOD_LANGUAGE__ACTIONABLE_NOTIFICATION:String = "language/actionableNotification";
		private static const METHOD_JAVA__PROJECT_CONFIG_UPDATE:String = "java/projectConfigurationUpdate";

		private static const COMMAND_JAVA_IGNORE_INCOMPLETE_CLASSPATH_HELP:String = "java.ignoreIncompleteClasspath.help";
		private static const COMMAND_JAVA_IGNORE_INCOMPLETE_CLASSPATH:String = "java.ignoreIncompleteClasspath";
		private static const COMMAND_JAVA_APPLY_WORKSPACE_EDIT:String = "java.apply.workspaceEdit";
		private static const COMMAND_JAVA_CLEAN_WORKSPACE:String = "java.clean.workspace";
		
		private static const URI_SCHEME_FILE:String = "file";

		private static const URI_SCHEMES:Vector.<String> = new <String>[];
		private static const FILE_EXTENSIONS:Vector.<String> = new <String>["java"];

		private var _project:JavaProjectVO;
		private var _languageClient:LanguageClient;
		private var _model:IDEModel = IDEModel.getInstance();
		private var _dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var _languageServerProcess:NativeProcess;
		private var _languageStatusDone:Boolean = false;
		private var _waitingToRestart:Boolean = false;
		private var _waitingToCleanWorkspace:Boolean = false;
		private var _previousJDKPath:String = null;
		private var _languageServerLauncherJar:File;
		private var _javaVersion:String = null;
		private var _javaVersionProcess:NativeProcess;
		private var _waitingToDispose:Boolean = false;

		public function JavaLanguageServerManager(project:JavaProjectVO)
		{
			_project = project;

			_dispatcher.addEventListener(FilePluginEvent.EVENT_JAVA_TYPEAHEAD_PATH_SAVE, jdkPathSaveHandler, false, 0, true);
			_dispatcher.addEventListener(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, executeLanguageServerCommandHandler, false, 0, true);
			_dispatcher.addEventListener(SaveFileEvent.FILE_SAVED, fileSavedHandler, false, 0, true);
			//when adding new listeners, don't forget to also remove them in
			//dispose()

			prepareApplicationStorage();
			bootstrapThenStartNativeProcess();
		}

		public function get project():ProjectVO
		{
			return _project;
		}

		public function get uriSchemes():Vector.<String>
		{
			return URI_SCHEMES;
		}

		public function get fileExtensions():Vector.<String>
		{
			return FILE_EXTENSIONS;
		}

		public function get active():Boolean
		{
			return _languageClient && _languageClient.initialized;
		}

		public function createTextEditorForUri(uri:String, readOnly:Boolean = false):BasicTextEditor
		{
			var colonIndex:int = uri.indexOf(":");
			if(colonIndex == -1)
			{
				throw new URIError("Invalid URI: " + uri);
			}
			var scheme:String = uri.substr(0, colonIndex);

			var editor:JavaTextEditor = new JavaTextEditor(readOnly);
			if(scheme == URI_SCHEME_FILE)
			{
				//the regular OpenFileEvent should be used to open this one
				return editor;
			}
			switch(scheme)
			{
				default:
				{
					throw new URIError("Unknown URI scheme for Java: " + scheme);
				}
			}
			return editor;
		}

		protected function dispose():void
		{
			_dispatcher.removeEventListener(FilePluginEvent.EVENT_JAVA_TYPEAHEAD_PATH_SAVE, jdkPathSaveHandler);
			_dispatcher.removeEventListener(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, executeLanguageServerCommandHandler);
			_dispatcher.removeEventListener(SaveFileEvent.FILE_SAVED, fileSavedHandler);

			cleanupLanguageClient();

			if(_javaVersionProcess)
			{
				_waitingToDispose = true;
				_javaVersionProcess.exit(true);
			}
		}

		protected function cleanupLanguageClient():void
		{
			if(!_languageClient)
			{
				return;
			}
			_languageStatusDone = false;
			_languageClient.removeCommandListener(COMMAND_JAVA_CLEAN_WORKSPACE, command_javaCleanWorkspaceHandler);
			_languageClient.removeNotificationListener(METHOD_LANGUAGE__STATUS, language__status);
			_languageClient.removeNotificationListener(METHOD_LANGUAGE__ACTIONABLE_NOTIFICATION, language__actionableNotification);
			_languageClient.removeEventListener(Event.INIT, languageClient_initHandler);
			_languageClient.removeEventListener(Event.CLOSE, languageClient_closeHandler);
			_languageClient = null;
		}

		private function extractVersionStringFromStandardErrorOutput(versionOutput:String):String
		{
			var result:Array = versionOutput.match(/version "(\d+(\.\d+)*(_\d+)?(\-\w+)?)"/);
			if(result && result.length > 1)
			{
				return result[1];
			}
			return versionOutput;
		}

		private function isJavaVersionSupported(version:String):Boolean
		{
			var parts:Array = version.split("-");
			var versionNumberWithUpdate:String = parts[0];
			parts = versionNumberWithUpdate.split("_");
			var versionNumber:String = parts[0];
			var versionNumberParts:Array = versionNumber.split(".");
			var partsCount:int = versionNumberParts.length;
			for(var i:int = 0; i < partsCount; i++)
			{
				var part:String = versionNumberParts[i];
				var parsed:Number = parseInt(part, 10);
				if(isNaN(parsed))
				{
					return false;
				}
				versionNumberParts[i] = parsed;
			}
			var major:Number = versionNumberParts[0];
			if(major < 11)
			{
				return false;
			}
			return true;
		}

		private function prepareApplicationStorage():void
		{
			var appFolder:File = File.applicationDirectory.resolvePath(PATH_JDT_LANGUAGE_SERVER_APP);
			var appPluginsFolder:File = appFolder.resolvePath(LANGUAGE_SERVER_JAR_FOLDER_PATH)
			var storageFolder:File = File.applicationStorageDirectory.resolvePath(PATH_JDT_LANGUAGE_SERVER_STORAGE);
			var storagePluginsFolder:File = storageFolder.resolvePath(LANGUAGE_SERVER_JAR_FOLDER_PATH);
			
			this._languageServerLauncherJar = null;
			var files:Array = appPluginsFolder.getDirectoryListing();
			var fileCount:int = files.length;
			for(var i:int = 0; i < fileCount; i++)
			{
				var file:File = File(files[i]);
				if(file.name.indexOf(LANGUAGE_SERVER_JAR_FILE_NAME_PREFIX) == 0)
				{
					//jarFile = file;
					this._languageServerLauncherJar = storagePluginsFolder.resolvePath(file.name);
					break;
				}
			}
			if(!this._languageServerLauncherJar)
			{
				error("Error initializing Java language server. Missing Java language server launcher.");
				return;
			}
			if(this._languageServerLauncherJar.exists)
			{
				//we've already copied the files to application storage, so
				//we're good to go!
				return;
			}
			//this directory may already exist, if an older version of Moonshine
			//with an older version of the JDT language server was installed
			//we don't want conflicts between JDT language server versions, so
			//delete the entire directory and start fresh
			var showStorageError:Boolean = false;
			try
			{
				if(storageFolder.exists)
				{
					storageFolder.deleteDirectory(true);
				}
				appFolder.copyTo(storageFolder);
			}
			catch(error:Error)
			{
				showStorageError = true;
			}
			if(showStorageError || !storageFolder.exists || !this._languageServerLauncherJar.exists)
			{
				//something went wrong!
				error("Error initializing Java language server. Please delete the following folder, if it exists, and restart Moonshine: " + storageFolder.nativePath);
			}
		}

		private function bootstrapThenStartNativeProcess():void
		{
			if(!UtilsCore.isJavaForTypeaheadAvailable())
			{
				return;
			}
			checkJavaVersion();
		}
		
		private function checkJavaVersion():void
		{
			_dispatcher.dispatchEvent(new StatusBarEvent(
				StatusBarEvent.LANGUAGE_SERVER_STATUS,
				project.name, "Checking Java version...", false
			));

			this._javaVersion = "";
			var javaVersionCommand:Vector.<String> = new <String>[
				EnvironmentExecPaths.JAVA_ENVIRON_EXEC_PATH,
				"-version"
			];
			EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(function(value:String):void
			{
				var cmdFile:File = null;
				var processArgs:Vector.<String> = new <String>[];
				
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

				var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				processInfo.arguments = processArgs;
				processInfo.executable = cmdFile;
				processInfo.workingDirectory = _project.folderLocation.fileBridge.getFile as File;
				
				_javaVersionProcess = new NativeProcess();
				_javaVersionProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, javaVersionProcess_standardErrorDataHandler);
				_javaVersionProcess.addEventListener(NativeProcessExitEvent.EXIT, javaVersionProcess_exitHandler);
				_javaVersionProcess.start(processInfo);
			}, null, [CommandLineUtil.joinOptions(javaVersionCommand)]);
		}

		private function startNativeProcess():void
		{
			if(_languageServerProcess)
			{
				trace("Error: Java language server process already exists!");
				return;
			}
			var jdkPath:String = getProjectSDKPath(_project, _model);
			_previousJDKPath = jdkPath;
			if(!jdkPath)
			{
				return;
			}

			var jdkFolder:File = new File(jdkPath);

			var javaFileName:String = (Settings.os == "win") ? "java.exe" : "java";
			var cmdFile:File = jdkFolder.resolvePath(javaFileName);
			if(!cmdFile.exists)
			{
				cmdFile = jdkFolder.resolvePath("bin/" + javaFileName);
			}
			if(!cmdFile.exists)
			{
				error("Invalid path to Java Development Kit: " + cmdFile.nativePath);
                _dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, "actionScripts.plugins.as3project.mxmlc::MXMLCPlugin"));
				return;
			}

			var storageFolder:File = File.applicationStorageDirectory.resolvePath(PATH_JDT_LANGUAGE_SERVER_STORAGE);
			var processArgs:Vector.<String> = new <String>[];
			var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			//uncomment to allow connection to debugger
			//processArgs.push("-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=1044");
			processArgs.push("-Declipse.application=org.eclipse.jdt.ls.core.id1");
			processArgs.push("-Dosgi.bundles.defaultStartLevel=4");
			processArgs.push("-Declipse.product=org.eclipse.jdt.ls.core.product");
			//uncomment for extra debug logging
			//processArgs.push("-Dlog.level=ALL");
			processArgs.push("-noverify");
			processArgs.push("-Xmx1G");
			processArgs.push("-jar");
			processArgs.push(this._languageServerLauncherJar.nativePath);
			processArgs.push("-configuration");
			var configFile:File = null;
			if(ConstantsCoreVO.IS_MACOS)
			{
				configFile = storageFolder.resolvePath(LANGUAGE_SERVER_MACOS_CONFIG_PATH);
			}
			else
			{
				configFile = storageFolder.resolvePath(LANGUAGE_SERVER_WINDOWS_CONFIG_PATH);
			}
			processArgs.push(configFile.nativePath);
			processArgs.push("-data");
			//this is a file outside of the project folder due to limitations
			//of the language server, which is based on Eclipse
			processArgs.push(getWorkspaceNativePath());
			processInfo.arguments = processArgs;
			processInfo.executable = cmdFile;
			processInfo.workingDirectory = _project.folderLocation.fileBridge.getFile as File;

			_languageServerProcess = new NativeProcess();
			_languageServerProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, languageServerProcess_standardErrorDataHandler);
			_languageServerProcess.addEventListener(NativeProcessExitEvent.EXIT, languageServerProcess_exitHandler);
			_languageServerProcess.start(processInfo);

			initializeLanguageServer(jdkPath);
		}

		private function getWorkspaceNativePath():String
		{
			//we need to store the language server's data files somewhere, but
			//it CANNOT be inside the project directory. let's put them in the
			//app storage directory instead.
			var projectPath:String = _project.folderLocation.fileBridge.nativePath;
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(projectPath);
			//we need to differentiate between different projects that have
			//the same name, so let's use a hash of the full path
			var digest:String = SHA256.computeDigest(bytes);
			bytes.clear();
			var workspaceLocation:File = File.applicationStorageDirectory.resolvePath(PATH_WORKSPACE_STORAGE).resolvePath(digest);
			return workspaceLocation.nativePath;
		}

		private function getProjectBuildConfigFile():FileLocation
		{
			//same as JavaImporter, prefer pom.xml over build.gradle
			var configFile:FileLocation = project.folderLocation.resolvePath(FILE_NAME_POM_XML);
			if(!configFile.fileBridge.exists)
			{
				configFile = project.folderLocation.resolvePath(FILE_NAME_BUILD_GRADLE);
			}
			return configFile;
		}
		
		private function initializeLanguageServer(sdkPath:String):void
		{
			if(_languageClient)
			{
				//we're already initializing or initialized...
				trace("Error: Java language client already exists!");
				return;
			}

			trace("Java language server workspace root: " + project.folderPath);
			trace("Java language Server JDK: " + sdkPath);

			var initOptions:Object = 
			{
				bundles: [],
				workspaceFolders: [_project.projectFolder.file.fileBridge.url],
				settings: {
					java: {
						autobuild: {
							enabled: false
						}
					}
				},
				extendedClientCapabilities:
				{
					progressReportProvider: false,//getJavaConfiguration().get('progressReports.enabled'),
					classFileContentsSupport: true,
					overrideMethodsPromptSupport: true,
					hashCodeEqualsPromptSupport: true,
					advancedOrganizeImportsSupport: true,
					generateToStringPromptSupport: true,
					advancedGenerateAccessorsSupport: true,
					generateConstructorsPromptSupport: true,
					generateDelegateMethodsPromptSupport: true,
					advancedExtractRefactoringSupport: true
				}
			};

			_languageStatusDone = false;
			var debugMode:Boolean = false;
			_languageClient = new LanguageClient(LANGUAGE_ID_JAVA, _project, debugMode, initOptions,
				_dispatcher, _languageServerProcess.standardOutput, _languageServerProcess, ProgressEvent.STANDARD_OUTPUT_DATA, _languageServerProcess.standardInput);
			_languageClient.addEventListener(Event.INIT, languageClient_initHandler);
			_languageClient.addEventListener(Event.CLOSE, languageClient_closeHandler);
			_languageClient.addNotificationListener(METHOD_LANGUAGE__STATUS, language__status);
			_languageClient.addNotificationListener(METHOD_LANGUAGE__ACTIONABLE_NOTIFICATION, language__actionableNotification);
			_languageClient.addCommandListener(COMMAND_JAVA_CLEAN_WORKSPACE, command_javaCleanWorkspaceHandler);
		}

		private function restartLanguageServer():void
		{
			if(_waitingToRestart)
			{
				//we'll just continue waiting
				return;
			}
			_waitingToCleanWorkspace = false;
			_waitingToRestart = false;
			if(_languageClient)
			{
				_waitingToRestart = true;
				_languageClient.stop();
			}
			else if(_languageServerProcess)
			{
				_waitingToRestart = true;
				_languageServerProcess.exit();
			}

			if(!_waitingToRestart)
			{
				bootstrapThenStartNativeProcess();
			}
		}

		private function cleanWorkspace():void
		{
			try
			{
				var workspaceFolder:File = new File(getWorkspaceNativePath());
				if(workspaceFolder.exists && workspaceFolder.isDirectory)
				{
					workspaceFolder.deleteDirectory(true);
				}
			}
			catch(e:Error)
			{
				error("Failed to clean project workspace");
			}
			restartLanguageServer();
		}

		private function createCommandListener(command:String, args:Array, popup:StandardPopupView, popupWrapper:FeathersUIWrapper):Function
		{
			return function(event:Event):void
			{
				_dispatcher.dispatchEvent(new ExecuteLanguageServerCommandEvent(
					ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND,
					project, command, args ? args : []));
				if(popup)
				{
					PopUpManager.removePopUp(popupWrapper);
					popup.data = null;
				}
			};
		}

		private function languageServerProcess_standardErrorDataHandler(e:ProgressEvent):void
		{
			var output:IDataInput = _languageServerProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			error(data);
			trace(data);
		}

		private function languageServerProcess_exitHandler(e:NativeProcessExitEvent):void
		{
			if(_languageClient)
			{
				//this should have already happened, but if the process exits
				//abnormally, it might not have
				_languageClient.stop();
				
				warning("Java language server exited unexpectedly. Close the " + project.name + " project and re-open it to enable code intelligence.");
			}
			_languageServerProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, languageServerProcess_standardErrorDataHandler);
			_languageServerProcess.removeEventListener(NativeProcessExitEvent.EXIT, languageServerProcess_exitHandler);
			_languageServerProcess.exit();
			_languageServerProcess = null;
			if(_waitingToRestart)
			{
				_waitingToRestart = false;
				bootstrapThenStartNativeProcess();
				return;
			}
		}
		
		private function javaVersionProcess_standardErrorDataHandler(event:ProgressEvent):void 
		{
			if(_javaVersionProcess)
			{
				//for some reason, java -version writes to stderr
				var output:IDataInput = _javaVersionProcess.standardError;
				var data:String = output.readUTFBytes(output.bytesAvailable);
				this._javaVersion += data;
			}
		}
		
		private function javaVersionProcess_exitHandler(event:NativeProcessExitEvent):void
		{
			_dispatcher.dispatchEvent(new StatusBarEvent(
				StatusBarEvent.LANGUAGE_SERVER_STATUS,
				project.name
			));

			_javaVersionProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, javaVersionProcess_standardErrorDataHandler);
			_javaVersionProcess.removeEventListener(NativeProcessExitEvent.EXIT, javaVersionProcess_exitHandler);
			_javaVersionProcess.exit();
			_javaVersionProcess = null;

			if(_waitingToDispose)
			{
				//don't continue if we've disposed during the bootstrap process
				return;
			}
			if(_waitingToRestart)
			{
				_waitingToRestart = false;
				bootstrapThenStartNativeProcess();
				return;
			}

			if(event.exitCode == 0)
			{
				this._javaVersion = extractVersionStringFromStandardErrorOutput(StringUtil.trim(this._javaVersion));
				trace("Java version: " + this._javaVersion);
				if(!isJavaVersionSupported(this._javaVersion))
				{
					error("Java version 11.0.0 or newer is required. Version not supported: " + this._javaVersion + ". Java code intelligence disabled for project: " + project.name + ".");
					return;
				}
				startNativeProcess();
			}
			else
			{
				error("Failed to load Java version. Java code intelligence disabled for project: " + project.name + ".");
			}
		}

		private function jdkPathSaveHandler(event:FilePluginEvent):void
		{
			//restart only when the path has changed
			if(getProjectSDKPath(_project, _model) != _previousJDKPath)
			{
				restartLanguageServer();
			}
		}

		private function fileSavedHandler(event:SaveFileEvent):void
		{
			if(!_languageStatusDone)
			{
				return;
			}
			var savedTab:BasicTextEditor = event.editor as BasicTextEditor;	
			if(!savedTab || !savedTab.currentFile)
			{
				return;
			}
			var uri:String = savedTab.currentFile.fileBridge.url;
			var configFile:FileLocation = getProjectBuildConfigFile();
			if(uri != configFile.fileBridge.url)
			{
				return;
			}
			_languageClient.sendNotification(METHOD_JAVA__PROJECT_CONFIG_UPDATE, {uri: uri});
		}

		private function executeLanguageServerCommandHandler(event:ExecuteLanguageServerCommandEvent):void
		{
			if(event.isDefaultPrevented())
			{
				//already handled somewhere else
				return;
			}
			switch(event.command)
			{
				case COMMAND_JAVA_IGNORE_INCOMPLETE_CLASSPATH:
				{
					event.preventDefault();
					trace("TODO: update the java.errors.incompleteClasspath.severity setting");
					break;
				}
				case COMMAND_JAVA_IGNORE_INCOMPLETE_CLASSPATH_HELP:
				{
					event.preventDefault();
					navigateToURL(new URLRequest("https://github.com/redhat-developer/vscode-java/wiki/%22Classpath-is-incomplete%22-warning"), "_blank");
					break;
				}
				case COMMAND_JAVA_APPLY_WORKSPACE_EDIT:
				{
					event.preventDefault();
					var workspaceEdit:WorkspaceEdit = WorkspaceEdit.parse(event.arguments[0]);
					applyWorkspaceEdit(workspaceEdit);
					break;
				}
			}
		}

		private function languageClient_initHandler(event:Event):void
		{
			this.dispatchEvent(new Event(Event.INIT));
		}

		private function languageClient_closeHandler(event:Event):void
		{
			if(_waitingToCleanWorkspace)
			{
				cleanupLanguageClient();
				cleanWorkspace();
			}
			else if(_waitingToRestart)
			{
				cleanupLanguageClient();
				//the native process will automatically exit, so we continue
				//waiting for that to complete
			}
			else
			{
				dispose();
			}
			this.dispatchEvent(new Event(Event.CLOSE));
		}

		private function language__status(message:Object):void
		{
			if(_languageStatusDone)
			{
				return;
			}
			switch(message.params.type)
			{
				case "Starting":
				{
					GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
						StatusBarEvent.LANGUAGE_SERVER_STATUS,
						project.name, message.params.message, false
					));
					break;
				}
				case "Message":
				{
					GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
						StatusBarEvent.LANGUAGE_SERVER_STATUS,
						project.name, message.params.message, false
					));
				}
				case "Started":
				{
					_languageStatusDone = true;
					GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
						StatusBarEvent.LANGUAGE_SERVER_STATUS,
						project.name
					));
			
					var configFile:FileLocation = getProjectBuildConfigFile();
					_languageClient.sendNotification(METHOD_JAVA__PROJECT_CONFIG_UPDATE, {uri: configFile.fileBridge.url});
					break;
				}
				case "Error":
				{
					_languageStatusDone = true;
					GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
						StatusBarEvent.LANGUAGE_SERVER_STATUS,
						project.name
					));
					break;
				}
				default:
				{
					trace("Unknown " + METHOD_LANGUAGE__STATUS + " message type:", message.params.type);
					break;
				}
			}
		}

		private function language__actionableNotification(notification:Object):void
		{
			var params:Object = notification.params;
			var severity:int = notification.severity as int;
			var message:String = params.message;
			var commands:Array = params.commands as Array;

			if(severity == 4) //log
			{
				print(message);
				trace(message);
				return;
			}

			var popup:StandardPopupView = new StandardPopupView();
			popup.data = this; // Keep the command from getting GC'd
			popup.text = message;

			var buttons:Array = [];
			var commandCount:int = commands.length;
			for(var i:int = 0; i < commandCount; i++)
			{
				var command:Object = commands[i];
				var title:String = command.title as String;
				var commandName:String = command.command;
				var args:Array = command.arguments as Array;

				var button:Button = new Button();
				button.variant = MoonshineTheme.THEME_VARIANT_LIGHT_BUTTON;
				button.text = title;
				button.addEventListener(MouseEvent.CLICK, createCommandListener(commandName, args, popup, popupWrapper), false, 0, false);
				buttons.push(button);
			}
			
			popup.controls = buttons;
			
			var popupWrapper:FeathersUIWrapper = new FeathersUIWrapper(popup);
			PopUpManager.addPopUp(popupWrapper, FlexGlobals.topLevelApplication as DisplayObject, true);
			popupWrapper.y = (ConstantsCoreVO.IS_MACOS) ? 25 : 45;
			popupWrapper.x = (FlexGlobals.topLevelApplication.width-popupWrapper.width)/2;
			popupWrapper.assignFocus("top");
		}

		private function command_javaCleanWorkspaceHandler():void
		{
			if(_languageClient)
			{
				_waitingToCleanWorkspace = true;
				_languageClient.stop();
			}
			else
			{
				cleanWorkspace();
			}
		}
	}
}
