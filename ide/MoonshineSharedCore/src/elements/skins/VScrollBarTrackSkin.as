package elements.skins
{
	import flash.filters.DropShadowFilter;
	
	import mx.skins.ProgrammaticSkin;

	public class VScrollBarTrackSkin extends ProgrammaticSkin
	{
		
		public function VScrollBarTrackSkin()
		{
			super();
			
			filters = [
				new DropShadowFilter(2, 0, 0x0, .2, 8, 8, 1, 1, true)
			];
		}

		override public function get measuredWidth():Number
		{
			return 15;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// background
			graphics.clear();
			graphics.beginFill(0x444444);
			graphics.drawRect(0, 0, 15, unscaledHeight);
			graphics.endFill();
		}
		
	}
}