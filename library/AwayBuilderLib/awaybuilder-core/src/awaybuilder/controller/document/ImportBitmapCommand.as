package awaybuilder.controller.document
{
	import awaybuilder.controller.document.events.ImportTextureEvent;
	import awaybuilder.model.IDocumentService;
	
	import org.robotlegs.mvcs.Command;

	public class ImportBitmapCommand extends Command
	{
		[Inject]
		public var event:ImportTextureEvent;
		
		[Inject]
		public var fileService:IDocumentService;
		
		override public function execute():void
		{
			this.fileService.openBitmap( event.items , event.options as String  );
		}
	}
}