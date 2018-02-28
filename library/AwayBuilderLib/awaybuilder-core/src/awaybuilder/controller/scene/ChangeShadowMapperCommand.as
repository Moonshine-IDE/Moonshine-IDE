package awaybuilder.controller.scene
{
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.vo.scene.ShadowMapperVO;

	public class ChangeShadowMapperCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		override public function execute():void
		{
			var newAsset:ShadowMapperVO = event.newValue as ShadowMapperVO;
			var vo:ShadowMapperVO = event.items[0] as ShadowMapperVO;
			
			saveOldValue( event, vo.clone() );
			
			vo.fillFromShadowMapper( newAsset );
			
			commitHistoryEvent( event );
		}
	}
}