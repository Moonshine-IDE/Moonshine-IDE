package actionScripts.languageServer
{
    import actionScripts.languageServer.ILanguageServerManager;
    import flash.events.Event;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.ui.editor.BasicTextEditor;
    import moonshine.lsp.LanguageClient;
    import actionScripts.plugin.basic.vo.BasicProjectVO;

    [Event(name="init",type="flash.events.Event")]
	[Event(name="close",type="flash.events.Event")]
	public class BasicLanguageServerManager  implements ILanguageServerManager
	
	{
		
		private static const FILE_EXTENSIONS:Vector.<String> = new <String>["tibbo"];
		private static const URI_SCHEMES:Vector.<String> = new <String>[];
		private var _languageClient:LanguageClient;
		private var _project:BasicProjectVO;
		private var _dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var _waitingToRestart:Boolean = false;
		private var _languageServerProcess:NativeProcess;
		
		public function BasicLanguageServerManager (project:BasicProjectVO)
		{
			this._project=project;
			_dispatcher.addEventListener(WatchedFileChangeEvent.FILE_CREATED, fileCreatedHandler);
			_dispatcher.addEventListener(WatchedFileChangeEvent.FILE_DELETED, fileDeletedHandler);
			_dispatcher.addEventListener(WatchedFileChangeEvent.FILE_MODIFIED, fileModifiedHandler);
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
			throw new Error("Method not implemented.");
		}
		
		private function bootstrapThenStartNativeProcess():void
		{
			
		}

	}
}