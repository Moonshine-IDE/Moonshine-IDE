package awaybuilder.controller.scene
{
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.vo.scene.ShadingMethodVO;

	public class ChangeShadingMethodCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		override public function execute():void
		{
			var newAsset:ShadingMethodVO = event.newValue as ShadingMethodVO;
			var vo:ShadingMethodVO = event.items[0] as ShadingMethodVO;
			
			saveOldValue( event, vo.clone() );
			
			vo.fillFromShadingMethod( newAsset );
			
			commitHistoryEvent( event );
		}
	}
}