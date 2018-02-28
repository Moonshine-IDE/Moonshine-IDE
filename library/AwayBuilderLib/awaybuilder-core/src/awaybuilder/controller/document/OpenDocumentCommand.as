package awaybuilder.controller.document
{
	import awaybuilder.controller.events.ConcatenateDataOperationEvent;
	import awaybuilder.controller.events.DocumentEvent;
	import awaybuilder.controller.events.ReplaceDocumentDataEvent;
	import awaybuilder.model.IDocumentService;
	
	import org.robotlegs.mvcs.Command;
	
	public class OpenDocumentCommand extends Command
	{
		[Inject]
		public var fileService:IDocumentService;
		
		override public function execute():void
		{
			var nextEvent:ReplaceDocumentDataEvent = new ReplaceDocumentDataEvent(ReplaceDocumentDataEvent.REPLACE_DOCUMENT_DATA );
			this.fileService.open( "open", true, nextEvent );
		}
	}
}