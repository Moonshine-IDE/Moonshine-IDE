package actionScripts.languageServer
{
    import actionScripts.languageServer.ILanguageServerManager;
    import flash.events.Event;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.ui.editor.BasicTextEditor;
    import moonshine.lsp.LanguageClient;

    [Event(name="init",type="flash.events.Event")]
	[Event(name="close",type="flash.events.Event")]
	public class BasicLanguageServer  implements ILanguageServerManager
	
	{
		
		private static const FILE_EXTENSIONS:Vector.<String> = new <String>["tibbo"];
		private static const URI_SCHEMES:Vector.<String> = new <String>[];
		private var _languageClient:LanguageClient;
		
		public function BasicLanguageServer()
		{
		}

		public function get active():Boolean
		{
			return _languageClient && _languageClient.initialized;
		}

		public function get project():ProjectVO
		{
			throw new Error("Method not implemented.");
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

		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			throw new Error("Method not implemented.");
		}

		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			throw new Error("Method not implemented.");
		}

		public function dispatchEvent(event:flash.events.Event):Boolean
		{
			throw new Error("Method not implemented.");
		}

		public function hasEventListener(type:String):Boolean
		{
			throw new Error("Method not implemented.");
		}

		public function willTrigger(type:String):Boolean
		{
			throw new Error("Method not implemented.");
		}
	}
}