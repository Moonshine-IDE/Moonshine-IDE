package awaybuilder.controller.document
{
	import awaybuilder.controller.events.SaveDocumentEvent;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.IDocumentService;
	
	import org.robotlegs.mvcs.Command;

	public class SaveDocumentCommand extends Command
	{
		[Inject]
		public var event:SaveDocumentEvent;
		
		[Inject]
		public var document:DocumentModel;
		
		[Inject]
		public var documentService:IDocumentService;
		
		override public function execute():void
		{
			if( (this.event.type==SaveDocumentEvent.SAVE_DOCUMENT_AS) || !this.document.path)
			{
				this.documentService.saveAs(document, this.document.name);
			}
			else
			{
				this.documentService.save(document, this.document.path);
			}
		}
	}
}