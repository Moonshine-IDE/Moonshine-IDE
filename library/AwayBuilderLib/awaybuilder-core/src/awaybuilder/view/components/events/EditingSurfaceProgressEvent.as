package awaybuilder.view.components.events
{
	import flash.events.Event;
	
	public class EditingSurfaceProgressEvent extends Event
	{
		public static const PROGRESS_START:String = "progressStart";
		public static const PROGRESS_UPDATE:String = "progressUpdate";
		public static const PROGRESS_COMPLETE:String = "progressComplete";
		
		public function EditingSurfaceProgressEvent(type:String, value:Number)
		{
			super(type, false, false);
			this.value = value;
		}
		
		public var value:Number;
		
		override public function clone():Event
		{
			return new EditingSurfaceProgressEvent(this.type, this.value);
		}
	}
}