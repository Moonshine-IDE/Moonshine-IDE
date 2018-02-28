package awaybuilder.view.components.events
{
	import flash.events.Event;
	
	public class EditingSurfaceTransformEvent extends Event
	{
		public static const TRANSFORM_OBJECTS:String = "transformObjects";
		
		public function EditingSurfaceTransformEvent(type:String, objects:Vector.<Object>)
		{
			super(type, false, false);
			this.objects = objects;
		}
		
		public var objects:Vector.<Object>;
		
		override public function clone():Event
		{
			return new EditingSurfaceTransformEvent(this.type, this.objects);
		}
	}
}