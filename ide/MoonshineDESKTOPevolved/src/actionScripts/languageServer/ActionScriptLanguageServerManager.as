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
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.filesystem.File;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.utils.IDataInput;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import mx.controls.Alert;

	import actionScripts.events.ApplicationEvent;
	import actionScripts.events.DiagnosticsEvent;
	import actionScripts.events.EditorPluginEvent;
	import actionScripts.events.ExecuteLanguageServerCommandEvent;
	import actionScripts.events.FilePluginEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.SdkEvent;
	import actionScripts.events.SettingsEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.events.WatchedFileChangeEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.actionscript.as3project.vo.BuildOptions;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.ui.editor.ActionScriptTextEditor;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.utils.CommandLineUtil;
	import actionScripts.utils.EnvironmentSetupUtils;
	import actionScripts.utils.GlobPatterns;
	import actionScripts.utils.UtilsCore;
	import actionScripts.utils.applyWorkspaceEdit;
	import actionScripts.utils.FindOpenPort;
	import actionScripts.utils.getProjectSDKPath;
	import actionScripts.utils.isUriInProject;
	import actionScripts.valueObjects.EnvironmentExecPaths;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.Settings;

	import com.adobe.utils.StringUtil;

	import moonshine.lsp.ApplyWorkspaceEditParams;
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

	[Event(name="init",type="flash.events.Event")]
	[Event(name="close",type="flash.events.Event")]
	public class ActionScriptLanguageServerManager extends ConsoleOutputter implements ILanguageServerManager
	{
		private static const LANGUAGE_SERVER_BIN_PATH:String = "elements/as3mxml-language-server/bin/";
		private static const BUNDLED_COMPILER_PATH:String = "elements/as3mxml-language-server/bundled-compiler/";
		private static const LANGUAGE_ID_ACTIONSCRIPT:String = "nextgenas";
		private static const METHOD_WORKSPACE__DID_CHANGE_CONFIGURATION:String = "workspace/didChangeConfiguration";
		private static const METHOD_MOONSHINE__DID_CHANGE_PROJECT_CONFIGURATION:String = "moonshine/didChangeProjectConfiguration";

		private static const URI_SCHEME_FILE:String = "file";
		private static const URI_SCHEME_SWC:String = "swc";

		private static const URI_SCHEMES:Vector.<String> = new <String>[URI_SCHEME_SWC];
		private static const FILE_EXTENSIONS:Vector.<String> = new <String>["as", "mxml"];

		private static const LANGUAGE_SERVER_SHUTDOWN_TIMEOUT:Number = 8000;

		private static const LANGUAGE_SERVER_PROCESS_FORMATTED_PID:RegExp = new RegExp( /(%%%[0-9]+%%%)/ );

		private var _project:AS3ProjectVO;
		private var _port:int;
		private var _languageClient:LanguageClient;
		private var _model:IDEModel = IDEModel.getInstance();
		private var _dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var _useSocket:Boolean = false;
		private var _languageServerProcess:NativeProcess;
		private var _javaVersionProcess:NativeProcess;
		private var _waitingToRestart:Boolean = false;
		private var _previousJavaPath:String = null;
		private var _previousSDKPath:String = null;
		private var _javaVersion:String = null;
		private var _waitingToDispose:Boolean = false;
		private var _watchedFiles:Object = {};
		private var _shutdownTimeoutID:uint = uint.MAX_VALUE;
		private var _serverSocket:ServerSocket;
		private var _clientSocket:Socket;
		private var _pid:int = -1;

		public function ActionScriptLanguageServerManager(project:AS3ProjectVO)
		{
			_project = project;

			_project.addEventListener(AS3ProjectVO.CHANGE_CUSTOM_SDK, projectChangeCustomSDKHandler);
			_dispatcher.addEventListener(ProjectEvent.SAVE_PROJECT_SETTINGS, saveProjectSettingsHandler, false, 0, true);
			_dispatcher.addEventListener(SdkEvent.CHANGE_SDK, changeMenuSDKStateHandler, false, 0, true);
			_dispatcher.addEventListener(FilePluginEvent.EVENT_JAVA_TYPEAHEAD_PATH_SAVE, javaPathSaveHandler, false, 0, true);
			_dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, removeProjectHandler, false, 0, true);
			_dispatcher.addEventListener(ApplicationEvent.APPLICATION_EXIT, applicationExitHandler, false, 0, true);
			_dispatcher.addEventListener(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, executeLanguageServerCommandHandler, false, 0, true);
			_dispatcher.addEventListener(WatchedFileChangeEvent.FILE_CREATED, fileCreatedHandler);
			_dispatcher.addEventListener(WatchedFileChangeEvent.FILE_DELETED, fileDeletedHandler);
			_dispatcher.addEventListener(WatchedFileChangeEvent.FILE_MODIFIED, fileModifiedHandler);
			//when adding new listeners, don't forget to also remove them in
			//dispose()

			LanguageServerGlobals.addLanguageServerManager( this );

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

			var editor:ActionScriptTextEditor = new ActionScriptTextEditor(_project, readOnly);
			if(scheme == URI_SCHEME_FILE)
			{
				//the regular OpenFileEvent should be used to open this one
				return editor;
			}
			switch(scheme)
			{
				case URI_SCHEME_SWC:
				{
					var label:String = uri;
					var args:String = null;
					var argsIndex:int = uri.indexOf("?");
					if(argsIndex != -1)
					{
						label = uri.substr(0, argsIndex);
						args = uri.substr(argsIndex + 1);
					}
					var lastSlashIndex:int = label.lastIndexOf("/");
					if(lastSlashIndex != -1)
					{
						label = label.substr(lastSlashIndex + 1);
					}
					args = decodeURIComponent(args);

					var extension:String = "";
					var dotIndex:int = label.lastIndexOf(".");
					if(dotIndex != -1)
					{
						extension = label.substr(dotIndex + 1);
					}
					editor.defaultLabel = label;

					var editorEvent:EditorPluginEvent = new EditorPluginEvent(EditorPluginEvent.EVENT_EDITOR_OPEN);
					editorEvent.editor = editor.getEditorComponent();
					editorEvent.fileExtension = extension;
					GlobalEventDispatcher.getInstance().dispatchEvent(editorEvent);

					//editor.open() must be called after EditorPluginEvent.EVENT_EDITOR_OPEN
					//is dispatched or the syntax highlighting will not work
					editor.open(null, args);
					break;
				}
				default:
				{
					throw new URIError("Unknown URI scheme for ActionScript and MXML: " + scheme);
				}
			}
			return editor;
		}

		protected function dispose():void
		{
			cleanupClientSocket();
			cleanupServerSocket();
			cleanupLanguageClient();
			
			_project.removeEventListener(AS3ProjectVO.CHANGE_CUSTOM_SDK, projectChangeCustomSDKHandler);
			_dispatcher.removeEventListener(ProjectEvent.SAVE_PROJECT_SETTINGS, saveProjectSettingsHandler);
			_dispatcher.removeEventListener(SdkEvent.CHANGE_SDK, changeMenuSDKStateHandler);
			_dispatcher.removeEventListener(FilePluginEvent.EVENT_JAVA_TYPEAHEAD_PATH_SAVE, javaPathSaveHandler);
			_dispatcher.removeEventListener(ProjectEvent.REMOVE_PROJECT, removeProjectHandler);
			_dispatcher.removeEventListener(ApplicationEvent.APPLICATION_EXIT, applicationExitHandler);
			_dispatcher.removeEventListener(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, executeLanguageServerCommandHandler);
			_dispatcher.removeEventListener(WatchedFileChangeEvent.FILE_CREATED, fileCreatedHandler);
			_dispatcher.removeEventListener(WatchedFileChangeEvent.FILE_DELETED, fileDeletedHandler);
			_dispatcher.removeEventListener(WatchedFileChangeEvent.FILE_MODIFIED, fileModifiedHandler);

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
			_languageClient.removeEventListener(Event.INIT, languageClient_initHandler);
			_languageClient.removeEventListener(Event.CLOSE, languageClient_closeHandler);
			_languageClient.removeEventListener(LspNotificationEvent.PUBLISH_DIAGNOSTICS, languageClient_publishDiagnosticsHandler);
			_languageClient.removeEventListener(LspNotificationEvent.REGISTER_CAPABILITY, languageClient_registerCapabilityHandler);
			_languageClient.removeEventListener(LspNotificationEvent.UNREGISTER_CAPABILITY, languageClient_unregisterCapabilityHandler);
			_languageClient.removeEventListener(LspNotificationEvent.LOG_MESSAGE, languageClient_logMessageHandler);
			_languageClient.removeEventListener(LspNotificationEvent.SHOW_MESSAGE, languageClient_showMessageHandler);
			_languageClient.removeEventListener(LspNotificationEvent.APPLY_EDIT, languageClient_applyEditHandler);
			_languageClient = null;
			
			LanguageServerGlobals.removeLanguageServerManager( this );
			LanguageServerGlobals.getEventDispatcher().dispatchEvent( new Event( Event.REMOVED ) );
		}
		

		private function cleanupServerSocket():void
		{
			if (!_serverSocket)
			{
				return;
			}
			_serverSocket.removeEventListener(Event.CONNECT, serverSocket_connectHandler);
			_serverSocket = null;
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
			if(major < 9)
			{
				var minor:Number = versionNumberParts[1];
				if(major != 1 || minor < 8)
				{
					return false;
				}
			}
			return true;
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
				trace("Error: AS3 & MXML language server process already exists!");
				return;
			}
			var jdkFolder:File = null;
			if(_model.javaPathForTypeAhead)
			{
				jdkFolder = _model.javaPathForTypeAhead.fileBridge.getFile as File;
			}
			var sdkPath:String = getProjectSDKPath(_project, _model);
			if(!jdkFolder || !sdkPath)
			{
				//we'll need to try again later if the settings change
				_previousJavaPath = null;
				_previousSDKPath = null;
				return;
			}
			_previousJavaPath = jdkFolder.nativePath;
			_previousSDKPath = sdkPath;

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

			var frameworksPath:String = (new File(sdkPath)).resolvePath("frameworks").nativePath;

			var cp:String = File.applicationDirectory.resolvePath(LANGUAGE_SERVER_BIN_PATH).nativePath + File.separator + "*";
			if (Settings.os == "win")
			{
				cp += ";"
			}
			else
			{
				cp += ":";
			}
			cp += File.applicationDirectory.resolvePath(BUNDLED_COMPILER_PATH).nativePath + File.separator + "*";

			var languageServerCommand:Vector.<String> = new <String>[
				cmdFile.nativePath,
				"-Dfile.encoding=UTF8",
				"-Xmx2g",
				"-Droyalelib=" + frameworksPath,
				"-cp",
				cp,
				"moonshine.Main"
			];
			if (_useSocket)
			{
				languageServerCommand.insertAt(2, "-Dmoonshine.port=" + _port);
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
					initializeLanguageServer(sdkPath);
				}
				
				GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
					StatusBarEvent.LANGUAGE_SERVER_STATUS,
					project.name, "Starting ActionScript & MXML code intelligence..."
				));
			}, null, [CommandLineUtil.joinOptions(languageServerCommand)]);
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
		
		private function initializeLanguageServer(sdkPath:String):void
		{
			if(_languageClient)
			{
				//we're already initializing or initialized...
				trace("Error: AS3 & MXML language client already exists!");
				return;
			}

			trace("AS3 & MXML language server workspace root: " + project.folderPath);
			trace("AS3 & MXML language server SDK: " + sdkPath);

			var debugMode:Boolean = false;
			var initOptions:Object = {
				config: getProjectConfiguration(),
				supportsSimpleSnippets: true
			};
			if (_useSocket)
			{
				_languageClient = new LanguageClient(LANGUAGE_ID_ACTIONSCRIPT,
					_clientSocket, _clientSocket, ProgressEvent.SOCKET_DATA, _clientSocket, flushSocket);
			}
			else
			{
				_languageClient = new LanguageClient(LANGUAGE_ID_ACTIONSCRIPT,
					_languageServerProcess.standardOutput, _languageServerProcess, ProgressEvent.STANDARD_OUTPUT_DATA,
					_languageServerProcess.standardInput);
			}
			_languageClient.debugMode = debugMode;
			_languageClient.registerUriScheme("swc");
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
			_project.languageClient = _languageClient;

			var initParams:Object = LanguageClientUtil.getSharedInitializeParams();
			initParams.initializationOptions = initOptions;
			_languageClient.initialize(initParams);
		}
	
		private function flushSocket():void
		{
			if(!_clientSocket)
			{
				return;
			}
			_clientSocket.flush();
		}

		private function restartLanguageServer():void
		{
			if(_waitingToRestart)
			{
				//we'll just continue waiting
				return;
			}
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

		private function getProjectConfiguration():Object
		{
			var type:String = "app";
			if(_project.isLibraryProject)
			{
				type = "lib";
			}
			var config:String = "flex";
			if(_project.air)
			{
				if(_project.isMobile)
				{
					config = "airmobile";
				}
				else
				{
					config = "air";
				}
			}
			else if (_project.isRoyale)
			{
				config = "royale";
			}

			//the config file may not exist, or it may be out of date, so
			//we're going to tell the project to update it immediately
			_project.updateConfig();
			var buildOptions:BuildOptions = _project.buildOptions;
			if(_project.config.file)
			{
				var projectPath:File = new File(project.folderLocation.fileBridge.nativePath);
				var configPath:File = new File(_project.config.file.fileBridge.nativePath);
				var buildArgs:String = "-load-config+=" +
					projectPath.getRelativePath(configPath, true) +
					" " +
					buildOptions.getArguments();
			}
			else
			{
				buildArgs = buildOptions.getArguments();
			}
				
			var files:Array = [];
			var filesCount:int = _project.targets.length;
			for(var i:int = 0; i < filesCount; i++)
			{
				var file:String = _project.targets[i].fileBridge.nativePath;
				files[i] = file;
			}

			//all of the compiler options are actually included in buildArgs,
			//but the language server needs to be able to read some of them more
			//easily, so we pass them in manually
			var compilerOptions:Object = {};
			var sourcePathCount:int = _project.classpaths.length;
			if(sourcePathCount > 0)
			{
				var sourcePaths:Array = [];
				for(i = 0; i < sourcePathCount; i++)
				{
					var sourcePath:String = _project.classpaths[i].fileBridge.nativePath;
					sourcePaths[i] = sourcePath;
				}
				compilerOptions["source-path"] = sourcePaths;
			}

			//this object is designed to be similar to the asconfig.json
			//format used by vscode-as3mxml
			//https://github.com/BowlerHatLLC/vscode-as3mxml/wiki/asconfig.json
			//https://github.com/BowlerHatLLC/vscode-as3mxml/blob/master/distribution/src/assembly/schemas/asconfig.schema.json
			var params:Object = new Object();
			params.type = type;
			params.config = config;
			params.files = files;
			params.compilerOptions = compilerOptions;
			params.additionalOptions = buildArgs;
			return params;
		}

		private function sendProjectConfiguration():void
		{
			if(!_languageClient || !_languageClient.initialized || _languageClient.stopping || _languageClient.stopped)
			{
				return;
			}
			var params:Object = this.getProjectConfiguration();
			_languageClient.sendNotification(METHOD_MOONSHINE__DID_CHANGE_PROJECT_CONFIGURATION, params);
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
			var message:String = "Timed out while shutting down ActionScript & MXML language server for project " + _project.name + ". Forcing process to exit.";
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
					LanguageServerGlobals.getEventDispatcher().dispatchEvent( new Event( Event.ADDED ) );
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
				
				warning("ActionScript & MXML language server exited unexpectedly. Close the " + project.name + " project and re-open it to enable code intelligence.");
			}
			LanguageServerGlobals.getEventDispatcher().dispatchEvent( new Event( Event.REMOVED ) );
			_languageServerProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, languageServerProcess_standardOutputDataHandler);
			_languageServerProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, languageServerProcess_standardErrorDataHandler);
			_languageServerProcess.removeEventListener(NativeProcessExitEvent.EXIT, languageServerProcess_exitHandler);
			_languageServerProcess.exit();
			_languageServerProcess = null;
			if(_waitingToRestart)
			{
				_waitingToRestart = false;
				bootstrapThenStartNativeProcess();
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
					error("Java version 8 or newer is required. Version not supported: " + this._javaVersion + ". ActionScript & MXML code intelligence disabled for project: " + project.name + ".");
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
				error("Failed to load Java version. ActionScript & MXML code intelligence disabled for project: " + project.name + ".");
			}
		}

		private function languageClient_initHandler(event:Event):void
		{	
			this.dispatchEvent(new Event(Event.INIT));
			
			GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
				StatusBarEvent.LANGUAGE_SERVER_STATUS,
				project.name
			));
		}

		private function languageClient_closeHandler(event:Event):void
		{
			if(_waitingToRestart)
			{
				cleanupClientSocket();
				cleanupServerSocket();
				cleanupLanguageClient();
				//the native process will automatically exit, so we continue
				//waiting for that to complete
			}
			else
			{
				this.dispose();
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
			var params:ApplyWorkspaceEditParams = ApplyWorkspaceEditParams(event.params);
			var workspaceEdit:WorkspaceEdit = params.edit;
			applyWorkspaceEdit(workspaceEdit);
		}

		private function projectChangeCustomSDKHandler(event:Event):void
		{
			//restart only when the path has changed
			if(getProjectSDKPath(_project, _model) != _previousSDKPath)
			{
				restartLanguageServer();
			}
		}

		private function changeMenuSDKStateHandler(event:Event):void
		{
			//restart only when the path has changed
			if(getProjectSDKPath(_project, _model) != _previousSDKPath)
			{
				restartLanguageServer();
			}
		}

		private function javaPathSaveHandler(event:FilePluginEvent):void
		{
			var javaPath:String = null;
			if(_model.javaPathForTypeAhead)
			{
				var javaFile:File = _model.javaPathForTypeAhead.fileBridge.getFile as File;
				javaPath = javaFile.nativePath;
			}
			//restart only when the path has changed
			if(javaPath != _previousJavaPath)
			{
				restartLanguageServer();
			}
		}
		
		private function saveProjectSettingsHandler(event:ProjectEvent):void
		{
			if(event.project !== _project)
			{
				return;
			}
			sendProjectConfiguration();
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
			if(!_languageClient)
			{
				//not ready yet
				return;
			}

			_languageClient.executeCommand({
				command: event.command,
				arguments: event.arguments
			}, function(result:Object):void {
				event.result = result;
			});
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

		private function fileCreatedHandler(event:WatchedFileChangeEvent):void
		{
			if(!_languageClient || !isUriInProject(event.file.fileBridge.url, project) || !isWatchingFile(event.file))
			{
				return;
			}
			_languageClient.didChangeWatchedFiles({
				changes: [
					{
						uri: event.file.fileBridge.url,
						type: 1
					}
				]
			});
		}

		private function fileDeletedHandler(event:WatchedFileChangeEvent):void
		{
			if(!_languageClient || !isUriInProject(event.file.fileBridge.url, project) || !isWatchingFile(event.file))
			{
				return;
			}
			_languageClient.didChangeWatchedFiles({
				changes: [
					{
						uri: event.file.fileBridge.url,
						type: 3
					}
				]
			});
		}

		private function fileModifiedHandler(event:WatchedFileChangeEvent):void
		{
			if(!_languageClient || !isUriInProject(event.file.fileBridge.url, project) || !isWatchingFile(event.file))
			{
				return;
			}
			_languageClient.didChangeWatchedFiles({
				changes: [
					{
						uri: event.file.fileBridge.url,
						type: 2
					}
				]
			});
		}

		private function serverSocket_connectHandler(event:ServerSocketConnectEvent):void
		{
			_clientSocket = event.socket;
			_clientSocket.addEventListener(IOErrorEvent.IO_ERROR, clientSocket_ioErrorHandler);
			_clientSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, clientSocket_securityErrorHandler);
            _clientSocket.addEventListener(Event.CLOSE, clientSocket_closeHandler);
			
			initializeLanguageServer(_previousSDKPath);
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
