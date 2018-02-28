package awaybuilder.controller.document
{
	import awaybuilder.controller.events.MessageBoxEvent;
	import awaybuilder.controller.events.SaveDocumentEvent;
	import awaybuilder.utils.logging.AwayBuilderLogger;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.ApplicationModel;

	import org.robotlegs.mvcs.Command;
	
	public class SaveDocumentFailCommand extends Command
	{
		[Inject]
		public var windowModel:ApplicationModel;
		
		[Inject]
		public var event:SaveDocumentEvent;
		
		override public function execute():void
		{
			if(this.windowModel.savedNextEvent)
			{
				//just clear it, the user cancelled the save action, and we
				//cannot assume that they want to continue.
				this.windowModel.savedNextEvent = null;
			}
			
			AwayBuilderLogger.info("Unable to save document: " + event.name + "(" + event.path + ")" );
			this.dispatch(new MessageBoxEvent(MessageBoxEvent.SHOW_MESSAGE_BOX, "Error", "Unable to save document " + event.name + ".", "Close"));
		}
	}
}