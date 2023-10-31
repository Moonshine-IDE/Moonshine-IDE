package actionScripts.plugins.tibbo
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;

	import mx.controls.Alert;

	import actionScripts.events.ApplicationEvent;
	import actionScripts.events.DiagnosticsEvent;
	import actionScripts.events.ExecuteLanguageServerCommandEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.SaveFileEvent;
	import actionScripts.events.SdkEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.events.WatchedFileChangeEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.languageServer.ILanguageServerManager;
	import actionScripts.languageServer.LanguageClientUtil;
	import actionScripts.languageServer.LanguageServerGlobals;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.plugin.tibbo.tibboproject.vo.TibboBasicProjectVO;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.editor.LanguageServerTextEditor;
	import actionScripts.ui.tabview.TabEvent;
	import actionScripts.utils.CommandLineUtil;
	import actionScripts.utils.EnvironmentSetupUtils;
	import actionScripts.utils.GlobPatterns;
	import actionScripts.utils.UtilsCore;
	import actionScripts.utils.applyWorkspaceEdit;
	import actionScripts.utils.isUriInProject;
	import actionScripts.valueObjects.EnvironmentExecPaths;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.Settings;

	import com.adobe.utils.StringUtil;

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
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import actionScripts.plugin.tibbo.tibboproject.vo.TibboBasicProjectVO;

	[Event(name="init",type="flash.events.Event")]
	[Event(name="close",type="flash.events.Event")]

	public class TibboBasicLanguageServerManager extends ConsoleOutputter implements ILanguageServerManager
	{
		private static const LANGUAGE_SERVER_ROOT_PATH:String = "elements/tbls";
		private static const LANGUAGE_SERVER_SCRIPT_PATH:String = LANGUAGE_SERVER_ROOT_PATH + "/moonshine-basic.js";
		
		private static const LANGUAGE_ID:String = "tibbo-basic";
		
		private static const URI_SCHEME_FILE:String = "file";

		private static const URI_SCHEMES:Vector.<String> = new <String>[];
		private static const FILE_EXTENSIONS:Vector.<String> = new <String>[
			"tbs",
			"tbh",
			"tph",
			"tpr"
		];

		private static const LANGUAGE_SERVER_SHUTDOWN_TIMEOUT:Number = 8000;

		private static const LANGUAGE_SERVER_PROCESS_FORMATTED_PID:RegExp = new RegExp( /(%%%[0-9]+%%%)/ );

		private var _project:TibboBasicProjectVO;
		private var _languageClient:LanguageClient;
		private var _model:IDEModel = IDEModel.getInstance();
		private var _dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var _languageServerProcess:NativeProcess;
		private var _waitingToRestart:Boolean = false;
		private var _waitingToDispose:Boolean = false;
		private var _previousNodePath:String = null;
		private var _displayArguments:String = null;
		private var _languageServerProgressStarted:Boolean = false;
		private var _activeProgressTokens:Array = [];
		private var _watchedFiles:Object = {};
		private var _shutdownTimeoutID:uint = uint.MAX_VALUE;
		private var _pid:int = -1;
		private var _watchedFilesDebounceTimeoutID:uint = uint.MAX_VALUE;
		private var _watchedFilesPendingChanges:Array = [];

		public function TibboBasicLanguageServerManager(project:TibboBasicProjectVO)
		{
			_project = project;

			_dispatcher.addEventListener(SdkEvent.CHANGE_NODE_SDK, changeNodeSDKHandler, false, 0, true);
			_dispatcher.addEventListener(ProjectEvent.SAVE_PROJECT_SETTINGS, saveProjectSettingsHandler, false, 0, true);
			_dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, removeProjectHandler, false, 0, true);
			_dispatcher.addEventListener(ApplicationEvent.APPLICATION_EXIT, applicationExitHandler, false, 0, true);
			_dispatcher.addEventListener(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, executeLanguageServerCommandHandler, false, 0, true);
			_dispatcher.addEventListener(WatchedFileChangeEvent.FILE_CREATED, fileCreatedHandler);
			_dispatcher.addEventListener(WatchedFileChangeEvent.FILE_DELETED, fileDeletedHandler);
			_dispatcher.addEventListener(WatchedFileChangeEvent.FILE_MODIFIED, fileModifiedHandler);
			//when adding new listeners, don't forget to also remove them in
			//dispose()

			LanguageServerGlobals.getInstance().addLanguageServerManager( this );

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

			var editor:LanguageServerTextEditor = new LanguageServerTextEditor(LANGUAGE_ID, _project, readOnly);
			editor.editor.allowToggleBreakpoints = true;
			if(scheme == URI_SCHEME_FILE)
			{
				//the regular OpenFileEvent should be used to open this one
				return editor;
			}
			switch(scheme)
			{
				default:
				{
					throw new URIError("Unknown URI scheme for Basic: " + scheme);
				}
			}
			return editor;
		}

		protected function dispose():void
		{
			_dispatcher.removeEventListener(SdkEvent.CHANGE_NODE_SDK, changeNodeSDKHandler);
			_dispatcher.removeEventListener(ProjectEvent.SAVE_PROJECT_SETTINGS, saveProjectSettingsHandler);
			_dispatcher.removeEventListener(ProjectEvent.REMOVE_PROJECT, removeProjectHandler);
			_dispatcher.removeEventListener(ApplicationEvent.APPLICATION_EXIT, applicationExitHandler);
			_dispatcher.removeEventListener(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, executeLanguageServerCommandHandler);
			_dispatcher.removeEventListener(WatchedFileChangeEvent.FILE_CREATED, fileCreatedHandler);
			_dispatcher.removeEventListener(WatchedFileChangeEvent.FILE_DELETED, fileDeletedHandler);
			_dispatcher.removeEventListener(WatchedFileChangeEvent.FILE_MODIFIED, fileModifiedHandler);

			cleanupLanguageClient();
		}

		protected function cleanupLanguageClient():void
		{
			if(!_languageClient)
			{
				return;
			}
			if(_languageServerProgressStarted)
			{
				//if we had a progress message, clean it up
				_dispatcher.dispatchEvent(new StatusBarEvent(
					StatusBarEvent.LANGUAGE_SERVER_STATUS,
					project.name
				));
			}
			_languageServerProgressStarted = false;
			_languageClient.removeEventListener(Event.INIT, languageClient_initHandler);
			_languageClient.removeEventListener(Event.CLOSE, languageClient_closeHandler);
			_languageClient.removeEventListener(LspNotificationEvent.PUBLISH_DIAGNOSTICS, languageClient_publishDiagnosticsHandler);
			_languageClient.removeEventListener(LspNotificationEvent.REGISTER_CAPABILITY, languageClient_registerCapabilityHandler);
			_languageClient.removeEventListener(LspNotificationEvent.UNREGISTER_CAPABILITY, languageClient_unregisterCapabilityHandler);
			_languageClient.removeEventListener(LspNotificationEvent.LOG_MESSAGE, languageClient_logMessageHandler);
			_languageClient.removeEventListener(LspNotificationEvent.SHOW_MESSAGE, languageClient_showMessageHandler);
			_languageClient.removeEventListener(LspNotificationEvent.APPLY_EDIT, languageClient_applyEditHandler);
			_languageClient = null;
			
			LanguageServerGlobals.getInstance().removeLanguageServerManager( this );
			LanguageServerGlobals.getInstance().dispatchEvent( new Event( Event.REMOVED ) );
			
		}
		
		private function bootstrapThenStartNativeProcess():void
		{
			if(!UtilsCore.isNodeAvailable())
			{
				_previousNodePath = null;
				warning("Tibbo Basic language code intelligence disabled. To enable, update Node.js location in application settings.");
				return;
			}
			startNativeProcess();
		}

		private function startNativeProcess():void
		{
			if(_languageServerProcess)
			{
				// the process for the language server wasn't cleaned up
				// properly before trying to start a new one...
				trace("Error: Tibbo Basic language server process already exists for project: " + project.name);
				return;
			}
			if(!UtilsCore.isNodeAvailable())
			{
				return;
			}

			var nodePath:String = UtilsCore.getNodeBinPath();
			_previousNodePath = nodePath;

			var scriptFile:File = File.applicationDirectory.resolvePath(LANGUAGE_SERVER_SCRIPT_PATH);
			var languageServerCommand:Vector.<String> = new <String>[
				nodePath,
				// uncomment --inspect to allow devtools debugging of the Node.js script
				// "--inspect",
				scriptFile.nativePath,
				"--stdio"
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

				_languageServerProcess = new NativeProcess();
				_languageServerProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, languageServerProcess_standardOutputDataHandler);
				_languageServerProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, languageServerProcess_standardErrorDataHandler);
				_languageServerProcess.addEventListener(NativeProcessExitEvent.EXIT, languageServerProcess_exitHandler);
				_languageServerProcess.start(processInfo);
				// initializeLanguageServer();
			}, null, [CommandLineUtil.joinOptions(languageServerCommand)]);
		}
		
		private function initializeLanguageServer():void
		{
			if(_languageClient)
			{
				// the language server is already initializing or initialized...
				trace("Error: Tibbo Basic language client already exists for project: " + project.name);
				return;
			}

			trace("Tibbo Basic language server workspace root: " + project.folderPath);

			var sendMethodResults:Boolean = false;
			var initOptions:Object = {
				platformsPath: "Platforms"
			};

			var debugMode:Boolean = false;
			_languageClient = new LanguageClient(LANGUAGE_ID,
				_languageServerProcess.standardOutput, _languageServerProcess, ProgressEvent.STANDARD_OUTPUT_DATA,
				_languageServerProcess.standardInput);
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
			_languageServerProgressStarted = false;
			_languageClient.addNotificationListener("$/progress", dollar__progress);
			_languageClient.addNotificationListener("window/workDoneProgress/create", window__workDoneProgress__create);
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
			var message:String = "Timed out while shutting down Tibbo Basic language server for project " + _project.name + ". Forcing process to exit.";
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
					LanguageServerGlobals.getInstance().dispatchEvent( new Event( Event.ADDED ) );
					initializeLanguageServer();
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
				
				warning("Tibbo Basic language server exited unexpectedly. Close the " + project.name + " project and re-open it to enable code intelligence.");
			}
			LanguageServerGlobals.getInstance().dispatchEvent( new Event( Event.REMOVED ) );
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

		private function changeNodeSDKHandler(event:SdkEvent):void
		{
			if(UtilsCore.getNodeBinPath() != _previousNodePath)
			{
				restartLanguageServer();
			}
		}

		private function saveProjectSettingsHandler(event:ProjectEvent):void
		{
			var needsRestart:Boolean = false;

			// if a setting change requires the language server to restart,
			// do it here

			if(needsRestart)
			{
				restartLanguageServer();
			}
		}

		private function languageClient_initHandler(event:Event):void
		{
			this.dispatchEvent(new Event(Event.INIT));
		}

		private function languageClient_closeHandler(event:Event):void
		{
			if(_waitingToRestart)
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

		private function window__workDoneProgress__create(message:Object):void
		{
			var token:Object = message.params.token;
			this._activeProgressTokens.push(token);
		}

		private function dollar__progress(message:Object):void
		{
			var token:Object = message.params.token;
			var value:Object = message.params.value;
			var tokenIndex:int = this._activeProgressTokens.indexOf(token);
			if(tokenIndex == -1)
			{
				return;
			}

			switch(value.kind)
			{
				case "end":
				{
					this._activeProgressTokens.splice(tokenIndex, 1);
					_dispatcher.dispatchEvent(new StatusBarEvent(
						StatusBarEvent.LANGUAGE_SERVER_STATUS,
						project.name
					));
					break;
				}
				case "begin":
				{
					_dispatcher.dispatchEvent(new StatusBarEvent(
						StatusBarEvent.LANGUAGE_SERVER_STATUS,
						project.name, value.title, false
					));
					break;
				}
				default:
					trace("Unknown progress message: " + JSON.stringify(message));
				
			}
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
	}
}
