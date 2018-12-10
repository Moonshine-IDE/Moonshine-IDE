package actionScripts.languageServer
{
	import actionScripts.valueObjects.ProjectVO;
	import flash.events.IEventDispatcher;
	import actionScripts.ui.editor.BasicTextEditor;

	[Event(name="close",type="flash.events.Event")]

	public interface ILanguageServerManager extends IEventDispatcher
	{
		function get project():ProjectVO;
		function get uriSchemes():Vector.<String>;
		function get fileExtensions():Vector.<String>;
		function createTextEditorForUri(uri:String, readOnly:Boolean = false):BasicTextEditor;
	}
}