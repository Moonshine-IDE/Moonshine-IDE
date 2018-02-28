package awaybuilder.controller.events
{
	import flash.events.Event;
	
	public class ReadDocumentDataResultEvent extends Event
	{
		public static const READ_DOCUMENT_DATA_FAULT:String = "readDocumentDataFault";
		public static const READ_DOCUMENT_DATA_SUCCESS:String = "readDocumentDataSuccess";
		
		public function ReadDocumentDataResultEvent(type:String, message:String = null, error:Error = null, clearDocument:Boolean = false)
		{
			super(type, false, false);
			this.error = error;
			this.message = message;
			this.clearDocument = clearDocument;
		}
		
		public var error:Error;
		public var message:String;
		public var clearDocument:Boolean;
		
		override public function clone():Event
		{
			return new ReadDocumentDataResultEvent(this.type, this.message, this.error, this.clearDocument);
		}
	}
}