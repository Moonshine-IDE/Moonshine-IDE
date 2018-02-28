package awaybuilder.view.components.events
{
	import flash.events.Event;
	
	public class StatusBarEvent extends Event
	{
		public static const CONTAINER_CLICKED : String = "containerClicked";
		
		public var item : Object;
		
		public function StatusBarEvent(type:String, item:Object)
		{
			super(type, false, false);
			this.item = item;
		}
		
		override public function clone():Event
		{
			return new StatusBarEvent(this.type, this.item);
		}
	}
}