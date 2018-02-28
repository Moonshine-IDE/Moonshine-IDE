package awaybuilder.controller.events
{
	import flash.events.Event;
	
	public class SettingsEvent extends Event
	{
		
		public static const SHOW_DOCUMENT_SETTINGS:String = "showDocumentSettings";
		public static const SHOW_APPLICATION_SETTINGS_DOCUMENT_DEFAULTS:String = "showApplicationSettingsDocumentDefaults";
		
		public function SettingsEvent(type:String)
		{
			super(type, false, false);
		}
		
		override public function clone():Event
		{
			return new SettingsEvent(this.type);
		}
	}
}