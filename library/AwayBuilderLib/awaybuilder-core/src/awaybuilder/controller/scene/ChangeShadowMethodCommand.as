package awaybuilder.controller.scene
{
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.vo.scene.ShadowMethodVO;

	public class ChangeShadowMethodCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		override public function execute():void
		{
			var newAsset:ShadowMethodVO = event.newValue as ShadowMethodVO;
			var vo:ShadowMethodVO = event.items[0] as ShadowMethodVO;
			
			saveOldValue( event, vo.clone() );
			
			vo.name = newAsset.name;
			vo.type = newAsset.type;
			vo.epsilon = newAsset.epsilon;
			vo.alpha = newAsset.alpha;
			vo.samples = newAsset.samples;
			vo.range = newAsset.range;
			vo.baseMethod = newAsset.baseMethod;
			
			commitHistoryEvent( event );
		}
	}
}