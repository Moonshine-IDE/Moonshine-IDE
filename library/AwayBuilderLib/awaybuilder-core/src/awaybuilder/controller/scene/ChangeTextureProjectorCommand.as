package awaybuilder.controller.scene
{
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.AssetsModel;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.vo.scene.TextureProjectorVO;

	public class ChangeTextureProjectorCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		[Inject]
		public var assets:AssetsModel;
		
		
		override public function execute():void
		{
			var newAsset:TextureProjectorVO = event.newValue as TextureProjectorVO;
			var vo:TextureProjectorVO = event.items[0] as TextureProjectorVO;
			
			saveOldValue( event, vo.clone() );
			vo.fillFromTextureProjector(newAsset);
			
			commitHistoryEvent( event );
		}
	}
}