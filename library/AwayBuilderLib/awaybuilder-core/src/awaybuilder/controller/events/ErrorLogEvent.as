package awaybuilder.controller.events
{
	import flash.events.Event;
	
	public class ErrorLogEvent extends Event
	{
		public static const LOG_ENTRY_MADE:String = "logEntryMade";
		
		public function ErrorLogEvent(type:String)
		{
			super(type, false, false);
		}
		
		override public function clone():Event
		{
			return new ErrorLogEvent(this.type);
		}
	}
}