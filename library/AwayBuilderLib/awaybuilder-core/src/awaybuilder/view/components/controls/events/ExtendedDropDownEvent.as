package awaybuilder.view.components.controls.events
{
	import flash.events.Event;
	
	import spark.events.DropDownEvent;
	
	public class ExtendedDropDownEvent extends DropDownEvent
	{
		
		public static const ADD:String = "addNewItem";
		
		public function ExtendedDropDownEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, triggerEvent:Event=null)
		{
			super(type, bubbles, cancelable, triggerEvent);
		}
	}
}