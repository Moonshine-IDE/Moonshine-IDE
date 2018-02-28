package awaybuilder.controller.scene
{
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.vo.scene.SkyBoxVO;

	public class ChangeSkyBoxCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		override public function execute():void
		{
			var newValue:SkyBoxVO = event.newValue as SkyBoxVO;
			var vo:SkyBoxVO = event.items[0] as SkyBoxVO;
			
			saveOldValue( event, vo.clone() );
			
			vo.fillFromSkyBox( newValue );
			
			commitHistoryEvent( event );
		}
	}
}