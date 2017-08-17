package actionScripts.events
{
	import actionScripts.valueObjects.Location;

	import flash.events.Event;

	public class ReferencesEvent extends Event
	{
		public static const EVENT_SHOW_REFERENCES:String = "newShowReferences";
		
		public var references:Vector.<Location>;
		
		public function ReferencesEvent(type:String, references:Vector.<Location>)
		{
			super(type, false, false);
			this.references = references;
		}
	}
}
