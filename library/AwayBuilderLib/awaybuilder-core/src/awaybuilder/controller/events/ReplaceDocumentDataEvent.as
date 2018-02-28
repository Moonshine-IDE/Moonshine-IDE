package awaybuilder.controller.events
{
	import awaybuilder.model.vo.DocumentVO;
	import awaybuilder.model.vo.GlobalOptionsVO;
	
	import flash.events.Event;

	public class ReplaceDocumentDataEvent extends Event
	{
		public static const REPLACE_DOCUMENT_DATA:String = "replaceDocumentData";
		
		public function ReplaceDocumentDataEvent( type:String )
		{
			super(type, false, false);
		}
		
		public var value:DocumentVO;
		
		public var fileName:String = "undefined";
		
		public var path:String;
		
		public var globalOptions:GlobalOptionsVO;
		
	}
}