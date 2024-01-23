////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.java
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.filesystem.File;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	import mx.utils.SHA256;

	import actionScripts.events.ApplicationEvent;
	import actionScripts.events.DiagnosticsEvent;
	import actionScripts.events.ExecuteLanguageServerCommandEvent;
	import actionScripts.events.FilePluginEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.SaveFileEvent;
	import actionScripts.events.SettingsEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.events.WatchedFileChangeEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.languageServer.ILanguageServerManager;
	import actionScripts.languageServer.LanguageClientUtil;
	import actionScripts.languageServer.LanguageServerGlobals;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
	import actionScripts.plugin.java.javaproject.vo.JavaTypes;
	import actionScripts.ui.FeathersUIWrapper;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.editor.LanguageServerTextEditor;
	import actionScripts.utils.CommandLineUtil;
	import actionScripts.utils.EnvironmentSetupUtils;
	import actionScripts.utils.GlobPatterns;
	import actionScripts.utils.UtilsCore;
	import actionScripts.utils.applyWorkspaceEdit;
	import actionScripts.utils.FindOpenPort;
	import actionScripts.utils.isUriInProject;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.EnvironmentExecPaths;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.Settings;

	import com.adobe.utils.StringUtil;

	import feathers.controls.Button;

	import moonshine.components.StandardPopupView;
	import moonshine.lsp.LanguageClient;
	import moonshine.lsp.LogMessageParams;
	import moonshine.lsp.PublishDiagnosticsParams;
	import moonshine.lsp.Registration;
	import moonshine.lsp.RegistrationParams;
	import moonshine.lsp.ShowMessageParams;
	import moonshine.lsp.Unregistration;
	import moonshine.lsp.UnregistrationParams;
	import moonshine.lsp.WorkspaceEdit;
	import moonshine.lsp.events.LspNotificationEvent;
	import moonshine.theme.MoonshineTheme;

	[Event(name="init",type="flash.events.Event")]
	[Event(name="close",type="flash.events.Event")]

	public class JavaLanguageServerManager extends ConsoleOutputter implements ILanguageServerManager
	{
		private static const PATH_JDT_LANGUAGE_SERVER_APP:String = "elements/jdt-language-server";
		private static const LANGUAGE_SERVER_PLUGINS_PATH:String = "plugins";
		private static const LANGUAGE_SERVER_FEATURES_PATH:String = "features";
		private static const LANGUAGE_SERVER_WINDOWS_CONFIG_PATH:String = "config_win";
		private static const LANGUAGE_SERVER_MACOS_CONFIG_PATH:String = "config_mac";
		private static const PATH_WORKSPACE_STORAGE:String = "java/workspaces";

		private static const MINIMUM_JAVA_MAJOR_VERSION:int = 17;
		
		private static const LANGUAGE_ID_JAVA:String = "java";
		
		private static const FILE_NAME_POM_XML:String = "pom.xml";
		private static const FILE_NAME_BUILD_GRADLE:String = "build.gradle";

		private static const METHOD_LANGUAGE__STATUS:String = "language/status";
		private static const METHOD_LANGUAGE__ACTIONABLE_NOTIFICATION:String = "language/actionableNotification";
		private static const METHOD_LANGUAGE__EVENT_NOTIFICATION:String = "language/eventNotification";
		private static const METHOD_JAVA__PROJECT_CONFIG_UPDATE:String = "java/projectConfigurationUpdate";
		private static const METHOD_WORKSPACE__DID_CHANGE_CONFIGURATION:String = "workspace/didChangeConfiguration";

		private static const COMMAND_JAVA_IGNORE_INCOMPLETE_CLASSPATH_HELP:String = "java.ignoreIncompleteClasspath.help";
		private static const COMMAND_JAVA_IGNORE_INCOMPLETE_CLASSPATH:String = "java.ignoreIncompleteClasspath";
		private static const COMMAND_JAVA_APPLY_WORKSPACE_EDIT:String = "java.apply.workspaceEdit";
		private static const COMMAND_JAVA_CLEAN_WORKSPACE:String = "java.clean.workspace";
		private static const COMMAND_JAVA_PROJECT_CONFIGURATION_STATUS:String = "java.projectConfiguration.status";

		private static const FEATURE_STATUS_DISABLED:int = 0;
		private static const FEATURE_STATUS_INTERACTIVE:int = 1;
		private static const FEATURE_STATUS_AUTOMATIC:int = 2;

		private static const MESSAGE_TYPE_ERROR:int = 1;
		private static const MESSAGE_TYPE_WARNING:int = 2;
		private static const MESSAGE_TYPE_INFO:int = 3;
		private static const MESSAGE_TYPE_LOG:int = 4;
		
		private static const URI_SCHEME_FILE:String = "file";

		private static const URI_SCHEMES:Vector.<String> = new <String>[];
		private static const FILE_EXTENSIONS:Vector.<String> = new <String>["java"];

		private static const LANGUAGE_SERVER_SHUTDOWN_TIMEOUT:Number = 8000;

		private static const LANGUAGE_SERVER_PROCESS_FORMATTED_PID:RegExp = new RegExp( /(%%%[0-9]+%%%)/ );

		private var _project:JavaProjectVO;
		private var _languageClient:LanguageClient;
		private var _model:IDEModel = IDEModel.getInstance();
		private var _dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var _useSocket:Boolean = false;
		private var _port:int;
		private var _clientSocket:Socket;
		private var _serverSocket:ServerSocket;
		private var _languageServerProcess:NativeProcess;
		private var _languageStatusDone:Boolean = false;
		private var _waitingToRestart:Boolean = false;
		private var _waitingToCleanWorkspace:Boolean = false;
		private var _previousJDKPath:String = null;
		private var _previousJDK8Path:String = null;
		private var _previousJDKType:String = null;
		private var _javaVersion:String = null;
		private var _javaVersionProcess:NativeProcess;
		private var _waitingToDispose:Boolean = false;
		private var _watchedFiles:Object = {};
		private var _settingUpdateBuildConfiguration:int = FEATURE_STATUS_AUTOMATIC;
		private var _shutdownTimeoutID:uint = uint.MAX_VALUE;
		private var _pid:int = -1;
		private var _watchedFilesDebounceTimeoutID:uint = uint.MAX_VALUE;
		private var _watchedFilesPendingChanges:Array = [];

		public function JavaLanguageServerManager(project:JavaProjectVO)
		{
			_project = project;

			_dispatcher.addEventListener(ProjectEvent.SAVE_PROJECT_SETTINGS, saveProjectSettingsHandler, false, 0, true);
			_dispatcher.addEventListener(FilePluginEvent.EVENT_JAVA_TYPEAHEAD_PATH_SAVE, jdkPathSaveHandler, false, 0, true);
			_dispatcher.addEventListener(FilePluginEvent.EVENT_JAVA8_PATH_SAVE, jdk8PathSaveHandler, false, 0, true);
			_dispatcher.addEventListener(SaveFileEvent.FILE_SAVED, fileSavedHandler, false, 0, true);
			_dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, removeProjectHandler, false, 0, true);
			_dispatcher.addEventListener(ApplicationEvent.APPLICATION_EXIT, applicationExitHandler, false, 0, true);
			_dispatcher.addEventListener(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, executeLanguageServerCommandHandler, false, 0, true);
			_dispatcher.addEventListener(WatchedFileChangeEvent.FILE_CREATED, fileCreatedHandler);
			_dispatcher.addEventListener(WatchedFileChangeEvent.FILE_DELETED, fileDeletedHandler);
			_dispatcher.addEventListener(WatchedFileChangeEvent.FILE_MODIFIED, fileModifiedHandler);
			//when adding new listeners, don't forget to also remove them in
			//dispose()

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

		public function get pid():int
		{
			return _pid;
		}

		public function createTextEditorForUri(uri:String, readOnly:Boolean = false):BasicTextEditor
		{
			var colonIndex:int = uri.indexOf(":");
			if(colonIndex == -1)
			{
				throw new URIError("Invalid URI: " + uri);
			}
			var scheme:String = uri.substr(0, colonIndex);

			var editor:LanguageServerTextEditor = new LanguageServerTextEditor(LANGUAGE_ID_JAVA, _project, readOnly);
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
			_dispatcher.removeEventListener(SaveFileEvent.FILE_SAVED, fileSavedHandler);
			_dispatcher.removeEventListener(ProjectEvent.REMOVE_PROJECT, removeProjectHandler);
			_dispatcher.removeEventListener(ApplicationEvent.APPLICATION_EXIT, applicationExitHandler);
			_dispatcher.removeEventListener(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, executeLanguageServerCommandHandler);
			_dispatcher.removeEventListener(WatchedFileChangeEvent.FILE_CREATED, fileCreatedHandler);
			_dispatcher.removeEventListener(WatchedFileChangeEvent.FILE_DELETED, fileDeletedHandler);
			_dispatcher.removeEventListener(WatchedFileChangeEvent.FILE_MODIFIED, fileModifiedHandler);

			cleanupClientSocket();
			cleanupServerSocket();
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
			_languageClient.unregisterCommand(COMMAND_JAVA_CLEAN_WORKSPACE);
			_languageClient.unregisterCommand(COMMAND_JAVA_APPLY_WORKSPACE_EDIT);
			_languageClient.unregisterCommand(COMMAND_JAVA_PROJECT_CONFIGURATION_STATUS);
			_languageClient.removeNotificationListener(METHOD_LANGUAGE__STATUS, language__status);
			_languageClient.removeNotificationListener(METHOD_LANGUAGE__ACTIONABLE_NOTIFICATION, language__actionableNotification);
			_languageClient.removeNotificationListener(METHOD_LANGUAGE__EVENT_NOTIFICATION, language__eventNotification);
			_languageClient.removeEventListener(Event.INIT, languageClient_initHandler);
			_languageClient.removeEventListener(Event.CLOSE, languageClient_closeHandler);
			_languageClient.removeEventListener(LspNotificationEvent.PUBLISH_DIAGNOSTICS, languageClient_publishDiagnosticsHandler);
			_languageClient.removeEventListener(LspNotificationEvent.REGISTER_CAPABILITY, languageClient_registerCapabilityHandler);
			_languageClient.removeEventListener(LspNotificationEvent.UNREGISTER_CAPABILITY, languageClient_unregisterCapabilityHandler);
			_languageClient.removeEventListener(LspNotificationEvent.LOG_MESSAGE, languageClient_logMessageHandler);
			_languageClient.removeEventListener(LspNotificationEvent.SHOW_MESSAGE, languageClient_showMessageHandler);
			_languageClient.removeEventListener(LspNotificationEvent.APPLY_EDIT, languageClient_applyEditHandler);
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
			if(major < MINIMUM_JAVA_MAJOR_VERSION)
			{
				return false;
			}
			return true;
		}

		private function bootstrapThenStartNativeProcess():void
		{
			if(!UtilsCore.isJavaForTypeaheadAvailable())
			{
				return;
			}
			if (_project.jdkType == JavaTypes.JAVA_8 && !UtilsCore.isJava8Present())
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
				// the process for the language server wasn't cleaned up
				// properly before trying to start a new one...
				trace("Error: Java language server process already exists for project: " + project.name);
				return;
			}
			var jdkPath:String = null;
			if (_model.javaPathForTypeAhead)
			{
				jdkPath = _model.javaPathForTypeAhead.fileBridge.nativePath;
			}
			var jdk8Path:String = null;
			if (_model.java8Path)
			{
				jdk8Path = _model.java8Path.fileBridge.nativePath;
			}
			if(!jdkPath || (_project.jdkType == JavaTypes.JAVA_8 && !jdk8Path))
			{
				//we'll need to try again later if the settings change
				_previousJDKPath = null;
				_previousJDK8Path = null;
				_previousJDKType = null;
				return;
			}
			_previousJDKPath = jdkPath;
			_previousJDK8Path = jdk8Path
			_previousJDKType = _project.jdkType;

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

			var appFolder:File = File.applicationDirectory.resolvePath(PATH_JDT_LANGUAGE_SERVER_APP);
			var configFile:File = null;
			if(ConstantsCoreVO.IS_MACOS)
			{
				configFile = appFolder.resolvePath(LANGUAGE_SERVER_MACOS_CONFIG_PATH);
			}
			else
			{
				configFile = appFolder.resolvePath(LANGUAGE_SERVER_WINDOWS_CONFIG_PATH);
			}
			var pluginsPath:File = appFolder.resolvePath(LANGUAGE_SERVER_PLUGINS_PATH);
			var featuresPath:File = appFolder.resolvePath(LANGUAGE_SERVER_FEATURES_PATH);

			var cp:String = pluginsPath.nativePath + File.separator + "*";
			if (Settings.os == "win")
			{
				cp += ";"
			}
			else
			{
				cp += ":";
			}
			cp += featuresPath.nativePath + File.separator + "*";

			var languageServerCommand:Vector.<String> = new <String>[
				cmdFile.nativePath,
				// uncomment to allow connection to debugger
				// "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=1044",
				"-Declipse.application=org.eclipse.jdt.ls.core.id1",
				"-Dosgi.bundles.defaultStartLevel=4",
				"-Declipse.product=org.eclipse.jdt.ls.core.product",
				"-Dosgi.checkConfiguration=true",
				"-Dosgi.sharedConfiguration.area=" + configFile.nativePath,
				"-Dosgi.sharedConfiguration.area.readOnly=true",
				"-Dosgi.configuration.cascaded=true",
				"-Xmx1G",
				"--add-modules=ALL-SYSTEM",
				"--add-opens",
				"java.base/java.util=ALL-UNNAMED",
				"--add-opens",
				"java.base/java.lang=ALL-UNNAMED",
				"-cp",
				cp,
				// Starting the wrapper instead of the language server launcher
				"moonshine.JDTWrapper",
				"-data",
				//this is a file outside of the project folder due to limitations
				//of the language server, which is based on Eclipse
				getWorkspaceNativePath()
			];
			if (_useSocket)
			{
				languageServerCommand.insertAt(1, "-DCLIENT_PORT=" + _port);
			}
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
				
				_languageServerProcess = new NativeProcess();
				_languageServerProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, languageServerProcess_standardErrorDataHandler);
				_languageServerProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, languageServerProcess_standardOutputDataHandler);
				_languageServerProcess.addEventListener(NativeProcessExitEvent.EXIT, languageServerProcess_exitHandler);
				_languageServerProcess.start(processInfo);

				if (!_serverSocket)
				{
					initializeLanguageServer(jdkPath);
				}
			}, null, [CommandLineUtil.joinOptions(languageServerCommand)]);
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

		private function startServerSocket():void
		{
			_port = FindOpenPort.findOpenPort();

			_serverSocket = new ServerSocket();
			_serverSocket.bind(_port);
			_serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, serverSocket_connectHandler);
			_serverSocket.listen();

			startNativeProcess();
		}

		private function cleanupServerSocket():void
		{
			if (!_serverSocket)
			{
				return;
			}
			_serverSocket.removeEventListener(ServerSocketConnectEvent.CONNECT, serverSocket_connectHandler);
			_serverSocket = null;
		}
	
		private function flushSocket():void
		{
			if(!_clientSocket)
			{
				return;
			}
			_clientSocket.flush();
		}

		private function cleanupClientSocket():void
		{
			if (!_clientSocket)
			{
				return;
			}

			_clientSocket.removeEventListener(IOErrorEvent.IO_ERROR, clientSocket_ioErrorHandler);
			_clientSocket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, clientSocket_securityErrorHandler);
            _clientSocket.removeEventListener(Event.CLOSE, clientSocket_closeHandler);
            _clientSocket = null;
		}
		
		private function initializeLanguageServer(sdkPath:String):void
		{
			if(_languageClient)
			{
				// the language server is already initializing or initialized...
				trace("Error: Java language client already exists for project: " + project.name);
				return;
			}

			trace("Java language server workspace root: " + project.folderPath);
			trace("Java language server JDK: " + sdkPath);
			if(_project.jdkType == JavaTypes.JAVA_8) {
				var jdk8NativePath:String = (_model.java8Path != null) ? _model.java8Path.fileBridge.nativePath : null;
				trace("Java JDK 8: " + jdk8NativePath);
			}

			var initOptions:Object = 
			{
				bundles: [],
				workspaceFolders: [_project.projectFolder.file.fileBridge.url],
				settings: getWorkspaceSettings(),
				extendedClientCapabilities:
				{
					progressReportProvider: false,//getJavaConfiguration().get('progressReports.enabled'),
					classFileContentsSupport: false,
					overrideMethodsPromptSupport: false,
					hashCodeEqualsPromptSupport: false,
					advancedOrganizeImportsSupport: false,
					generateToStringPromptSupport: false,
					advancedGenerateAccessorsSupport: false,
					generateConstructorsPromptSupport: false,
					generateDelegateMethodsPromptSupport: false,
					advancedExtractRefactoringSupport: false,
					// inferSelectionSupport: ["extractMethod", "extractVariable", "extractField"],
					moveRefactoringSupport: false,
					clientHoverProvider: false,
					clientDocumentSymbolProvider: false,
					gradleChecksumWrapperPromptSupport: false,
					resolveAdditionalTextEditsSupport: false,
					advancedIntroduceParameterRefactoringSupport: false,
					actionableRuntimeNotificationSupport: false,
					shouldLanguageServerExitOnShutdown: true
					// onCompletionItemSelectedCommand: "editor.action.triggerParameterHints"
				}
			};

			_languageStatusDone = false;
			var debugMode:Boolean = false;
			if (_useSocket)
			{
				_languageClient = new LanguageClient(LANGUAGE_ID_JAVA,
					_clientSocket, _clientSocket, ProgressEvent.SOCKET_DATA, _clientSocket, flushSocket);
			}
			else
			{
				_languageClient = new LanguageClient(LANGUAGE_ID_JAVA,
					_languageServerProcess.standardOutput, _languageServerProcess, ProgressEvent.STANDARD_OUTPUT_DATA,
					_languageServerProcess.standardInput);
			}
			_languageClient.debugMode = debugMode;
			_languageClient.addWorkspaceFolder({
				name: project.name,
				uri: project.folderLocation.fileBridge.url
			});
			_languageClient.addEventListener(Event.INIT, languageClient_initHandler);
			_languageClient.addEventListener(Event.CLOSE, languageClient_closeHandler);
			_languageClient.addEventListener(LspNotificationEvent.PUBLISH_DIAGNOSTICS, languageClient_publishDiagnosticsHandler);
			_languageClient.addEventListener(LspNotificationEvent.REGISTER_CAPABILITY, languageClient_registerCapabilityHandler);
			_languageClient.addEventListener(LspNotificationEvent.UNREGISTER_CAPABILITY, languageClient_unregisterCapabilityHandler);
			_languageClient.addEventListener(LspNotificationEvent.LOG_MESSAGE, languageClient_logMessageHandler);
			_languageClient.addEventListener(LspNotificationEvent.SHOW_MESSAGE, languageClient_showMessageHandler);
			_languageClient.addEventListener(LspNotificationEvent.APPLY_EDIT, languageClient_applyEditHandler);
			_languageClient.addNotificationListener(METHOD_LANGUAGE__STATUS, language__status);
			_languageClient.addNotificationListener(METHOD_LANGUAGE__ACTIONABLE_NOTIFICATION, language__actionableNotification);
			_languageClient.addNotificationListener(METHOD_LANGUAGE__EVENT_NOTIFICATION, language__eventNotification);
			_languageClient.registerCommand(COMMAND_JAVA_CLEAN_WORKSPACE, command_javaCleanWorkspaceHandler);
			_languageClient.registerCommand(COMMAND_JAVA_APPLY_WORKSPACE_EDIT, command_javaApplyWorkspaceEditHandler);
			_languageClient.registerCommand(COMMAND_JAVA_PROJECT_CONFIGURATION_STATUS, command_javaProjectConfigurationStatus);
			_project.languageClient = _languageClient;

			var initParams:Object = LanguageClientUtil.getSharedInitializeParams();
			initParams.initializationOptions = initOptions;
			_languageClient.initialize(initParams);
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
			if(_languageClient || _languageServerProcess)
			{
				_waitingToRestart = true;
				shutdown();
			}

			if(!_waitingToRestart)
			{
				bootstrapThenStartNativeProcess();
			}
		}

		private function getWorkspaceSettings():Object
		{
			var runtimes:Array = [];
			var javaHome:FileLocation = null;
			var java8Path:FileLocation = _model.java8Path;
			if(_project.jdkType == JavaTypes.JAVA_8)
			{
				javaHome = java8Path;
				if(java8Path != null)
				{
					runtimes.push({
						"name": "JavaSE-1.8",
						"path": java8Path.fileBridge.nativePath,
						"default":  true
					});
				}
			}
			else
			{
				javaHome = _model.javaPathForTypeAhead;
				var versionParts:Array = _javaVersion.split(".");
				var sourcesZip:FileLocation = _model.javaPathForTypeAhead.fileBridge.resolvePath("lib/src.zip");
				runtimes.push({
					"name": "JavaSE-" + versionParts[0],
					"path": _model.javaPathForTypeAhead.fileBridge.nativePath,
					"sources": sourcesZip.fileBridge.nativePath,
					"javadoc": "https://docs.oracle.com/en/java/javase/" + versionParts[0] + "/docs/api",
					"default":  true
				});
			}
			var settings:Object = {
				java: {
					autobuild: {
						enabled: false
					},
					completion: {
						maxResults: 0
					},
					configuration: {
						runtimes: runtimes
					}
				}
			};
			if (javaHome)
			{
				settings.java.home = javaHome.fileBridge.nativePath;
			}
			switch(_settingUpdateBuildConfiguration) {
				case FEATURE_STATUS_DISABLED:
					settings.java.configuration.updateBuildConfiguration = "disabled";
					break;
				case FEATURE_STATUS_INTERACTIVE:
					settings.java.configuration.updateBuildConfiguration = "interactive";
					break;
				case FEATURE_STATUS_AUTOMATIC:
					settings.java.configuration.updateBuildConfiguration = "automatic";
					break;
			}
			return settings;
		}

		private function sendWorkspaceSettings():void
		{
			if(!_languageClient || !_languageClient.initialized || _languageClient.stopping || _languageClient.stopped)
			{
				return;
			}
			
			var params:Object = new Object();
			params.settings = getWorkspaceSettings();
			_languageClient.sendNotification(METHOD_WORKSPACE__DID_CHANGE_CONFIGURATION, params);
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
				if(popupWrapper)
				{
					PopUpManager.removePopUp(popupWrapper);
				}
				if(popup)
				{
					popup.data = null;
				}
			};
		}

		private function shutdown():void
		{
			if(!_languageClient || !_languageClient.initialized)
			{
				if (_languageClient)
				{
					cleanupLanguageClient();
				}
				if (_languageServerProcess)
				{
					_languageServerProcess.exit(true);
				}
				return;
			}
			_shutdownTimeoutID = setTimeout(shutdownTimeout, LANGUAGE_SERVER_SHUTDOWN_TIMEOUT);
			_languageClient.shutdown();
		}

		private function shutdownTimeout():void
		{
			_shutdownTimeoutID = uint.MAX_VALUE;
			if (!_languageServerProcess) {
				return;
			}
			var message:String = "Timed out while shutting down Java language server for project " + _project.name + ". Forcing process to exit.";
			warning(message);
			trace(message);
			_languageClient = null;
			_languageServerProcess.exit(true);
		}

		private function languageServerProcess_standardOutputDataHandler(e:ProgressEvent):void
		{
			var output:IDataInput = _languageServerProcess.standardOutput;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			if ( data.search(LANGUAGE_SERVER_PROCESS_FORMATTED_PID) > -1 ) {
				// Formatted PID found
				var a:Array = data.match(LANGUAGE_SERVER_PROCESS_FORMATTED_PID);
				var spid:String = a[ 0 ].split("%%%")[ 1 ];
				_pid = parseInt(spid);
				if ( _pid > 0 ) {
					// PID is set, we don't need the stdout handler anymore
					_languageServerProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, languageServerProcess_standardOutputDataHandler);
					LanguageServerGlobals.getInstance().addLanguageServerManager(this);
				}
			}
		}

		private function languageServerProcess_standardErrorDataHandler(e:ProgressEvent):void
		{
			var output:IDataInput = _languageServerProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			trace(data);
		}

		private function languageServerProcess_exitHandler(e:NativeProcessExitEvent):void
		{
			if (_shutdownTimeoutID != uint.MAX_VALUE) {
				clearTimeout(_shutdownTimeoutID);
				_shutdownTimeoutID = uint.MAX_VALUE;
			}
			if(_languageClient)
			{
				//this should have already happened, but if the process exits
				//abnormally, it might not have
				_languageClient.shutdown();
				
				warning("Java language server exited unexpectedly. Close the " + project.name + " project and re-open it to enable code intelligence.");
			}
			// if the language server didn't start correctly,
			// clear the active status bar animation
			_dispatcher.dispatchEvent(new StatusBarEvent(
				StatusBarEvent.LANGUAGE_SERVER_STATUS,
				project.name
			));
			LanguageServerGlobals.getInstance().removeLanguageServerManager(this);
			_languageServerProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, languageServerProcess_standardOutputDataHandler);
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
					error("Java JDK version " + MINIMUM_JAVA_MAJOR_VERSION + " or newer is required. Version not supported: " + this._javaVersion + ". Java code intelligence disabled for project: " + project.name + ".");
					return;
				}
				if (_useSocket)
				{
					startServerSocket();
				}
				else
				{
					startNativeProcess();
				}
			}
			else
			{
				error("Failed to load Java version. Java code intelligence disabled for project: " + project.name + ".");
			}
		}

		private function saveProjectSettingsHandler(event:ProjectEvent):void
		{
			if(event.project != _project)
			{
				return;
			}
			if (_project.jdkType != _previousJDKType)
			{
				restartLanguageServer();
			}
		}

		private function jdkPathSaveHandler(event:FilePluginEvent):void
		{
			//restart only when the path has changed
			var jdkPath:String = null;
			if (_model.javaPathForTypeAhead)
			{
				jdkPath = _model.javaPathForTypeAhead.fileBridge.nativePath
			}
			if(jdkPath != _previousJDKPath)
			{
				restartLanguageServer();
			}
		}

		private function jdk8PathSaveHandler(event:FilePluginEvent):void
		{
			if (_project.jdkType != JavaTypes.JAVA_8)
			{
				return;
			}
			var jdk8Path:String = (_model.java8Path != null) ? _model.java8Path.fileBridge.nativePath : null;
			//restart only when the path has changed
			if (jdk8Path != _previousJDK8Path)
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
			if(event.project != _project)
			{
				//it's for a different project
				return;
			}
			if(event.isDefaultPrevented())
			{
				//it's already handled somewhere else
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
					command_javaApplyWorkspaceEditHandler(event.arguments[0]);
					break;
				}
				default:
				{
					if(!_languageClient)
					{
						//not ready yet
						return;
					}

					// trace("command: " + event.command, JSON.stringify(event.arguments));
					_languageClient.executeCommand({
						command: event.command,
						arguments: event.arguments
					}, function(result:Object):void {
						event.result = result;
					});
				}
			}
		}

		private function languageClient_initHandler(event:Event):void
		{
			this.dispatchEvent(new Event(Event.INIT));
			sendWorkspaceSettings();
		}

		private function languageClient_closeHandler(event:Event):void
		{
			if(_waitingToCleanWorkspace)
			{
				cleanupClientSocket();
				cleanupServerSocket();
				cleanupLanguageClient();
				cleanWorkspace();
			}
			else if(_waitingToRestart)
			{
				cleanupClientSocket();
				cleanupServerSocket();
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

		private function languageClient_publishDiagnosticsHandler(event:LspNotificationEvent):void
		{
			var params:PublishDiagnosticsParams = PublishDiagnosticsParams(event.params);
			var uri:String = params.uri;
			var diagnostics:Array = params.diagnostics;
			_dispatcher.dispatchEvent(new DiagnosticsEvent(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, uri, project, diagnostics));
		}

		private function languageClient_registerCapabilityHandler(event:LspNotificationEvent):void
		{
			var params:RegistrationParams = RegistrationParams(event.params);
			var registrations:Array = params.registrations;
			for each(var registration:Registration in registrations)
			{
				var method:String = registration.method;
				switch(method)
				{
					case LanguageClient.METHOD_WORKSPACE__DID_CHANGE_WATCHED_FILES:
						var registerOptions:Object = registration.registerOptions;
						_watchedFiles[registration.id] = registerOptions.watchers.map(function(watcher:Object, index:int, source:Array):Object {
							return GlobPatterns.toRegExp(watcher.globPattern);
						});
						break;
				}
				_dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.LANGUAGE_SERVER_REGISTER_CAPABILITY, _project, method));
			}
		}

		private function languageClient_unregisterCapabilityHandler(event:LspNotificationEvent):void
		{
			var params:UnregistrationParams = UnregistrationParams(event.params);
			var unregistrations:Array = params.unregistrations;
			for each(var unregistration:Unregistration in unregistrations)
			{
				var method:String = unregistration.method;
				switch(method)
				{
					case LanguageClient.METHOD_WORKSPACE__DID_CHANGE_WATCHED_FILES:
						delete _watchedFiles[unregistration.id];
						break;
				}
				_dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.LANGUAGE_SERVER_UNREGISTER_CAPABILITY, _project, method));
			}
		}

		private function languageClient_logMessageHandler(event:LspNotificationEvent):void
		{
			var params:LogMessageParams = LogMessageParams(event.params);
			var message:String = params.message;
			var type:int = params.type;
			var eventType:String = null;
			switch(type)
			{
				case 1: //error
				{
					eventType = ConsoleOutputEvent.TYPE_ERROR;
					break;
				}
				default:
				{
					eventType = ConsoleOutputEvent.TYPE_INFO;
				}
			}
			_dispatcher.dispatchEvent(
				new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, message, false, false, eventType)
			);
			trace(message);
		}

		private function languageClient_showMessageHandler(event:LspNotificationEvent):void
		{
			var params:ShowMessageParams = ShowMessageParams(event.params);
			var message:String = params.message;
			var type:int = params.type;
			var eventType:String = null;
			switch(type)
			{
				case 1: //error
				{
					eventType = ConsoleOutputEvent.TYPE_ERROR;
					break;
				}
				default:
				{
					eventType = ConsoleOutputEvent.TYPE_INFO;
				}
			}
			
			Alert.show(message);
		}

		private function languageClient_applyEditHandler(event:LspNotificationEvent):void
		{
			var params:Object = event.params;
			var workspaceEdit:WorkspaceEdit = WorkspaceEdit(params.edit);
			applyWorkspaceEdit(workspaceEdit)
		}

		private function language__status(message:Object):void
		{
			if(_languageStatusDone)
			{
				return;
			}
			switch(message.params.type)
			{
				case "ServiceReady":
				{
					// hide the status bar message
					_languageStatusDone = true;
					GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
						StatusBarEvent.LANGUAGE_SERVER_STATUS,
						project.name
					));
					break;
				}
				case "Starting":
				{
					// display to the user in the status bar
					GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
						StatusBarEvent.LANGUAGE_SERVER_STATUS,
						project.name, message.params.message, false
					));
					break;
				}
				case "Message":
				{
					// display to the user in the status bar
					GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
						StatusBarEvent.LANGUAGE_SERVER_STATUS,
						project.name, message.params.message, false
					));
					break;
				}
				case "Started":
				{
					// display to the user in the status bar
					GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
						StatusBarEvent.LANGUAGE_SERVER_STATUS,
						project.name, message.params.message, false
					));
					break;
				}
				case "Error":
				{
					// hide the status bar message
					_languageStatusDone = true;
					GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
						StatusBarEvent.LANGUAGE_SERVER_STATUS,
						project.name
					));
					// probably best to at least log this for contributors
					// not sure if it should be shown to user, though
					trace("Error starting Java language server: " + message.params.message);
					break;
				}
				case "ProjectStatus":
				{
					if (message.params.message == "WARNING")
					{
						// no message to display to the user, but we should
						// probably log this for contributors
						trace("Warning: project status notification not OK");
					}
					break;
				}
				default:
				{
					trace("Unknown " + METHOD_LANGUAGE__STATUS + " message type:", message.params.type);
					break;
				}
			}
		}

		private function language__eventNotification(notification:Object):void
		{
			// we can ignore this for now
		}

		private function language__actionableNotification(notification:Object):void
		{
			var params:Object = notification.params;
			var severity:int = notification.severity as int;
			var message:String = params.message;
			var commands:Array = params.commands as Array;

			if(severity == MESSAGE_TYPE_LOG) //log
			{
				print(message);
				trace(message);
				return;
			}

			var popup:StandardPopupView = new StandardPopupView();
			popup.data = this; // Keep the command from getting GC'd
			popup.text = message;
			var popupWrapper:FeathersUIWrapper = new FeathersUIWrapper(popup);

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
				shutdown();
			}
			else
			{
				cleanWorkspace();
			}
		}

		private function command_javaApplyWorkspaceEditHandler(json:Object):void
		{
			var workspaceEdit:WorkspaceEdit = WorkspaceEdit.parse(json);
			applyWorkspaceEdit(workspaceEdit);
		}

		private function command_javaProjectConfigurationStatus(uri:Object, status:int):void
		{
			_settingUpdateBuildConfiguration = status;
			sendWorkspaceSettings();
		}

		private function removeProjectHandler(event:ProjectEvent):void
		{
			if(event.project != _project)
			{
				return;
			}
			shutdown();
		}

		private function applicationExitHandler(event:ApplicationEvent):void
		{
			shutdown();
		}

		private function isWatchingFile(file:FileLocation):Boolean
		{
			var relativePath:String = project.folderLocation.fileBridge.getRelativePath(file);
			var matchesPattern:Boolean = false;
			for(var id:String in _watchedFiles)
			{
				var watchers:Array = _watchedFiles[id];
				for each(var pattern:RegExp in watchers)
				{
					if(pattern.test(relativePath)) {
						return true;
					}
				}
			}
			return false;
		}

		private function handleWatchedFilesPendingChanges():void
		{
			_watchedFilesDebounceTimeoutID = uint.MAX_VALUE;
			if (_watchedFilesPendingChanges.length == 0)
			{
				return;
			}
			if (!_languageClient || !_languageClient.initialized || _languageClient.stopping || _languageClient.stopped)
			{
				return;
			}
			_languageClient.didChangeWatchedFiles(
			{
				changes: _watchedFilesPendingChanges
			});
			_watchedFilesPendingChanges = [];
		}

		private function queueWatchedFileChange(change:Object):void
		{
			_watchedFilesPendingChanges.push(change);
			if (_watchedFilesDebounceTimeoutID != uint.MAX_VALUE)
			{
				clearTimeout(_watchedFilesDebounceTimeoutID);
				_watchedFilesDebounceTimeoutID = uint.MAX_VALUE;
			}
			_watchedFilesDebounceTimeoutID = setTimeout(handleWatchedFilesPendingChanges, 500);
		}

		private function fileCreatedHandler(event:WatchedFileChangeEvent):void
		{
			if(!_languageClient || !isUriInProject(event.file.fileBridge.url, project) || !isWatchingFile(event.file))
			{
				return;
			}
			queueWatchedFileChange(
			{
				uri: event.file.fileBridge.url,
				type: 1
			});
		}

		private function fileDeletedHandler(event:WatchedFileChangeEvent):void
		{
			if(!_languageClient || !isUriInProject(event.file.fileBridge.url, project) || !isWatchingFile(event.file))
			{
				return;
			}
			queueWatchedFileChange(
			{
				uri: event.file.fileBridge.url,
				type: 3
			});
		}

		private function fileModifiedHandler(event:WatchedFileChangeEvent):void
		{
			if(!_languageClient || !isUriInProject(event.file.fileBridge.url, project) || !isWatchingFile(event.file))
			{
				return;
			}
			queueWatchedFileChange(
			{
				uri: event.file.fileBridge.url,
				type: 2
			});
		}

		private function serverSocket_connectHandler(event:ServerSocketConnectEvent):void
		{
			// we need only one client socket
			_serverSocket.close();
			cleanupServerSocket();

			_clientSocket = event.socket;
			_clientSocket.addEventListener(IOErrorEvent.IO_ERROR, clientSocket_ioErrorHandler);
			_clientSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, clientSocket_securityErrorHandler);
            _clientSocket.addEventListener(Event.CLOSE, clientSocket_closeHandler);
			
			initializeLanguageServer(_previousJDKPath);
		}

		private function clientSocket_ioErrorHandler(event:IOErrorEvent):void
		{
			error("ioError " + event.text);
		}

		private function clientSocket_securityErrorHandler(event:SecurityErrorEvent):void
		{
			error("securityError " + event.text);
		}

		private function clientSocket_closeHandler(event:Event):void
		{
			cleanupClientSocket();
		}
	}
}
