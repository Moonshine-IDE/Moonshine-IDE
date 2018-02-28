package awaybuilder.view.components.controls
{
	import awaybuilder.model.vo.scene.EffectVO;
	import awaybuilder.model.vo.scene.MaterialVO;
	import awaybuilder.model.vo.scene.SharedEffectVO;
	import awaybuilder.view.components.controls.tree.ITreeItemRenderer;
	import awaybuilder.view.components.controls.tree.Tree;
	
	import mx.core.DragSource;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	
	import spark.layouts.supportClasses.DropLocation;

	use namespace mx_internal;
	
	public class MaterialsTree extends Tree
	{
		public function MaterialsTree()
		{
			super();
		}
		
		override protected function renderer_dragEnterHandler(event:DragEvent):void
		{
			var dropArea:UIComponent = event.target as UIComponent;
			var items:Vector.<Object> = event.dragSource.dataForFormat("itemsByIndex") as Vector.<Object>;
			validateDropRenderer( event.target as UIComponent, event.dragSource.dataForFormat("itemsByIndex") as Vector.<Object> );
		}
		
		override protected function renderer_dragOverHandler(event:DragEvent):void
		{
			event.stopPropagation();
			event.stopImmediatePropagation();
			validateDropRenderer( event.target as UIComponent, event.dragSource.dataForFormat("itemsByIndex") as Vector.<Object> );
		}
		
		private function validateDropRenderer( dropArea:UIComponent, items:Vector.<Object> ):void
		{
			if( !items ) return;
			var renderer:ITreeItemRenderer = dropArea.parent as ITreeItemRenderer;
			if( renderer.data == items[0] ) return;
			if( renderer.data is SharedEffectVO ) return;
			if( renderer.data is EffectVO ) return;
			if( items[0] is SharedEffectVO ) return;

			if( items[0] is EffectVO )
			{
				renderer.showDropIndicator = true;
				DragManager.acceptDragDrop(dropArea);
				_druggingOverItem = true;
			}
		}
		
		override protected function calculateDropLocation(event:DragEvent):DropLocation
		{
			// Verify data format
			if (!enabled || !event.dragSource.hasFormat("itemsByIndex"))
				return null;
			
			if( _druggingOverItem ) return null;
			
			// Calculate the drop location
			var dropLocation:DropLocation = layout.calculateDropLocation(event);
			
			return dropLocation;
		}
		
//		override public function addDragData(dragSource:DragSource):void
//		{
//			dragSource.addHandler(copySelectedItemsForDragDrop, "itemsByIndex");
//			
//			// Calculate the index of the focus item within the vector
//			// of ordered items returned for the "itemsByIndex" format.
//			var caretIndex:int = 0;
//			var draggedIndices:Vector.<int> = selectedIndices;
//			var count:int = draggedIndices.length;
//			for (var i:int = 0; i < count; i++)
//			{
//				if (mouseDownIndex > draggedIndices[i])
//					caretIndex++;
//			}
//			dragSource.addData(caretIndex, "caretIndex");
//		}
//		
//		/**
//		 *  @private
//		 */
//		private function copySelectedItemsForDragDrop():Vector.<Object>
//		{
//			// Copy the vector so that we don't modify the original
//			// since selectedIndices returns a reference.
//			var draggedIndices:Vector.<int> = selectedIndices.slice(0, selectedIndices.length);
//			var result:Vector.<Object> = new Vector.<Object>(draggedIndices.length);
//			
//			// Sort in the order of the data source
//			draggedIndices.sort(compareValues);
//			
//			// Copy the items
//			var count:int = draggedIndices.length;
//			for (var i:int = 0; i < count; i++)
//			{
//				var item:Object = dataProvider.getItemAt(draggedIndices[i]);
//				if( item is EffectVO )
//				{
//					result[i] = new SharedEffectVO( item as EffectVO );
//				}
//				else
//				{
//					result[i] = dataProvider.getItemAt(draggedIndices[i]);
//				}
//				
//			}
//				  
//			return result;
//		}
//		
//		private function compareValues(a:int, b:int):int
//		{
//			return a - b;
//		} 
	}
}