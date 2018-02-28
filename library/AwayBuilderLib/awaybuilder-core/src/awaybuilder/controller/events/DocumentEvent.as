package awaybuilder.controller.events
{
	import flash.events.Event;
	
	public class DocumentEvent extends Event
	{
		public static const NEW_DOCUMENT:String = "newDocument";
		public static const OPEN_DOCUMENT:String = "openDocument";
		public static const IMPORT_DOCUMENT:String = "importDocument";
		public static const CLOSE_DOCUMENT:String = "closeDocument";
		
		public function DocumentEvent(type:String)
		{
			super(type, false, false);
		}
		
		override public function clone():Event
		{
			return new DocumentEvent(this.type);
		}
	}
}