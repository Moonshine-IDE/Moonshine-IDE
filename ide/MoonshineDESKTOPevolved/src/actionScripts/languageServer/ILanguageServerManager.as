package actionScripts.languageServer
{
	import actionScripts.valueObjects.ProjectVO;
	import flash.events.IEventDispatcher;

	[Event(name="close",type="flash.events.Event")]

	public interface ILanguageServerManager extends IEventDispatcher
	{
		function get project():ProjectVO;
	}
}