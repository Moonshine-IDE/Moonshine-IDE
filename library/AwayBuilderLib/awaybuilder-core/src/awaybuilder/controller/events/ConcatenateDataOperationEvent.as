package awaybuilder.controller.events
{
	import awaybuilder.controller.history.HistoryEvent;
	import awaybuilder.model.vo.DocumentVO;
	import awaybuilder.model.vo.GlobalOptionsVO;
	
	import flash.events.Event;

	public class ConcatenateDataOperationEvent extends HistoryEvent
	{
		public static const CONCAT_DOCUMENT_DATA:String = "concatenateDocumentData";
		
		public function ConcatenateDataOperationEvent( type:String )
		{
			super(type, null);
		}
		
		override public function clone():Event
		{
			var e:ConcatenateDataOperationEvent = new ConcatenateDataOperationEvent( this.type );
			e.newValue = this.newValue;
			e.oldValue = this.oldValue;
			return e;
		}
	}
}