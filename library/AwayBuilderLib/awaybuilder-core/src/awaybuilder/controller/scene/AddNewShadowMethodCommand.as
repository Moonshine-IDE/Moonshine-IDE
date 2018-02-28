package awaybuilder.controller.scene
{
	import awaybuilder.controller.events.DocumentModelEvent;
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.vo.scene.LightVO;
	import awaybuilder.model.vo.scene.MaterialVO;
	import awaybuilder.model.vo.scene.ShadowMethodVO;
	import awaybuilder.utils.AssetUtil;

	public class AddNewShadowMethodCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		override public function execute():void
		{
			var asset:LightVO;
			if( event.items && event.items.length )
			{
				asset = event.items[0] as LightVO;
			}
			var oldValue:ShadowMethodVO = event.oldValue as ShadowMethodVO;
			var newValue:ShadowMethodVO = event.newValue as ShadowMethodVO;
			
			if( asset )
			{
				if( event.isUndoAction )
				{
					document.removeAsset( asset.shadowMethods, oldValue );
				}
				else 
				{
					var alreadyAdded:Boolean = false;
					for each( var method:ShadowMethodVO in asset.shadowMethods )
					{
						if( method.equals( newValue ) ) alreadyAdded = true;	
					}
					if( !alreadyAdded )	asset.shadowMethods.addItem( newValue );
				}
			}
			
			commitHistoryEvent( event );
			dispatch( new DocumentModelEvent( DocumentModelEvent.OBJECTS_COLLECTION_UPDATED ) );
		}
		
		
	}
}