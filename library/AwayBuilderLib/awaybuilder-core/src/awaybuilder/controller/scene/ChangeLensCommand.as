package awaybuilder.controller.scene
{
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.AssetsModel;
	import awaybuilder.model.vo.scene.LensVO;

	public class ChangeLensCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		[Inject]
		public var assets:AssetsModel;
		
		override public function execute():void
		{
			var newAsset:LensVO = event.newValue as LensVO;
			var vo:LensVO = event.items[0] as LensVO;
			
			saveOldValue( event, vo.clone() );
			vo.fillFromLens(newAsset);
			
			commitHistoryEvent( event );
		}
	}
}