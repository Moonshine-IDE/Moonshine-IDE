package actionScripts.plugin.genericproj.events
{
	import flash.events.Event;

	public class GenericProjectEvent extends Event
	{
		public static const EVENT_OPEN_PROJECT:String = "eventOpenAsGenericProject";

		public var value:Object;

		public function GenericProjectEvent(type:String, value:Object=null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			this.value = value;
			super(type, bubbles, cancelable);
		}
	}
}
