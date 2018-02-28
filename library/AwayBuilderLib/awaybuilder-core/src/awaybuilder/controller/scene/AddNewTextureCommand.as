package awaybuilder.controller.scene
{
	import away3d.library.AssetLibrary;
	import away3d.materials.TextureMaterial;
	import away3d.textures.Texture2DBase;
	
	import awaybuilder.controller.events.DocumentModelEvent;
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.history.HistoryEvent;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.vo.DocumentVO;
	import awaybuilder.model.vo.scene.AssetVO;
	import awaybuilder.model.vo.scene.MaterialVO;
	import awaybuilder.model.vo.scene.TextureVO;
	import awaybuilder.model.vo.scene.interfaces.ITextured;
	import awaybuilder.utils.AssetUtil;
	
	import flash.display3D.textures.Texture;
	
	import mx.collections.ArrayCollection;

	public class AddNewTextureCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		override public function execute():void
		{
			var asset:AssetVO;
			if( event.items && event.items.length )
			{
				asset = event.items[0] as AssetVO;
			}
			var oldValue:DocumentVO = event.oldValue as DocumentVO;
			var newValue:DocumentVO = event.newValue as DocumentVO;
			
			if( asset ) {
				saveOldTexture( event, asset, event.options as String );
			}
			
			var newTexture:TextureVO;
			if( newValue.textures && newValue.textures.length )
			{
				newTexture = newValue.textures.getItemAt( 0 ) as TextureVO;
			}
			
			if( event.isUndoAction ) //handle undo-redo specific execution
			{
				document.removeAssets( document.textures, oldValue.textures );
			}
			else 
			{
				document.textures.addItemAt( newTexture, 0 ); // add new texture to library
			}
			
			if( asset )
			{
				asset[event.options] = newTexture;
			}
			else if( newTexture )
			{
				this.dispatch(new SceneEvent(SceneEvent.SELECT,[newTexture]));
			}
			
			commitHistoryEvent( event );
		}
		
		protected function saveOldTexture( event:HistoryEvent, prevValue:AssetVO, option:String ):void 
		{
			if( !event.oldValue )
			{
				var oldDocument:DocumentVO = new DocumentVO();
				if( prevValue[option] ) 
				{
					oldDocument.textures.addItem( prevValue[option] );
				}
				event.oldValue = oldDocument;
			}
		}
		
		
	}
}