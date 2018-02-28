package awaybuilder.controller.clipboard.events
{
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.controller.history.HistoryEvent;
	
	import flash.events.Event;
	
	public class PasteEvent extends HistoryEvent
	{
		
		public static const CLIPBOARD_PASTE:String = "clipboardPaste";
		
		public function PasteEvent(type:String, newValue:Object=null, oldValue:Object=null)
		{
			super(type, newValue, oldValue);
		}
		
		override public function clone():Event
		{
			return new PasteEvent( this.type, this.newValue, oldValue );
		}
	}
}