package awaybuilder.controller.scene
{
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.history.HistoryEvent;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.AssetsModel;
	import awaybuilder.model.vo.DroppedAssetVO;
	import awaybuilder.model.vo.scene.AssetVO;
	import awaybuilder.model.vo.scene.EffectVO;
	import awaybuilder.model.vo.scene.LightVO;
	import awaybuilder.model.vo.scene.MaterialVO;
	import awaybuilder.model.vo.scene.SharedEffectVO;
	
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;

	public class ReparentMaterialEffectCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		[Inject]
		public var assets:AssetsModel;
		
		override public function execute():void
		{
			saveOldValue( event, event.newValue );
			
			if( event.isUndoAction )
			{
				undo();
				return;
			}
			var material:MaterialVO;
			
			for each( var item:DroppedAssetVO in event.newValue ) 
			{
				if( item.value is EffectVO )
				{
					if( item.newParent == item.oldParent ) return;
					
					if( item.newParent && !item.oldParent )
					{
						material = item.newParent as MaterialVO;
						if( material && !itemIsInList(material.effectMethods, item.value as AssetVO) ) 
						{
							if( item.newPosition < material.effectMethods.length )
							{
								material.effectMethods.addItemAt( new SharedEffectVO(item.value as EffectVO), item.newPosition );
							}
							else
							{
								material.effectMethods.addItem( new SharedEffectVO(item.value as EffectVO) );
							}
							material.fillFromMaterial( material );
						}
						
					}
				}
			}
			
			commitHistoryEvent( event );
		}
		private function undo():void
		{
			var material:MaterialVO;
			
			for each( var item:DroppedAssetVO in event.newValue ) 
			{
				if( item.value is LightVO )
				{
					
					if( item.oldParent )
					{ 
						material = item.oldParent as MaterialVO;
						if( material && itemIsInList(material.effectMethods, item.value as AssetVO) ) 
						{
							removeItem( material.effectMethods, item.value as AssetVO );
						}
					}
				}
			}
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