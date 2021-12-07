package classes.events
{
	import org.apache.royale.events.Event;
	
	public class ScreenEvent extends Event
	{
		public static const EVENT_NAVIGATE_TO:String = "eventNavigateTo";
		
		public var screenName:String;
		
		public function ScreenEvent(type:String, screenName:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.screenName = screenName;
		}
	}
}