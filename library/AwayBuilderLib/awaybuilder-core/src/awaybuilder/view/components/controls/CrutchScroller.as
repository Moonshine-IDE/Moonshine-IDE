package awaybuilder.view.components.controls
{
	import flash.events.FocusEvent;
	
	import spark.components.Scroller;
	
	public class CrutchScroller extends Scroller
	{
		
		override protected function focusInHandler(event:FocusEvent):void
		{
			if(focusManager != null) {
				super.focusInHandler(event);
			}
		}
	}
}