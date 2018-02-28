package awaybuilder.view.components.controls
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import mx.core.UIComponent;
	
	public class PanelImage extends UIComponent
	{
		public function PanelImage()
		{
			super();
			
			_bitmap = new Bitmap();
			this.addChild( _bitmap );
		}
		
		private var _bitmap:Bitmap;
		
		public function drawPanel( panel:UIComponent ):void
		{
			if( panel.width && panel.height ) {
				var bitmapData:BitmapData = new BitmapData( panel.width, panel.height, true, 0x00ffffff );
				bitmapData.draw( panel );
				
				_bitmap.bitmapData = bitmapData;
			}
			
		}
		
	}
}