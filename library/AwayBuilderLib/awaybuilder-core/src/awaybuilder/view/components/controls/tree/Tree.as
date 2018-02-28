package awaybuilder.view.components.controls.tree
{
	import awaybuilder.model.vo.DroppedTreeItemVO;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.controls.treeClasses.ITreeDataDescriptor;
	import mx.core.DragSource;
	import mx.core.EventPriority;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	
	import spark.components.List;
	import spark.events.RendererExistenceEvent;
	import spark.layouts.supportClasses.DropLocation;
	
	use namespace mx_internal;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 *  Dispatched when a branch is closed or collapsed.
	 */
	[Event(name="itemClose", type="awaybuilder.view.components.controls.tree.TreeEvent")]
	
	/**
	 *  Dispatched when a branch is opened or expanded.
	 */
	[Event(name="itemOpen", type="awaybuilder.view.components.controls.tree.TreeEvent")]
	
	/**
	 *  Dispatched when a branch open or close is initiated.
	 */
	[Event(name="itemOpening", type="awaybuilder.view.components.controls.tree.TreeEvent")]
	
	[Event(name="itemDropped", type="awaybuilder.view.components.controls.tree.TreeEvent")]
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	/**
	 * Indentation for each tree level, in pixels. The default value is 17.
	 */
	[Style(name="indentation", type="Number", inherit="no", theme="spark")]
	
	/**
	 * Custom Spark Tree that is based on Spark List. Supports most of MX Tree
	 * features and does not have it's bugs.
	 */
	public class Tree extends List
	{
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public function Tree()
		{
			super();
			
			// Handle styles when getStyle() will return corrent values.
			//			itemRenderer = new ClassFactory(TreeItemRenderer);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		protected var _druggingOverItem:Boolean = false;
		
		private var refreshRenderersCalled:Boolean = false;
		
		private var renderersToRefresh:Vector.<ITreeItemRenderer> = new Vector.<ITreeItemRenderer>();
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  dataDescriptor
		//----------------------------------
		
		private var _dataDescriptor:ITreeDataDescriptor = new GenericDataDescriptor();
		
		[Bindable("dataDescriptorChange")]
		public function get dataDescriptor():ITreeDataDescriptor
		{
			return _dataDescriptor;
		}
		
		public function set dataDescriptor(value:ITreeDataDescriptor):void
		{
			if (_dataDescriptor == value)
				return;
			
			_dataDescriptor = value;
			if (_dataProvider)
			{
				_dataProvider.dataDescriptor = _dataDescriptor;
				refreshRenderers();
			}
			dispatchEvent(new Event("dataDescriptorChange"));
		}
		
		//----------------------------------
		//  dataProvider
		//----------------------------------
		
		private var _dataProvider:TreeDataProvider;
		
		override public function get dataProvider():IList
		{
			return _dataProvider;
		}
		
		override public function set dataProvider(value:IList):void
		{
			var typedValue:TreeDataProvider;
			if (value)
			{
				typedValue = value is TreeDataProvider ? TreeDataProvider(value) : new TreeDataProvider(value);
				typedValue.dataDescriptor = dataDescriptor;
			}
			
			if (_dataProvider)
			{
				_dataProvider.removeEventListener(TreeEvent.ITEM_CLOSE, dataProvider_someHandler);
				_dataProvider.removeEventListener(TreeEvent.ITEM_OPEN, dataProvider_someHandler);
				_dataProvider.removeEventListener(TreeEvent.ITEM_OPENING, dataProvider_someHandler);
			}
			
			_dataProvider = typedValue;
			super.dataProvider = typedValue;
			
			if (_dataProvider)
			{
				_dataProvider.addEventListener(TreeEvent.ITEM_CLOSE, dataProvider_someHandler);
				_dataProvider.addEventListener(TreeEvent.ITEM_OPEN, dataProvider_someHandler);
				_dataProvider.addEventListener(TreeEvent.ITEM_OPENING, dataProvider_someHandler);
			}
		}
		
		//----------------------------------
		//  iconField
		//----------------------------------
		
		private var _iconField:String = "icon";
		
		[Bindable("iconFieldChange")]
		public function get iconField():String
		{
			return _iconField;
		}
		
		public function set iconField(value:String):void
		{
			if (_iconField == value)
				return;
			
			_iconField = value;
			refreshRenderers();
			dispatchEvent(new Event("iconFieldChange"));
		}
		
		//----------------------------------
		//  iconOpenField
		//----------------------------------
		
		private var _iconOpenField:String = "icon";
		
		[Bindable("iconOpenFieldChange")]
		/**
		 * Field that will be searched for icon when showing open folder item.
		 */
		public function get iconOpenField():String
		{
			return _iconOpenField;
		}
		
		public function set iconOpenField(value:String):void
		{
			if (_iconOpenField == value)
				return;
			
			_iconOpenField = value;
			refreshRenderers();
			dispatchEvent(new Event("iconOpenFieldChange"));
		}
		
		//----------------------------------
		//  iconFunction
		//----------------------------------
		
		private var _iconFunction:Function;
		
		[Bindable("iconFunctionChange")]
		/**
		 * Icon function. Signature <code>function(item:Object, isOpen:Boolean, isBranch:Boolean):Class</code>.
		 */
		public function get iconFunction():Function
		{
			return _iconFunction;
		}
		
		public function set iconFunction(value:Function):void
		{
			if (_iconFunction == value)
				return;
			
			_iconFunction = value;
			refreshRenderers();
			dispatchEvent(new Event("iconFunctionChange"));
		}
		
		//----------------------------------
		//  iconsVisible
		//----------------------------------
		
		private var _iconsVisible:Boolean = true;
		
		[Bindable("iconsVisibleChange")]
		/**
		 * Field that will be searched for icon when showing open folder item.
		 */
		public function get iconsVisible():Boolean
		{
			return _iconsVisible;
		}
		
		public function set iconsVisible(value:Boolean):void
		{
			if (_iconsVisible == value)
				return;
			
			_iconsVisible = value;
			refreshRenderers();
			dispatchEvent(new Event("iconsVisibleChange"));
		}
		
		//----------------------------------
		//  useTextColors
		//----------------------------------
		
		private var _useTextColors:Boolean = true;
		
		[Bindable("useTextColorsChange")]
		/**
		 * MX components use "textRollOverColor" and "textSelectedColor" while Spark
		 * do not. Set this property to <code>true</code> to use them in tree.
		 */
		public function get useTextColors():Boolean
		{
			return _useTextColors;
		}
		
		public function set useTextColors(value:Boolean):void
		{
			if (_useTextColors == value)
				return;
			
			_useTextColors = value;
			refreshRenderers();
			dispatchEvent(new Event("useTextColorsChange"));
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------
		
		override public function updateRenderer(renderer:IVisualElement, itemIndex:int, data:Object):void
		{
			itemIndex = _dataProvider.getItemIndex(data);
			
			super.updateRenderer(renderer, itemIndex, data);
			
			var treeItemRenderer:ITreeItemRenderer = ITreeItemRenderer(renderer);
			treeItemRenderer.level = _dataProvider.getItemLevel(data);
			treeItemRenderer.isBranch = true;
			treeItemRenderer.isLeaf = false;
			treeItemRenderer.hasChildren = dataDescriptor.hasChildren(data);
			treeItemRenderer.isOpen = _dataProvider.isOpen(data);
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// refresh all renderers or only some of them
			var n:int;
			var i:int;
			var renderer:ITreeItemRenderer;
			if (refreshRenderersCalled)
			{
				refreshRenderersCalled = false;
				n = dataGroup.numElements;
				for (i = 0; i < n; i++)
				{
					renderer = dataGroup.getElementAt(i) as ITreeItemRenderer;
					if (renderer && renderer.data)
						updateRenderer(renderer, renderer.itemIndex, renderer.data);
				}
			}
			else if (renderersToRefresh.length > 0)
			{
				n = renderersToRefresh.length;
				for (i = 0; i < n; i++)
				{
					renderer = renderersToRefresh[i];
					if (renderer && renderer.data)
						updateRenderer(renderer, renderer.itemIndex, renderer.data);
				}
			}
			if (renderersToRefresh.length > 0)
				renderersToRefresh.splice(0, renderersToRefresh.length);
		}
		
		/**
		 * Handle <code>Keyboard.LEFT</code> and <code>Keyboard.RIGHT</code> as tree
		 * node collapsing and expanding.
		 */
		override protected function adjustSelectionAndCaretUponNavigation(event:KeyboardEvent):void
		{
			super.adjustSelectionAndCaretUponNavigation(event);
			
			if (!selectedItem)
				return;
			
			var navigationUnit:uint = mapKeycodeForLayoutDirection(event);
			if (navigationUnit == Keyboard.LEFT)
			{
				if (_dataProvider.isOpen(selectedItem))
				{
					expandItem(selectedItem, false);
				}
				else
				{
					var parent:Object = _dataProvider.getItemParent(selectedItem);
					if (parent)
						selectedItem = parent;
				}
			}
			else if (navigationUnit == Keyboard.RIGHT)
			{
				expandItem(selectedItem);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Checks if Spark Tree has it's custom styles defined.
		 */
		protected function hasOwnStyles():Boolean
		{
			return getStyle("disclosureOpenIcon") || 
				getStyle("disclosureClosedIcon") || getStyle("folderOpenIcon") ||
				getStyle("folderClosedIcon") || getStyle("defaultLeafIcon");
		}
		
		public function expandAll():void
		{
			for( var i:int = 0; i < dataProvider.length; i++ ) 
			{
				var item:Object = dataProvider.getItemAt( i );
				if (dataDescriptor.hasChildren(item))
				{
					var children:IList = IList(dataDescriptor.getChildren(item));
					_dataProvider.openBranch(children, item, true);
				}
			}
		}
		
		public function collapseAll():void
		{
			for( var i:int = 0; i < dataProvider.length; i++ ) 
			{
				var item:Object = dataProvider.getItemAt( i );
				if (dataDescriptor.hasChildren(item))
				{
					var children:IList = IList(dataDescriptor.getChildren(item));
					_dataProvider.closeBranch(children, item, true);
				}
			}
		}
		
		public function expandBranch(item:Object, cancelable:Boolean = true):void
		{
			if (dataDescriptor.hasChildren(item))
			{
				var children:IList = IList(dataDescriptor.getChildren(item));
				_dataProvider.openBranch(children, item, cancelable);
				for each( var child:Object in children )
				{
					expandBranch( child, cancelable );
				}
			}
		}
		
		public function expandItem(item:Object, open:Boolean = true, cancelable:Boolean = true):void
		{
			if (dataDescriptor.hasChildren(item))
			{
				var children:IList = IList(dataDescriptor.getChildren(item));
				if (open)
					_dataProvider.openBranch(children, item, cancelable);
				else
					_dataProvider.closeBranch(children, item, cancelable);
			}
		}
		
		public function refreshRenderers():void
		{
			refreshRenderersCalled = true;
			invalidateDisplayList();
		}
		
		public function refreshRenderer(renderer:ITreeItemRenderer):void
		{
			renderersToRefresh.push(renderer);
			invalidateDisplayList();
		}
		
		override public function ensureIndexIsVisible(index:int):void
		{
			if (!layout)
				return;
			
			var spDelta:Point = dataGroup.layout.getScrollPositionDeltaToElement(index);
			
			if (spDelta)
			{
				dataGroup.horizontalScrollPosition += spDelta.x;
				dataGroup.verticalScrollPosition += spDelta.y;
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overriden event handlers
		//
		//--------------------------------------------------------------------------
		
		override protected function dataGroup_rendererAddHandler(event:RendererExistenceEvent):void
		{
			super.dataGroup_rendererAddHandler( event );
			var renderer:ITreeItemRenderer = event.renderer as ITreeItemRenderer;
			if (!renderer)
				return;
			renderer.dropArea.addEventListener(DragEvent.DRAG_ENTER, renderer_dragEnterHandler);
			renderer.dropArea.addEventListener(DragEvent.DRAG_OVER, renderer_dragOverHandler);
			renderer.dropArea.addEventListener(DragEvent.DRAG_EXIT, renderer_dragExitHandler);
			renderer.dropArea.addEventListener(DragEvent.DRAG_DROP, renderer_dragDropHandler);
		}
		override protected function dataGroup_rendererRemoveHandler(event:RendererExistenceEvent):void
		{
			super.dataGroup_rendererRemoveHandler( event );
			var renderer:ITreeItemRenderer = event.renderer as ITreeItemRenderer;
			
			if (!renderer)
				return;
			
			renderer.dropArea.removeEventListener(DragEvent.DRAG_ENTER, renderer_dragEnterHandler);
			renderer.dropArea.removeEventListener(DragEvent.DRAG_OVER, renderer_dragOverHandler);
			renderer.dropArea.removeEventListener(DragEvent.DRAG_EXIT, renderer_dragExitHandler);
			renderer.dropArea.removeEventListener(DragEvent.DRAG_DROP, renderer_dragDropHandler);
		}
		
		protected function renderer_dragEnterHandler(event:DragEvent):void
		{
			var dropArea:UIComponent = event.target as UIComponent;
			var items:Vector.<Object> = event.dragSource.dataForFormat("itemsByIndex") as Vector.<Object>;
			
		}
		
		protected function renderer_dragOverHandler(event:DragEvent):void
		{
			event.stopPropagation();
			event.stopImmediatePropagation();
		}
		
		protected function renderer_dragDropHandler(event:DragEvent):void
		{
			var droppedItems:Dictionary = new Dictionary();
			var item:Object;
			var items:Vector.<Object> = event.dragSource.dataForFormat("itemsByIndex") as Vector.<Object>;
			var renderer:TreeItemRenderer = UIComponent(event.target).parent as TreeItemRenderer;
			
			for each( item in items )
			{
				var droppedItem:DroppedTreeItemVO = new DroppedTreeItemVO( item );
				droppedItems[item] = droppedItem;
			}
			
			var indices:Vector.<int> = selectedIndices; 
			for (var i:int = indices.length - 1; i >= 0; i--)
			{
				item = dataProvider.getItemAt( indices[i] );
				var oldParent:Object = _dataProvider.getItemParent(item);
				
				var branch:IList = oldParent ? IList(dataDescriptor.getChildren(oldParent)) : _dataProvider;
				var localIndex:int = branch.getItemIndex(item);
				
				droppedItems[item].oldPosition = localIndex;
				droppedItems[item].oldParent = oldParent;
			}
			
			for each( item in items )
			{
//				this.dataDescriptor.addChildAt( renderer.data, item, 0 );
				
				droppedItems[item].newParent = renderer.data;
				droppedItems[item].newPosition = 0;
			}
			
			var e:TreeEvent = new TreeEvent( TreeEvent.ITEM_DROPPED, false, false, droppedItems );
			dispatchEvent( e );
			
			renderer.showDropIndicator = false;
			_druggingOverItem = false;
		}
		
		protected function renderer_dragExitHandler(event:DragEvent):void
		{
			var dropArea:UIComponent = event.target as UIComponent;
			var renderer:ITreeItemRenderer = dropArea.parent as ITreeItemRenderer;
			renderer.showDropIndicator = false;
			_druggingOverItem = false;
		}
		
		
		private var _dragEnabled:Boolean = false;
		
		[Inspectable(defaultValue="false")]
		override public function get dragEnabled():Boolean
		{
			return _dragEnabled;
		}
		
		override public function set dragEnabled(value:Boolean):void
		{
			if (value == _dragEnabled)
				return;
			_dragEnabled = value;
			
			if (_dragEnabled)
			{
				addEventListener(DragEvent.DRAG_START, dragStartHandler, false, EventPriority.DEFAULT_HANDLER);
				addEventListener(DragEvent.DRAG_COMPLETE, dragCompleteHandler, false, EventPriority.DEFAULT_HANDLER);
			}
			else
			{
				removeEventListener(DragEvent.DRAG_START, dragStartHandler, false);
				removeEventListener(DragEvent.DRAG_COMPLETE, dragCompleteHandler, false);
			}
		}
		
		private var _dropEnabled:Boolean = false;
		
		[Inspectable(defaultValue="false")]
		override public function get dropEnabled():Boolean
		{
			return _dropEnabled;
		}
		
		override public function set dropEnabled(value:Boolean):void
		{
			if (value == _dropEnabled)
				return;
			_dropEnabled = value;
			
			if (_dropEnabled)
			{
				addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler, false, EventPriority.DEFAULT_HANDLER);
				addEventListener(DragEvent.DRAG_EXIT, dragExitHandler, false, EventPriority.DEFAULT_HANDLER);
				addEventListener(DragEvent.DRAG_OVER, dragOverHandler, false, EventPriority.DEFAULT_HANDLER);
				addEventListener(DragEvent.DRAG_DROP, dragDropHandler, false, EventPriority.DEFAULT_HANDLER);
			}
			else
			{
				removeEventListener(DragEvent.DRAG_ENTER, dragEnterHandler, false);
				removeEventListener(DragEvent.DRAG_EXIT, dragExitHandler, false);
				removeEventListener(DragEvent.DRAG_OVER, dragOverHandler, false);
				removeEventListener(DragEvent.DRAG_DROP, dragDropHandler, false);
			}
		}
		override protected function dragOverHandler(event:DragEvent):void
		{
			if (event.isDefaultPrevented())
				return;
			var dropLocation:DropLocation = calculateDropLocation(event);
			if (dropLocation)
			{
				DragManager.acceptDragDrop(this);
				// Show focus
				drawFocusAnyway = true;
				drawFocus(true);
				
				// Notify manager we can drop
				DragManager.showFeedback(event.ctrlKey ? DragManager.COPY : DragManager.MOVE);
				
				// Show drop indicator
				layout.showDropIndicator(dropLocation);
			}
			else
			{
				
				// Hide if previously showing
				layout.hideDropIndicator();
				
				// Hide focus
				drawFocus(false);
				drawFocusAnyway = false;
				
				if( _druggingOverItem ) return;
				
				// Notify manager we can't drop
				DragManager.showFeedback(DragManager.NONE);
			}
		}
		override protected function dragDropHandler(event:DragEvent):void
		{
			var droppedItems:Dictionary = new Dictionary();
			if (event.isDefaultPrevented())
				return;
			
			if (_dataProvider)
				_dataProvider.allowIncorrectIndexes = true;
			
			var branch:IList;
			var localIndex:int;
			var item:Object;
			
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
			DragManager.showFeedback(event.ctrlKey ? DragManager.COPY : DragManager.MOVE);
			
			var dragSource:DragSource = event.dragSource;
			var items:Vector.<Object> = dragSource.dataForFormat("itemsByIndex") as Vector.<Object>;
			
			for each( item in items )
			{
				var droppedItem:DroppedTreeItemVO = new DroppedTreeItemVO( item );
				droppedItems[item] = droppedItem;
			}
			
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
					if (indices[i] < dropIndex) dropIndex--;
					
					item = dataProvider.getItemAt( indices[i] );
					var oldParent:Object = _dataProvider.getItemParent(item);
					
					branch = oldParent ? IList(dataDescriptor.getChildren(oldParent)) : _dataProvider;
					localIndex = branch.getItemIndex(item);
					
					droppedItems[item].oldPosition = localIndex;
					droppedItems[item].oldParent = oldParent;
//					moveItemFrom(indices[i]);
					
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
			
			var copyItems:Boolean = (event.action == DragManager.COPY);
			for (i = 0; i < items.length; i++)
			{
				// Get the item, clone if needed
				item = items[i];
				if (copyItems)
					item = copyItemWithUID(item);
				
				// Copy the data
				var effectiveItem:Object = dataProvider.getItemAt( dropIndex );
				var parent:Object = _dataProvider.getItemParent(effectiveItem);
				branch = parent ? IList(dataDescriptor.getChildren(parent)) : _dataProvider;
				localIndex = branch.getItemIndex(effectiveItem);
				
				droppedItems[item].newParent = parent;
				droppedItems[item].newPosition = localIndex;
				
//				dropItemTo( item, dropIndex + i );
				
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
			if (_dataProvider)
				_dataProvider.allowIncorrectIndexes = false;
			
			var e:TreeEvent = new TreeEvent( TreeEvent.ITEM_DROPPED, false, false, droppedItems );
			dispatchEvent( e );
		}
		private function compareValues(a:int, b:int):int
		{
			return a - b;
		} 
		
		protected function calculateDropLocation(event:DragEvent):DropLocation
		{
			// Verify data format
			if (!enabled || !event.dragSource.hasFormat("itemsByIndex"))
				return null;
			
			if( _druggingOverItem ) return null;
			
			// Calculate the drop location
			return layout.calculateDropLocation(event);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		private function dataProvider_someHandler(event:TreeEvent):void
		{
			var clonedEvent:TreeEvent = TreeEvent(event.clone());
			if (dataGroup)
			{
				// find corresponding item renderer
				var n:int = dataGroup.numElements;
				for (var i:int = 0; i < n; i++)
				{
					var renderer:ITreeItemRenderer = dataGroup.getElementAt(i) as ITreeItemRenderer;
					if( renderer )
					{
						updateRenderer(renderer, renderer.itemIndex, renderer.data)
					}
					
					if (renderer && renderer.data == event.item)
						clonedEvent.itemRenderer = renderer;
				}
			}
			dispatchEvent(clonedEvent);
			if (clonedEvent.isDefaultPrevented())
				event.preventDefault();
		}
		
	}
}
