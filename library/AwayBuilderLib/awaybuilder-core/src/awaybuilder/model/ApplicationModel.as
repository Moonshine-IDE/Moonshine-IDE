package awaybuilder.model
{
	import flash.events.Event;
	
	import org.robotlegs.mvcs.Actor;

	public class ApplicationModel extends Actor
	{
		public var isWaitingForClose:Boolean = false;
		
		public var savedNextEvent:Event;
		
		public var webRestrictionsEnabled:Boolean = false;
	}
}
