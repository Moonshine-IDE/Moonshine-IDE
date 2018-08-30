package actionScripts.interfaces
{
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.ui.editor.BasicTextEditor;

	public interface ILanguageServerBridge
	{
		function get connectedProjectCount():int;

		function start():void;
		function hasLanguageServerForProject(project:ProjectVO):Boolean;

		function hasCustomTextEditorForFileExtension(extension:String, project:ProjectVO):Boolean;
		function getCustomTextEditorForFileExtension(extension:String, project:ProjectVO, readOnly:Boolean = false):BasicTextEditor;

		function hasCustomTextEditorForUriScheme(scheme:String, project:ProjectVO):Boolean;
		function getCustomTextEditorForUriScheme(scheme:String, project:ProjectVO, readOnly:Boolean = false):BasicTextEditor;
	}
}