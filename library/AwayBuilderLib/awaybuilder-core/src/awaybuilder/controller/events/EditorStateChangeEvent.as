package awaybuilder.controller.events
{
	import flash.events.Event;
	
	public class EditorStateChangeEvent extends Event
	{
		public static const ZOOM_CHANGE:String = "zoomChange";
//		public static const PAN_CHANGE:String = "panChange";
//		public static const SELECTION_CHANGE:String = "selectionChange";
//		public static const DRILL_DOWN_SELECTION_CHANGE:String = "drillDownSelectionChange";
//		public static const OBJECT_PROPERTY_CHANGE:String = "objectPropertyChange";
		
		public function EditorStateChangeEvent(type:String)
		{
			super(type, false, false);
		}
		
		override public function clone():Event
		{
			return new EditorStateChangeEvent(this.type);
		}
	}
}