package awaybuilder.controller.scene
{
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.AssetsModel;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.vo.scene.TextureVO;

	public class ChangeTextureCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		[Inject]
		public var assets:AssetsModel;
		
		override public function execute():void
		{
			var newAsset:TextureVO = event.newValue as TextureVO;
			var vo:TextureVO = event.items[0] as TextureVO;
			
			saveOldValue( event, vo.clone() );
			vo.name = newAsset.name;
			vo.bitmapData = newAsset.bitmapData;
			
			commitHistoryEvent( event );
		}
	}
}