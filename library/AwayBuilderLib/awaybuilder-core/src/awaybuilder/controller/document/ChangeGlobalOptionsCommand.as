package awaybuilder.controller.document
{
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.vo.GlobalOptionsVO;

	public class ChangeGlobalOptionsCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		override public function execute():void
		{
			var globalOptions:GlobalOptionsVO = event.newValue as GlobalOptionsVO;
			
			saveOldValue( event, document.globalOptions.clone() );
			
			document.globalOptions.fill( globalOptions );
			
			event.items = [document.globalOptions];
			
			addToHistory( event );
		}
	}
}