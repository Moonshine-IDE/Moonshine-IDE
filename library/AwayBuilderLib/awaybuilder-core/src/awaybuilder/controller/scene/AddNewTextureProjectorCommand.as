package awaybuilder.controller.scene
{
	import awaybuilder.utils.scene.Scene3DManager;
	import away3d.entities.TextureProjector;
	import awaybuilder.controller.events.DocumentModelEvent;
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.AssetsModel;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.vo.scene.TextureProjectorVO;

	public class AddNewTextureProjectorCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		[Inject]
		public var assets:AssetsModel;
		
		override public function execute():void
		{
			var oldValue:TextureProjectorVO = event.oldValue as TextureProjectorVO;
			var newValue:TextureProjectorVO = event.newValue as TextureProjectorVO;
			
			if( event.isUndoAction )
			{
				document.removeAsset( document.scene, oldValue );
				Scene3DManager.removeTextureProjector( assets.GetObject(oldValue) as TextureProjector );
			}
			else
			{
				document.scene.addItemAt( newValue, 0 );
				Scene3DManager.addTextureProjector( assets.GetObject(newValue) as TextureProjector, newValue.texture.bitmapData );
			}
			
			addToHistory( event );
			
			commitHistoryEvent( event );
		}
		
	}
}