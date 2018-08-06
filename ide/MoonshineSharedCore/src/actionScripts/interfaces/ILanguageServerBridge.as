package actionScripts.interfaces
{
	public interface ILanguageServerBridge
	{
		function get connectedProjectCount():int;

		function startProjectWatcher():void;
	}
}