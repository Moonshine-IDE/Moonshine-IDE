package awaybuilder.view.components.events
{
	import flash.events.Event;
	
	public class ToolBarZoomEvent extends Event
	{
		public static const ZOOM_IN:String = "zoomIn";
		public static const ZOOM_OUT:String = "zoomOut";
		public static const ZOOM_TO:String = "zoomTo";
		
		public function ToolBarZoomEvent(type:String, zoomValue:Number = NaN)
		{
			super(type, false, false);
			this.zoomValue = zoomValue;
		}
		
		public var zoomValue:Number;
		
		override public function clone():Event
		{
			return new ToolBarZoomEvent(this.type, this.zoomValue);
		}
	}
}