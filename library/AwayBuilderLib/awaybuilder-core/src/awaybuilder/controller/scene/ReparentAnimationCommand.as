package awaybuilder.controller.scene
{
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.history.HistoryEvent;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.AssetsModel;
	import awaybuilder.model.vo.DroppedAssetVO;
	import awaybuilder.model.vo.scene.AnimationNodeVO;
	import awaybuilder.model.vo.scene.AnimationSetVO;
	import awaybuilder.model.vo.scene.AssetVO;
	import awaybuilder.model.vo.scene.SharedAnimationNodeVO;
	
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.events.PropertyChangeEvent;

	public class ReparentAnimationCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		[Inject]
		public var assets:AssetsModel;
		
		override public function execute():void
		{
			saveOldValue( event, event.newValue );
			
			var animationSet:AnimationSetVO;
			
			for each( var item:DroppedAssetVO in event.newValue ) 
			{
				
				if( item.value is AnimationNodeVO )
				{
					if( item.newParent == item.oldParent ) return;
					
					if( item.newParent )
					{
						animationSet = item.newParent as AnimationSetVO;
						if( animationSet && !itemIsInList(animationSet.animations, item.value) ) 
						{
							if( item.newPosition < animationSet.animations.length )
							{
								animationSet.animations.addItemAt( new SharedAnimationNodeVO(item.value as AnimationNodeVO), item.newPosition );
							}
							else
							{
								animationSet.animations.addItem( new SharedAnimationNodeVO(item.value as AnimationNodeVO) );
							}
							animationSet.fillFromAnimationSet( animationSet );
						}
					}
				}
			}
			
			animationSet.fillFromAnimationSet( animationSet );
			
			commitHistoryEvent( event );
		}
		private function itemIsInList( collection:ArrayCollection, asset:AssetVO ):Boolean
		{
			for each( var a:AssetVO in collection )
			{
				if( a.equals( asset ) ) return true;
			}
			return false;
		}
		
		private function removeItem( source:ArrayCollection, oddItem:AssetVO ):void
		{
			for (var i:int = 0; i < source.length; i++) 
			{
				var item:AssetVO = source[i] as AssetVO;
				if( item.equals( oddItem ) )
				{
					source.removeItemAt( i );
					i--;
				}
			}
		}
		
		override protected function saveOldValue( event:HistoryEvent, prevValue:Object ):void 
		{
			if( !event.oldValue ) 
			{
				var oldValue:Vector.<DroppedAssetVO> = new Vector.<DroppedAssetVO>();
				for each( var item:DroppedAssetVO in event.newValue ) 
				{
					var newItem:DroppedAssetVO = new DroppedAssetVO();
					newItem.value = item.value;
					newItem.newParent = item.oldParent;
					newItem.newPosition = item.newPosition;
					newItem.oldParent = item.newParent;
					newItem.oldPosition = item.oldPosition;
					oldValue.push(newItem);
				}
				event.oldValue = oldValue;
			}
		}
		
	}
}