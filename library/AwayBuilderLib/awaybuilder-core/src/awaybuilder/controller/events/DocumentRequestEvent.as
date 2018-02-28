package awaybuilder.controller.events
{
	import flash.events.Event;
	
	public class DocumentRequestEvent extends Event
	{
		public static const REQUEST_NEW_DOCUMENT:String = "requestNewDocument";
		public static const REQUEST_OPEN_DOCUMENT:String = "requestOpenDocument";
		public static const REQUEST_IMPORT_DOCUMENT:String = "requestImportDocument";
		public static const REQUEST_CLOSE_DOCUMENT:String = "requestCloseDocument";
		
		public function DocumentRequestEvent(type:String, nextEvent:Event = null)
		{
			super(type, false, false);
			
			var lookup:Object = {};
			lookup[REQUEST_NEW_DOCUMENT] = DocumentEvent.NEW_DOCUMENT;
			lookup[REQUEST_OPEN_DOCUMENT] = DocumentEvent.OPEN_DOCUMENT;
			lookup[REQUEST_CLOSE_DOCUMENT] = DocumentEvent.CLOSE_DOCUMENT;
			lookup[REQUEST_IMPORT_DOCUMENT] = DocumentEvent.IMPORT_DOCUMENT;
			if(!nextEvent && lookup.hasOwnProperty(type))
			{
				this.nextEvent = new DocumentEvent(lookup[type]);
			}
		}
		
		public var nextEvent:DocumentEvent;
		
		override public function clone():Event
		{
			return new DocumentRequestEvent(this.type);
		}
	}
}