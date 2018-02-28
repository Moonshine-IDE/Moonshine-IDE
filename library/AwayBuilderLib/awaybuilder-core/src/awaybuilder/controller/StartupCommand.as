package awaybuilder.controller
{
	import awaybuilder.controller.events.DocumentEvent;
	
	import org.robotlegs.base.ContextEvent;
	import org.robotlegs.mvcs.Command;

	public class StartupCommand extends Command
	{
		override public function execute():void
		{
			this.dispatch(new DocumentEvent(DocumentEvent.NEW_DOCUMENT));
			this.dispatch(new ContextEvent(ContextEvent.STARTUP_COMPLETE));
		}
	}
}