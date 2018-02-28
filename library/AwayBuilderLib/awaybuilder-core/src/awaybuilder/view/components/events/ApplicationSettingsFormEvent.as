package awaybuilder.view.components.events
{
	import flash.events.Event;
	
	public class ApplicationSettingsFormEvent extends Event
	{
		public static const RESET_DEFAULT_SETTINGS:String = "resetDefaultSettings";
		
		public function ApplicationSettingsFormEvent(type:String)
		{
			super(type, false, false);
		}
		
		override public function clone():Event
		{
			return new ApplicationSettingsFormEvent(this.type);
		}
	}
}