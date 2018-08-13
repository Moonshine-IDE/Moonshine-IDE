package actionScripts.interfaces
{
	import actionScripts.valueObjects.ProjectVO;

	public interface ILanguageServerBridge
	{
		function get connectedProjectCount():int;

		function start():void;
		function hasLanguageServerForProject(project:ProjectVO):Boolean;
	}
}