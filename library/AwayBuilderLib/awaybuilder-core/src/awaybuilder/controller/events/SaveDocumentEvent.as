package awaybuilder.controller.events
{
	import flash.events.Event;
	
	public class SaveDocumentEvent extends Event
	{
		public static const SAVE_DOCUMENT:String = "saveDocument";
		public static const SAVE_DOCUMENT_AS:String = "saveDocumentAs";
		public static const SAVE_DOCUMENT_SUCCESS:String = "saveDocumentSuccess";
		public static const SAVE_DOCUMENT_FAIL:String = "saveDocumentFail";
		
		public function SaveDocumentEvent(type:String, name:String = null, path:String = null)
		{
			super(type, bubbles, cancelable);
			this.name = name;
			this.path = path;
		}
		
		public var name:String;
		public var path:String;
		
		override public function clone():Event
		{
			return new SaveDocumentEvent(this.type, this.name, this.path);
		}
	}
}