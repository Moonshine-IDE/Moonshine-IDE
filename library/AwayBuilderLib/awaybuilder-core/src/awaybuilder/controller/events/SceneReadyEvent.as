package awaybuilder.controller.events
{
	import flash.events.Event;

	public class SceneReadyEvent extends Event
	{
		
		public static const READY:String = "sceneReady";
		
		public function SceneReadyEvent( type:String )
		{
			super(type, false, false);
		}
		
		override public function clone():Event
		{
			return new SettingsEvent(this.type);
		}
	}
}