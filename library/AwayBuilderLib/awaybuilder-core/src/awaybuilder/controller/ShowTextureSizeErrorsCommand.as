package awaybuilder.controller
{
	import awaybuilder.controller.events.TextureSizeErrorsEvent;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.view.components.popup.TextureSizeWarningPopup;
	
	import org.robotlegs.mvcs.Command;
	
	public class ShowTextureSizeErrorsCommand extends Command
	{
		[Inject]
		public var document:DocumentModel;
		
		[Inject]
		public var event:TextureSizeErrorsEvent;
		
		override public function execute():void
		{				
			TextureSizeWarningPopup.show();
		}
	}
}