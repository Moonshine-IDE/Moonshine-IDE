package awaybuilder.controller.scene
{
	import awaybuilder.controller.events.DocumentModelEvent;
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.vo.scene.AnimationSetVO;
	import awaybuilder.model.vo.scene.AnimatorVO;

	public class AddNewAnimatorCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		override public function execute():void
		{
			var asset:AnimationSetVO;
			if( event.items && event.items.length )
			{
				asset = event.items[0] as AnimationSetVO;
			}
			
			var oldValue:AnimatorVO = event.oldValue as AnimatorVO;
			var newValue:AnimatorVO = event.newValue as AnimatorVO;
			
			if( asset )
			{
				if( event.isUndoAction )
				{
					document.removeAsset( asset.animators, oldValue );
					asset.fillFromAnimationSet( asset );
				}
				else 
				{
					var alreadyAdded:Boolean = false;
					for each( var animator:AnimatorVO in asset.animators )
					{
						if( animator.equals( newValue ) ) alreadyAdded = true;	
					}
					if( !alreadyAdded )	asset.animators.addItem(newValue);
					asset.fillFromAnimationSet( asset );
				}
			}
			
			commitHistoryEvent( event );
			
			dispatch( new DocumentModelEvent( DocumentModelEvent.OBJECTS_COLLECTION_UPDATED ) );
		}
		
	}
}