package awaybuilder.view.components.controls
{
	import flash.events.KeyboardEvent;
	
	import spark.components.RadioButton;
	
	public class SwitchButton extends RadioButton
	{
		public function SwitchButton()
		{
			super();
		}
		
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			if (event.isDefaultPrevented())
				return;
			}
	}
}