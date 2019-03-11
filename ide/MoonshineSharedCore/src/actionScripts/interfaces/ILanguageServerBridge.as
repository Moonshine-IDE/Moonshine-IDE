package actionScripts.interfaces
{
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.ui.editor.BasicTextEditor;

	public interface ILanguageServerBridge
	{
		function get connectedProjectCount():int;

		function hasLanguageServerForProject(project:ProjectVO):Boolean;

		function hasCustomTextEditorForUri(uri:String, project:ProjectVO):Boolean;
		function getCustomTextEditorForUri(scheme:String, project:ProjectVO, readOnly:Boolean = false):BasicTextEditor;
	}
}