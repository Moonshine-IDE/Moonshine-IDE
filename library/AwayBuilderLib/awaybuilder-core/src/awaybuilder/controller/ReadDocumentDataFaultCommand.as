package awaybuilder.controller
{
	import awaybuilder.controller.events.DocumentEvent;
	import awaybuilder.controller.events.MessageBoxEvent;
	import awaybuilder.controller.events.ReadDocumentDataResultEvent;
	import awaybuilder.utils.logging.AwayBuilderLogger;
	
	import org.robotlegs.mvcs.Command;
	
	public class ReadDocumentDataFaultCommand extends Command
	{
		[Inject]
		public var event:ReadDocumentDataResultEvent;
		
		override public function execute():void
		{
			if(event.error)
			{
				AwayBuilderLogger.error("Unable to load document data. Error text: " + event.error.toString());
			}
			
			this.dispatch(new MessageBoxEvent(MessageBoxEvent.SHOW_MESSAGE_BOX, "Error", event.message ? event.message : "Unable to open file.", "Close"));
			if(event.clearDocument)
			{
				this.dispatch(new DocumentEvent(DocumentEvent.NEW_DOCUMENT));
			}
		}
	}
}