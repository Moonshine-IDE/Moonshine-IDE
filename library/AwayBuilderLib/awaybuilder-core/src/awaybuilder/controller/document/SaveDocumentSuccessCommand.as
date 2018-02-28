package awaybuilder.controller.document
{
	import flash.events.Event;
	
	import awaybuilder.controller.events.SaveDocumentEvent;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.ApplicationModel;

	import org.robotlegs.mvcs.Command;
	
	public class SaveDocumentSuccessCommand extends Command
	{
		[Inject]
		public var event:SaveDocumentEvent;
		
		[Inject]
		public var documentModel:DocumentModel;

		[Inject]
		public var windowModel:ApplicationModel;
		
		override public function execute():void
		{
			this.documentModel.name = this.event.name;
			this.documentModel.path = this.event.path;
			this.documentModel.edited = false;
			
			if(this.windowModel.savedNextEvent)
			{
				var nextEvent:Event = this.windowModel.savedNextEvent;
				this.windowModel.savedNextEvent = null;
				this.dispatch(nextEvent);
			}
		}
	}
}