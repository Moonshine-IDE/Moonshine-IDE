package awaybuilder.view.components.controls
{
	import awaybuilder.model.vo.scene.AnimationNodeVO;
	import awaybuilder.model.vo.scene.AssetVO;
	import awaybuilder.model.vo.scene.EffectVO;
	import awaybuilder.model.vo.scene.SharedEffectVO;
	import awaybuilder.view.components.controls.events.DroppedEvent;
	
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	import mx.core.DragSource;
	import mx.core.mx_internal;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	
	import spark.components.List;
	import spark.layouts.supportClasses.DropLocation;
	
	use namespace mx_internal;
	
	[Event(name="dropped", type="awaybuilder.view.components.controls.events.DroppedEvent")]
	
	public class DroppableAnimationsList extends List
	{
		public function DroppableAnimationsList()
		{
			super();
		}
		override protected function dragEnterHandler(event:DragEvent):void {
			if (event.isDefaultPrevented())
				return;
			
			var dropLocation:DropLocation = calculateDropLocation(event); 
			if (dropLocation) {
				DragManager.acceptDragDrop(this);
				
				// Create the dropIndicator instance. The layout will take care of
				// parenting, sizing, positioning and validating the dropIndicator.
				createDropIndicator();
				
				// Show focus
				drawFocusAnyway = true;
				drawFocus(true);
				
				// Notify manager we can drop
				DragManager.showFeedback(DragManager.LINK);
				
				// Show drop indicator
				layout.showDropIndicator(dropLocation);
			}
			else {
				DragManager.showFeedback(DragManager.NONE);
			}
		}
		
		override protected function dragOverHandler(event:DragEvent):void {
			if (event.isDefaultPrevented())
				return;
			
			var dropLocation:DropLocation = calculateDropLocation(event);
			if (dropLocation) {
				// Show focus
				drawFocusAnyway = true;
				drawFocus(true);
				
				// Notify manager we can drop
				DragManager.showFeedback(DragManager.LINK);
				
				// Show drop indicator
				layout.showDropIndicator(dropLocation);
			}
			else {
				// Hide if previously showing
				layout.hideDropIndicator();
				
				// Hide focus
				drawFocus(false);
				drawFocusAnyway = false;
				
				// Notify manager we can't drop
				DragManager.showFeedback(DragManager.NONE);
			}
		}
		
		override protected function dragDropHandler(event:DragEvent):void
		{
			if (event.isDefaultPrevented())
				return;
			
			// Hide the drop indicator
			layout.hideDropIndicator();
			destroyDropIndicator();
			
			// Hide focus
			drawFocus(false);
			drawFocusAnyway = false;
			
			// Get the dropLocation
			var dropLocation:DropLocation = calculateDropLocation(event);
			if (!dropLocation)
				return;
			
			// Find the dropIndex
			var dropIndex:int = dropLocation.dropIndex;
			
			// Make sure the manager has the appropriate action
			DragManager.showFeedback(DragManager.MOVE);
			
			var dragSource:DragSource = event.dragSource;
			var items:Vector.<Object> = dragSource.dataForFormat("itemsByIndex") as Vector.<Object>;
			
			var caretIndex:int = -1;
			if (dragSource.hasFormat("caretIndex"))
				caretIndex = event.dragSource.dataForFormat("caretIndex") as int;
			
			// Clear the selection first to avoid extra work while adding and removing items.
			// We will set a new selection further below in the method.
			var indices:Vector.<int> = selectedIndices; 
			setSelectedIndices(new Vector.<int>(), false);
			validateProperties(); // To commit the selection
			
			// If we are reordering the list, remove the items now,
			// adjusting the dropIndex in the mean time.
			// If the items are drag moved to this list from a different list,
			// the drag initiator will remove the items when it receives the
			// DragEvent.DRAG_COMPLETE event.
			if (dragMoveEnabled &&
				event.action == DragManager.MOVE &&
				event.dragInitiator == this)
			{
				// Remove the previously selected items
				indices.sort(compareValues);
				for (var i:int = indices.length - 1; i >= 0; i--)
				{
					if (indices[i] < dropIndex)
						dropIndex--;
					dataProvider.removeItemAt(indices[i]);
				}
			}
			
			// Drop the items at the dropIndex
			var newSelection:Vector.<int> = new Vector.<int>();
			
			// Update the selection with the index of the caret item
			if (caretIndex != -1)
				newSelection.push(dropIndex + caretIndex);
			
			// Create dataProvider if needed
			if (!dataProvider)
				dataProvider = new ArrayCollection();
			
			//			var copyItems:Boolean = (event.action == DragManager.COPY);
			for (i = 0; i < items.length; i++)
			{
				// Get the item, clone if needed
				var asset:AssetVO = new SharedEffectVO( items[i] as EffectVO );
				//				if (copyItems)
				//					item = copyItemWithUID(item);
				
				// Copy the data
				dataProvider.addItemAt( asset, dropIndex + i);
				dispatchEvent( new DroppedEvent( DroppedEvent.DROPPED, asset, dropIndex + i ) );
				
				// Update the selection
				if (i != caretIndex)
					newSelection.push(dropIndex + i);
			}
			
			// Set the selection
			setSelectedIndices(newSelection, false);
			
			// Scroll the caret index in view
			if (caretIndex != -1)
			{
				// Sometimes we may need to scroll several times as for virtual layouts
				// this is not guaranteed to bring in the element in view the first try
				// as some items in between may not be loaded yet and their size is only
				// estimated.
				var delta:Point;
				var loopCount:int = 0;
				while (loopCount++ < 10)
				{
					validateNow();
					delta = layout.getScrollPositionDeltaToElement(dropIndex + caretIndex);
					if (!delta || (delta.x == 0 && delta.y == 0))
						break;
					layout.horizontalScrollPosition += delta.x;
					layout.verticalScrollPosition += delta.y;
				}
			}
		}
		
		private function calculateDropLocation(event:DragEvent):DropLocation {
			if (!enabled || !event.dragSource.hasFormat("itemsByIndex"))
				return null;
			try 
			{
				var items:Vector.<Object> = event.dragSource.dataForFormat("itemsByIndex") as Vector.<Object>;
				for (var i:int = 0; i < items.length; i++) 
				{
					var asset:AnimationNodeVO = items[i] as AnimationNodeVO;
					if( !asset ) 
						return null;
					for each( var light:AnimationNodeVO in dataProvider ) 
					{
						
						if( light.equals(asset) ) 
						{
							return null;
						}
					}
				}
			}
			catch( error:Error )
			{
				trace( error.message );
			}
			
			return layout.calculateDropLocation(event);
		}
		
		private function compareValues(a:int, b:int):int {
			return a - b;
		}
	}
}