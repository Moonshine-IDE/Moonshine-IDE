package awaybuilder.controller.events
{
	import flash.events.Event;
	
	public class DocumentLoadEvent extends Event
	{
		public static const SHOW_DOCUMENT_LOAD_PROGRESS:String = "showDocumentLoadProgress";
		public static const UPDATE_DOCUMENT_LOAD_PROGRESS:String = "updateDocumentLoadProgress";
		public static const HIDE_DOCUMENT_LOAD_PROGRESS:String = "hideDocumentLoadProgress";
		
		public function DocumentLoadEvent(type:String, progress:Number)
		{
			super(type, false, false);
			this.progress = progress;
		}
		
		public var progress:Number;
		
		override public function clone():Event
		{
			return new DocumentLoadEvent(this.type, this.progress);
		}
	}
}