package awaybuilder.controller.document
{
	import awaybuilder.controller.events.ConcatenateDataOperationEvent;
	import awaybuilder.model.IDocumentService;
	
	import flash.utils.setTimeout;
	
	import org.robotlegs.mvcs.Command;

	public class ImportDocumentCommand extends Command
	{
		[Inject]
		public var fileService:IDocumentService;
		
		override public function execute():void
		{
			var nextEvent:ConcatenateDataOperationEvent = new ConcatenateDataOperationEvent(ConcatenateDataOperationEvent.CONCAT_DOCUMENT_DATA );
			this.fileService.open( "import", false, nextEvent );
		}
	}
}