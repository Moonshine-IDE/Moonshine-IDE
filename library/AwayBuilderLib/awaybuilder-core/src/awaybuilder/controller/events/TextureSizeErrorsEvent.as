package awaybuilder.controller.events
{
	import flash.events.Event;
	
	public class TextureSizeErrorsEvent extends Event
	{
		public static const SHOW_TEXTURE_SIZE_ERRORS:String = "textureSizeErrors";
		
		public function TextureSizeErrorsEvent(type:String)
		{
			super(type, false, false);
		}
		
		override public function clone():Event
		{
			return new TextureSizeErrorsEvent(this.type);
		}
	}
}