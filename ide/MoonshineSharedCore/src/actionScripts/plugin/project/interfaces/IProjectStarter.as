package actionScripts.plugin.project.interfaces
{
	import actionScripts.events.ProjectEvent;
	import actionScripts.valueObjects.ProjectVO;

	import flash.events.IEventDispatcher;

	public interface IProjectStarter extends IEventDispatcher
	{
		function get projectStarterDelegate():IProjectStarterDelegate;
		function set projectStarterDelegate(value:IProjectStarterDelegate):void;

		function onProjectAdded(event:ProjectEvent):void;
	}
}
