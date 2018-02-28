package awaybuilder.controller.scene
{
	import awaybuilder.controller.events.DocumentModelEvent;
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.AssetsModel;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.vo.scene.AssetVO;
	import awaybuilder.model.vo.scene.CubeTextureVO;
	import awaybuilder.model.vo.scene.EffectVO;

	public class AddNewCubeTextureCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		[Inject]
		public var assets:AssetsModel;
		
		override public function execute():void
		{
			var asset:AssetVO;
			if( event.items && event.items.length )
			{
				asset = event.items[0] as AssetVO;
			}
			
			var oldValue:CubeTextureVO = event.oldValue as CubeTextureVO;
			var newValue:CubeTextureVO = event.newValue as CubeTextureVO;
			
			if( asset ) {
				saveOldValue( event, asset[event.options] );
			}
			
			if( event.isUndoAction )
			{
				document.removeAsset( document.textures, oldValue );
			}
			else 
			{
				document.textures.addItemAt( newValue, 0 );
			}
			
			if( asset )
			{
				asset[event.options] = newValue;
			}
			
			commitHistoryEvent( event );
		}
		
	}
}