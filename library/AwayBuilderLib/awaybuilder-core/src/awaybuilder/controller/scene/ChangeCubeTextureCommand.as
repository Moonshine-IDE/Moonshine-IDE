package awaybuilder.controller.scene
{
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.AssetsModel;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.vo.scene.CubeTextureVO;
	
	import flash.display3D.textures.CubeTexture;

	public class ChangeCubeTextureCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		[Inject]
		public var assets:AssetsModel;
		
		override public function execute():void
		{
			var newAsset:CubeTextureVO = event.newValue as CubeTextureVO;
			var vo:CubeTextureVO = event.items[0] as CubeTextureVO;
			
			saveOldValue( event, vo.clone() );
			vo.fillFromCubeTexture( newAsset );
			
			commitHistoryEvent( event );
		}
	}
}