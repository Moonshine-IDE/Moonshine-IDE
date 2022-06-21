package actionScripts.languageServer
{
    import actionScripts.languageServer.ILanguageServerManager;
    import flash.events.Event;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.ui.editor.LotusBasicTextEditor;
    import moonshine.lsp.LanguageClient;
    import actionScripts.plugin.basic.vo.BasicProjectVO;

    [Event(name="init",type="flash.events.Event")]
	[Event(name="close",type="flash.events.Event")]
	public class BasicLanguageServerManager  implements ILanguageServerManager
	
	{
		
		private static const FILE_EXTENSIONS:Vector.<String> = new <String>["tibbo"];
		private static const URI_SCHEMES:Vector.<String> = new <String>[];
		private static const LANGUAGE_ID_BASIC:String = "basic";
		private var _languageClient:LanguageClient;
		private var _project:BasicProjectVO;
		private var _dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var _waitingToRestart:Boolean = false;
		private var _languageServerProcess:NativeProcess;
		private var _previousNodePath:String = null;
		
		public function BasicLanguageServerManager (project:BasicProjectVO)
		{
			this._project=project;
			_dispatcher.addEventListener(WatchedFileChangeEvent.FILE_CREATED, fileCreatedHandler);
			_dispatcher.addEventListener(WatchedFileChangeEvent.FILE_DELETED, fileDeletedHandler);
			_dispatcher.addEventListener(WatchedFileChangeEvent.FILE_MODIFIED, fileModifiedHandler);
			_dispatcher.addEventListener(ProjectEvent.SAVE_PROJECT_SETTINGS, saveProjectSettingsHandler, false, 0, true);
			_dispatcher.addEventListener(SaveFileEvent.FILE_SAVED, fileSavedHandler);
			_dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, removeProjectHandler, false, 0, true);
			_dispatcher.addEventListener(ApplicationEvent.APPLICATION_EXIT, applicationExitHandler, false, 0, true);
			_dispatcher.addEventListener(SdkEvent.CHANGE_NODE_SDK, changeNodeSDKHandler, false, 0, true);
			_dispatcher.addEventListener(TabEvent.EVENT_TAB_SELECT, tabSelectHandler, false, 0, true);
			_dispatcher.addEventListener(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, executeLanguageServerCommandHandler, false, 0, true);
			
		}
		
		private function initializeLanguageServer():void
		{
			if(_languageClient)
			{
				//we're already initializing or initialized...
				trace("Error: Basic language client already exists!");
				return;
			}

			trace("Basic language server workspace root: " + project.folderPath);
			

			var debugMode:Boolean = false;
			_languageClient = new LanguageClient(LANGUAGE_ID_BASIC,
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
			_project.languageClient = _languageClient;

			var initParams:Object = LanguageClientUtil.getSharedInitializeParams();
			_languageClient.initialize(initParams);
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
		
		private function tabSelectHandler(event:TabEvent):void
		{
			var textEditor:BasicTextEditor = event.child as BasicTextEditor;
			if(!textEditor || !textEditor.currentFile)
			{
				return;
			}
			if(!_languageClient || !_languageClient.initialized)
			{
				return;
			}
			_languageClient.sendNotification("basic/didChangeActiveTextEditor", {uri: textEditor.currentFile.fileBridge.url});
		}
		
		private function changeNodeSDKHandler(event:SdkEvent):void
		{
			if(UtilsCore.getNodeBinPath() != _previousNodePath)
			{
				restartLanguageServer();
			}
		}
		
		private function applicationExitHandler(event:ApplicationEvent):void
		{
			shutdown();
		}
		
		private function removeProjectHandler(event:ProjectEvent):void
		{
			if(event.project != _project)
			{
				return;
			}
			shutdown();
		}
		
		private function fileSavedHandler(event:SaveFileEvent):void
		{
			var savedFile:FileLocation = event.file;
			
			var savedFileFolder:FileLocation = savedFile.fileBridge.parent;
			if(savedFileFolder.fileBridge.nativePath != _project.folderLocation.fileBridge.nativePath)
			{
				return;
			}

			restartLanguageServer();
		}
		
		private function saveProjectSettingsHandler(event:ProjectEvent):void
		{
			if(event.project != _project)
			{
				return;	
			}
			restartLanguageServer();
			
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
		
		protected function cleanupLanguageClient():void
		{
			if(!_languageClient)
			{
				return;
			}
						
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
		
		public function get active():Boolean
		{
			return _languageClient && _languageClient.initialized;
		}

		public function get project():ProjectVO
		{
			return this._project;
		}

		public function get uriSchemes():Vector.<String>
		{
			return URI_SCHEMES;
		}

		public function get fileExtensions():Vector.<String>
		{
			return FILE_EXTENSIONS;
		}

		public function createTextEditorForUri(uri:String, readOnly:Boolean = false):BasicTextEditor
		{
			var colonIndex:int = uri.indexOf(":");
			if(colonIndex == -1)
			{
				throw new URIError("Invalid URI: " + uri);
			}
			var scheme:String = uri.substr(0, colonIndex);

			var editor:GroovyTextEditor = new LotusBasicTextEditor(_project, readOnly);
			if(scheme == URI_SCHEME_FILE)
			{
				//the regular OpenFileEvent should be used to open this one
				return editor;
			}
			switch(scheme)
			{
				default:
				{
					throw new URIError("Unknown URI scheme for BASIC: " + scheme);
				}
			}
			return editor;
		}
		
		private function bootstrapThenStartNativeProcess():void
		{
			startNativeProcess()
		}
		
		private function startNativeProcess():void
		{
			if(_languageServerProcess)
			{
				trace("Error:Basic  language server process already exists!");
				return;
			}
			if(!UtilsCore.isNodeAvailable())
			{
				return;
			}

			//var haxePath:String = getProjectSDKPath(_project, _model);
			//_previousHaxePath = haxePath;
			var nodePath:String = UtilsCore.getNodeBinPath();
			_previousNodePath = nodePath;
			/*if(_project.isLime)
			{
				_previousTargetPlatform = _project.limeTargetPlatform;
			}
			else
			{
				_previousTargetPlatform = _project.haxeOutput.platform;
			}*/

			var scriptFile:File = File.applicationDirectory.resolvePath(LANGUAGE_SERVER_SCRIPT_PATH);
			var languageServerCommand:Vector.<String> = new <String>[
				nodePath,
				// uncomment --inspect to allow devtools debugging of the Node.js script
				// "--inspect",
				scriptFile.nativePath
			];
			EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(function(value:String):void
			{
				var cmdFile:File = null;
				var processArgs:Vector.<String> = new <String>[];
				
				/**if (Settings.os == "win")
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
				}*/

				var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				processInfo.arguments = processArgs;
				processInfo.executable = cmdFile;
				processInfo.workingDirectory = _project.folderLocation.fileBridge.getFile as File;
				
				_languageServerProcess = new NativeProcess();
				_languageServerProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, languageServerProcess_standardErrorDataHandler);
				_languageServerProcess.addEventListener(NativeProcessExitEvent.EXIT, languageServerProcess_exitHandler);
				_languageServerProcess.start(processInfo);
				initializeLanguageServer();
			}, null, [CommandLineUtil.joinOptions(languageServerCommand)]);
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
				
				warning("Basic language server exited unexpectedly. Close the " + project.name + " project and re-open it to enable code intelligence.");
			}
			_languageServerProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, languageServerProcess_standardErrorDataHandler);
			_languageServerProcess.removeEventListener(NativeProcessExitEvent.EXIT, languageServerProcess_exitHandler);
			_languageServerProcess.exit();
			_languageServerProcess = null;
			if(!_waitingToRestart)
			{
				_waitingToRestart = false;
				bootstrapThenStartNativeProcess();
				return;
			}
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
		
		protected function dispose():void
		{
			
			_dispatcher.removeEventListener(SdkEvent.CHANGE_NODE_SDK, changeNodeSDKHandler);
			_dispatcher.removeEventListener(SaveFileEvent.FILE_SAVED, fileSavedHandler);
			_dispatcher.removeEventListener(ProjectEvent.SAVE_PROJECT_SETTINGS, saveProjectSettingsHandler);
			
			_dispatcher.removeEventListener(TabEvent.EVENT_TAB_SELECT, tabSelectHandler);
			_dispatcher.removeEventListener(ProjectEvent.REMOVE_PROJECT, removeProjectHandler);
			_dispatcher.removeEventListener(ApplicationEvent.APPLICATION_EXIT, applicationExitHandler);
			_dispatcher.removeEventListener(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, executeLanguageServerCommandHandler);
			_dispatcher.removeEventListener(WatchedFileChangeEvent.FILE_CREATED, fileCreatedHandler);
			_dispatcher.removeEventListener(WatchedFileChangeEvent.FILE_DELETED, fileDeletedHandler);
			_dispatcher.removeEventListener(WatchedFileChangeEvent.FILE_MODIFIED, fileModifiedHandler);

			cleanupLanguageClient();

			
		}
		
	}
}