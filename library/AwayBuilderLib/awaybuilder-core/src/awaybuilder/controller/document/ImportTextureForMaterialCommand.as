package awaybuilder.controller.document
{
	import awaybuilder.controller.document.events.ImportTextureEvent;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.IDocumentService;
	
	import org.robotlegs.mvcs.Command;

	public class ImportTextureForMaterialCommand extends Command
	{
		[Inject]
		public var event:ImportTextureEvent;
		
		[Inject]
		public var fileService:IDocumentService;
		
		override public function execute():void
		{
			var nextEvent:SceneEvent = new SceneEvent(SceneEvent.ADD_NEW_TEXTURE, event.items );
			nextEvent.options = event.options;
			this.fileService.open( "images", false, nextEvent );
		}
	}
}