package actionScripts.languageServer
{
	import actionScripts.valueObjects.ProjectVO;
	import flash.events.IEventDispatcher;
	import actionScripts.ui.editor.BasicTextEditor;

	/**
	 * Dispatched when the language server is active.
	 * 
	 * @see #active
	 */
	[Event(name="init",type="flash.events.Event")]
	
	/**
	 * Dispatched when the language server is no longer active.
	 * 
	 * @see #active
	 */
	[Event(name="close",type="flash.events.Event")]

	public interface ILanguageServerManager extends IEventDispatcher
	{
		/**
		 * Indicates if the language server is active. If active, it will need
		 * to be closed before Moonshine can exit.
		 * 
		 * @see #event:init
		 * @see #event:close
		 */
		function get active():Boolean;

		/**
		 * The spawned process' ID. Currently implemented in Java-based language server processes only
		 */
		function get pid():int;

		/**
		 * The project associated with this language server.
		 */
		function get project():ProjectVO;

		/**
		 * The URI schemes associated with this language server.
		 */
		function get uriSchemes():Vector.<String>;

		/**
		 * The file extensions associated with this language server.
		 */
		function get fileExtensions():Vector.<String>;

		/**
		 * Creates a text editor for the specified URI.
		 */
		function createTextEditorForUri(uri:String, readOnly:Boolean = false):BasicTextEditor;
	}
}