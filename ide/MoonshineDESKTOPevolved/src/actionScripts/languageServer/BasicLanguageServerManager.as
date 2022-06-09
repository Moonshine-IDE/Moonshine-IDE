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
		
		public function BasicLanguageServerManager (project:BasicProjectVO)
		{
			this._project=project;
			_dispatcher.addEventListener(WatchedFileChangeEvent.FILE_CREATED, fileCreatedHandler);
			_dispatcher.addEventListener(WatchedFileChangeEvent.FILE_DELETED, fileDeletedHandler);
			_dispatcher.addEventListener(WatchedFileChangeEvent.FILE_MODIFIED, fileModifiedHandler);
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


		
		private function saveProjectSettingsHandler(event:ProjectEvent):void
		{
			bootstrapThenStartNativeProcess();			
		}
		
		private function bootstrapThenStartNativeProcess():void
		{
			
		}

	}
}