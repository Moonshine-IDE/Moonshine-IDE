package awaybuilder.controller.scene
{
	import awaybuilder.controller.events.DocumentModelEvent;
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.vo.scene.EffectVO;
	import awaybuilder.model.vo.scene.MaterialVO;
	import awaybuilder.model.vo.scene.SharedEffectVO;
	import awaybuilder.utils.AssetUtil;

	public class AddNewEffectMethodCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		override public function execute():void
		{
			var material:MaterialVO;
			if( event.items && event.items.length )
			{
				material = event.items[0] as MaterialVO;
			}
			var oldValue:EffectVO = event.oldValue as EffectVO;
			var newValue:EffectVO = event.newValue as EffectVO;
			
			if( event.isUndoAction )
			{
				document.removeAsset( document.materials, oldValue );
			}
			else 
			{
				document.materials.addItemAt( newValue, 0 );
			}
			
			if( material )
			{
				if( event.isUndoAction )
				{
					document.removeAsset( material.effectMethods, oldValue );
				}
				else 
				{
					material.effectMethods.addItem( new SharedEffectVO(newValue));
				}
				material.fillFromMaterial( material );
			}
			
			commitHistoryEvent( event );
		}
		
	}
}