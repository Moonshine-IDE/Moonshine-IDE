package awaybuilder.desktop.controller
{
	import awaybuilder.model.ApplicationModel;
	import awaybuilder.model.DocumentModel;
	
	import mx.core.FlexGlobals;
	
	import org.robotlegs.mvcs.Command;
	
	public class CloseDocumentCommand extends Command
	{
		
		[Inject]
		public var windowModel:ApplicationModel;
		
		[Inject]
		public var documentModel:DocumentModel;
		
		override public function execute():void
		{
			if(this.windowModel.isWaitingForClose)
			{
				this.documentModel.edited = false;
			}
			
			//AwayBuilderApplication(FlexGlobals.topLevelApplication).close();
		}
	}
}