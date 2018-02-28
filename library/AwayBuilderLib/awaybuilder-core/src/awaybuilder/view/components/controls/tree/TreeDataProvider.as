package awaybuilder.view.components.controls.tree
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.collections.ICollectionView;
	import mx.collections.IList;
	import mx.collections.ISort;
	import mx.collections.IViewCursor;
	import mx.controls.treeClasses.ITreeDataDescriptor;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	
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
	
	/**
	 * Special implementation of <code>IList</code> that server as a 
	 * <code>dataProvider</code> for spark <code>Tree</code>.
	 * Flattens given <code>ArrayCollection</code> so that it can be used in default
	 * spark <code>List</code>.
	 */
	public class TreeDataProvider extends EventDispatcher implements IList, ICollectionView
	{
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public function TreeDataProvider(dataProvider:IList)
		{
			_dataProvider = dataProvider;
			
			resetDataStructures();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		public var allowIncorrectIndexes:Boolean = false;
		
		protected var levelOfLastRemovedItem:int = -1;
		
		//--------------------------------------------------------------------------
		//
		//  Implementation of IList and ICollectionView: properties
		//
		//--------------------------------------------------------------------------
		
		private var _length:int = 0;
		
		[Bindable("collectionChange")]
		public function get length():int
		{
			return _length;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Implementation of IList: methods
		//
		//--------------------------------------------------------------------------
		
		public function addItem(item:Object):void
		{
			_dataProvider.addItem(item);
		}
		
		public function addItemAt(item:Object, index:int):void
		{
			if (index == 0)
			{
				_dataProvider.addItemAt(item, 0);
				return;
			}
			
			if (allowIncorrectIndexes && index > length)
				index = length;
			
			// this code usually executes when item is dropped into tree
			// choose correct place for drop, see
			// https://github.com/kachurovskiy/Spark-Tree/issues/6
			var previousItem:Object = getItemAt(index - 1);
			var previousItemLevel:int = getItemLevel(previousItem);
			var nextItem:Object = index < length ? getItemAt(index) : null;
			var nextItemLevel:int = nextItem ? getItemLevel(nextItem) : -1;
			var effectiveItem:Object;
			var indexDelta:int;
			if (nextItemLevel != previousItemLevel && nextItem &&
				levelOfLastRemovedItem == previousItemLevel)
			{
				indexDelta = 0;
				effectiveItem = nextItem;
			}
			else
			{
				indexDelta = 1;
				effectiveItem = previousItem;
			}
			
			var parent:Object = getItemParent(effectiveItem);
			var branch:IList = parent ? IList(dataDescriptor.getChildren(parent)) : _dataProvider;
			var localIndex:int = branch.getItemIndex(effectiveItem);
			branch.addItemAt(item, localIndex + indexDelta);
		}
		
		public function getItemAt(index:int, prefetch:int=0):Object
		{
			if (index < 0 || index >= _length)
				throw new Error("index " + index + " is out of bounds");
			
			if (index < cache.length)
				return cache[index];
			
			var branches:Vector.<IList> = new Vector.<IList>();
			var branchIndexes:Vector.<int> = new Vector.<int>();
			var branch:IList = _dataProvider;
			var branchLength:int = branch.length;
			var branchIndex:int = 0;
			var currentItem:Object = branch.getItemAt(branchIndex);
			var cacheIndex:int = 0;
			while (currentItem)
			{
				cache[cacheIndex++] = currentItem;
				if (index == 0)
					return currentItem;
				
				if (parentObjectsToOpenedBranches[currentItem] &&
					IList(parentObjectsToOpenedBranches[currentItem]).length > 0)
				{
					branches.push(branch);
					branchIndexes.push(branchIndex);
					branch = parentObjectsToOpenedBranches[currentItem];
					branchIndex = 0;
					branchLength = branch.length;
					index--;
					currentItem = branch.getItemAt(branchIndex);
				}
				else if (branchIndex < branchLength - 1)
				{
					branchIndex++;
					index--;
					currentItem = branch.getItemAt(branchIndex);
				}
				else if (branches.length > 0)
				{
					do
					{
						branch = branches.pop();
						branchIndex = branchIndexes.pop() + 1;
						branchLength = branch.length;
					} while (branches.length > 0 && branchIndex >= branchLength)
					index--;
					currentItem = branch.getItemAt(branchIndex);
				}
				else
				{
					throw new Error("index " + index + " is out of bounds");
				}
			}
			throw new Error("index " + index + " is out of bounds");
			return null;
		}
		
		public function getItemIndex(item:Object):int
		{
			if (!item)
				return -1;
			
			var cacheIndex:int = cache.indexOf(item);
			if (cacheIndex >= 0)
				return cacheIndex;
			
			var index:int = 0;
			var branches:Vector.<IList> = new Vector.<IList>();
			var branchIndexes:Vector.<int> = new Vector.<int>();
			var branch:IList = _dataProvider;
			var branchLength:int = branch.length;
			if (branchLength == 0)
				return -1;
			var branchIndex:int = 0;
			var currentItem:Object = branch.getItemAt(branchIndex);
			cacheIndex = 0;
			while (currentItem)
			{
				cache[cacheIndex++] = currentItem;
				if (currentItem == item)
					return index;
				
				if (parentObjectsToOpenedBranches[currentItem] &&
					IList(parentObjectsToOpenedBranches[currentItem]).length > 0)
				{
					branches.push(branch);
					branchIndexes.push(branchIndex);
					branch = parentObjectsToOpenedBranches[currentItem];
					branchIndex = 0;
					branchLength = branch.length;
					index++;
					currentItem = branch.getItemAt(branchIndex);
				}
				else if (branchIndex < branchLength - 1)
				{
					branchIndex++;
					index++;
					currentItem = branch.getItemAt(branchIndex);
				}
				else if (branches.length > 0)
				{
					do
					{
						branch = branches.pop();
						branchIndex = branchIndexes.pop() + 1;
						branchLength = branch.length;
					} while (branches.length > 0 && branchIndex >= branchLength)
					index++;
					if (branchIndex < branchLength)
						currentItem = branch.getItemAt(branchIndex);
					else
						return -1;
				}
				else
				{
					return -1;
				}
			}
			return -1;
		}
		
		public function itemUpdated(item:Object, property:Object = null, 
									oldValue:Object = null, newValue:Object = null):void
		{
			var parent:Object = getItemParent(item);
			var branch:IList = parent ? IList(dataDescriptor.getChildren(parent)) : _dataProvider;
			_dataProvider.itemUpdated(item, property, oldValue, newValue);
		}
		
		public function removeAll():void
		{
			_dataProvider.removeAll();
		}
		
		public function removeItemAt(index:int):Object
		{
			var item:Object = getItemAt(index);
			for (var p:* in openedBranchesToParentObjects)
			{
				var branch:IList = IList(p);
				var n:int = branch.length;
				for (var i:int = 0; i < n; i++)
				{
					if (branch.getItemAt(i) == item)
					{
						levelOfLastRemovedItem = branchLevels[branch];
						return branch.removeItemAt(i);
					}
				}
			}
			return null;
		}
		
		public function setItemAt(item:Object, index:int):Object
		{
			var currentItem:Object = getItemAt(index);
			var parent:Object = getItemParent(currentItem);
			var branch:IList = parent ? IList(dataDescriptor.getChildren(parent)) : _dataProvider;
			var localIndex:int = branch.getItemIndex(currentItem);
			return branch.setItemAt(item, localIndex)
		}
		
		public function toArray():Array
		{
			var result:Array = [];
			var branches:Vector.<IList> = new Vector.<IList>();
			var branchIndexes:Vector.<int> = new Vector.<int>();
			var branch:IList = _dataProvider;
			var branchLength:int = branch.length;
			var branchIndex:int = 0;
			var currentItem:Object = branch.getItemAt(branchIndex);
			while (true)
			{
				result.push(currentItem);
				
				if (parentObjectsToOpenedBranches[currentItem] &&
					IList(parentObjectsToOpenedBranches[currentItem]).length > 0)
				{
					branches.push(branch);
					branchIndexes.push(branchIndex);
					branch = parentObjectsToOpenedBranches[currentItem];
					branchIndex = 0;
					branchLength = branch.length;
					currentItem = branch.getItemAt(branchIndex);
				}
				else if (branchIndex < branchLength - 1)
				{
					branchIndex++;
					currentItem = branch.getItemAt(branchIndex);
				}
				else if (branches.length > 0)
				{
					do
					{
						branch = branches.pop();
						branchIndex = branchIndexes.pop() + 1;
						branchLength = branch.length;
					} while (branches.length > 0 && branchIndex >= branchLength)
					if (branchIndex < branchLength)
						currentItem = branch.getItemAt(branchIndex);
					else
						return null;
					
				}
				else
				{
					return result;
				}
			}
			return null; // never happen
		}
		
		//--------------------------------------------------------------------------
		//
		//  Implementation of ICollectionView: methods
		//
		//--------------------------------------------------------------------------
		
		public function get filterFunction():Function
		{
			return null;
		}
		
		public function set filterFunction(value:Function):void {}
		
		public function get sort():ISort
		{
			return null;
		}
		
		public function set sort(value:ISort):void {}
		
		public function createCursor():IViewCursor
		{
			return null;
		}
		
		public function contains(item:Object):Boolean
		{
			return parentObjectsToOpenedBranches[item] || getItemIndex(item) >= 0;
		}
		
		public function disableAutoUpdate():void {}
		
		public function enableAutoUpdate():void {}
		
		public function refresh():Boolean
		{
			resetCache();
			refreshLength();
			dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false,
				false, CollectionEventKind.REFRESH));
			return true;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		protected var openedBranchesToParentObjects:Dictionary;
		
		private var parentObjectsToOpenedBranches:Dictionary;
		
		/**
		 * Vector of open branches. It is always sorted by branch first element order
		 * in UI list.
		 */
		private var openedBranchesVector:Vector.<IList>;
		
		/**
		 * Should be set before operating.
		 */
		public var dataDescriptor:ITreeDataDescriptor;
		
		/**
		 * Cache contains currently visible items in the correct order. Cache can
		 * have smaller length - it means it does not surely contains all items.
		 */
		private var cache:Vector.<Object>;
		
		/**
		 * Maps branches to levels.
		 */
		protected var branchLevels:Dictionary;
		
		/**
		 * Caches levels since it's the most time-consuming operation.
		 */
		private var levelsCache:Dictionary;
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		private var _dataProvider:IList;
		
		public function get dataProvider():IList
		{
			return _dataProvider;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		private function resetDataStructures():void
		{
			openedBranchesToParentObjects = new Dictionary();
			parentObjectsToOpenedBranches = new Dictionary();
			openedBranchesVector = new Vector.<IList>();
			branchLevels = new Dictionary();
			resetCache();
			
			if (_dataProvider)
				openBranch(_dataProvider, null, false);
		}
		
		private function resetCache():void
		{
			cache = new Vector.<Object>();
			levelsCache = new Dictionary();
		}
		
		public function openBranch(branch:IList, parentObject:Object, cancelable:Boolean):void
		{
			if (parentObject && isOpen(parentObject))
				return;
			
			var treeEvent:TreeEvent;
			if (parentObject) // if parentObject == null - root node is opening
			{
				treeEvent = new TreeEvent(TreeEvent.ITEM_OPENING, false, cancelable,
					parentObject, null);
				treeEvent.opening = true;
				dispatchEvent(treeEvent);
				if (cancelable && treeEvent.isDefaultPrevented())
					return;
			}
			
			openedBranchesToParentObjects[branch] = parentObject;
			if (parentObject)
				parentObjectsToOpenedBranches[parentObject] = branch;
			insertBranchIntoVector(branch, parentObject);
			branch.addEventListener(CollectionEvent.COLLECTION_CHANGE,
				branch_collectionChangeHandler);
			
			_length += branch.length;
			
			// cache branch level so that getItemLevel() work faster
			var level:int = parentObject ? getItemLevel(parentObject) + 1 : 0;
			branchLevels[branch] = level;
			// fill levelsCache from branch items
			var n:int = branch.length;
			for (var i:int = 0; i < n; i++)
			{
				levelsCache[branch.getItemAt(i)] = level;
			}
			
			// clear untrusted area of cache
			var parentObjectIndex:int = parentObject ? getItemIndex(parentObject) : -1;
			if (parentObjectIndex >= 0 && cache.length > parentObjectIndex)
				cache.splice(parentObjectIndex, cache.length - parentObjectIndex);
			
			var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE,
				false, false, CollectionEventKind.ADD,
				parentObject ? parentObjectIndex + 1 : 0, -1, branch.toArray());
			dispatchEvent(event);
			
			if (parentObject)
				dispatchParentObjectUpdateEvent(parentObject, parentObjectIndex);
			
			if (parentObject) // if parentObject == null - root node is opening
			{
				treeEvent = new TreeEvent(TreeEvent.ITEM_OPEN, false, false, parentObject, null);
				dispatchEvent(treeEvent);
			}
		}
		
		private function dispatchParentObjectUpdateEvent(parentObject:Object, parentObjectIndex:int):void
		{
			var propertyChangeEvent:PropertyChangeEvent =
				new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE,
					false, false, PropertyChangeEventKind.UPDATE, null,
					null, null, parentObject);
			var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.UPDATE, 
				parentObjectIndex, parentObjectIndex, [ propertyChangeEvent ]);
			dispatchEvent(event);
		}
		
		private function insertBranchIntoVector(branch:IList, parentObject:Object):void
		{
			var index:int = 0;
			var n:int = openedBranchesVector.length;
			for (var i:int = 0; i < n; i++)
			{
				var tempBranch:IList = openedBranchesVector[i];
				if (tempBranch.getItemIndex(parentObject) >= 0)
				{
					index = i + 1;
					break;
				}
			}
			openedBranchesVector.splice(index, 0, branch);
		}
		
		/**
		 * Tries to close open branch.
		 *
		 * @return true if closing succeeded.
		 */
		public function closeBranch(branch:IList, parentObject:Object, cancelable:Boolean):Boolean
		{
			if (!parentObject || !isOpen(parentObject))
				return false;
			
			var treeEvent:TreeEvent;
			if (parentObject) // if parentObject == null - root node is opening
			{
				treeEvent = new TreeEvent(TreeEvent.ITEM_OPENING, false, cancelable,
					parentObject, null);
				treeEvent.opening = false;
				dispatchEvent(treeEvent);
				if (cancelable && treeEvent.isDefaultPrevented())
					return false;
			}
			
			if (!closeAllChildBranches(branch, parentObject, cancelable))
				return false;
			
			branch.removeEventListener(CollectionEvent.COLLECTION_CHANGE, branch_collectionChangeHandler);
			delete openedBranchesToParentObjects[branch];
			if (parentObject)
				delete parentObjectsToOpenedBranches[parentObject];
			openedBranchesVector.splice(openedBranchesVector.indexOf(branch), 1);
			
			_length -= branch.length;
			
			delete branchLevels[branch];
			
			// clear levelsCache from branch items
			var n:int = branch.length;
			var i:int;
			for (i = 0; i < n; i++)
			{
				delete levelsCache[branch.getItemAt(i)];
			}
			
			// clear untrusted area of cache
			var parentObjectIndex:int = parentObject ? getItemIndex(parentObject) : -1;
			if (parentObjectIndex >= 0 && cache.length >= parentObjectIndex)
				cache.splice(parentObjectIndex, cache.length - parentObjectIndex);
			
			var locationBase:int = parentObject ? parentObjectIndex + 1 : 0;
			for (i = n - 1; i >= 0; i--)
			{
				var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE,
					false, false, CollectionEventKind.REMOVE, locationBase + i,
					locationBase + i, [ branch.getItemAt(i) ]);
				dispatchEvent(event);
			}
			
			if (parentObject)
				dispatchParentObjectUpdateEvent(parentObject, parentObjectIndex);
			
			if (parentObject) // if parentObject == null - root node is opening
			{
				treeEvent = new TreeEvent(TreeEvent.ITEM_CLOSE, false, false, parentObject, null);
				dispatchEvent(treeEvent);
			}
			
			return true;
		}
		
		/**
		 * Used when object that is root of open branch is removed.
		 *
		 * @param branchStartIndex Index of branch start if it is available.
		 * If can be not available e.g. when we recieved refresh event and
		 * branch parent just dissapeared in the new version. In this case remove
		 * event is not dispatched.
		 */
		private function removeBranch(branch:IList, parentObject:Object, branchStartIndex:int = -1):void
		{
			if (!branch)
				return;
			branch.removeEventListener(CollectionEvent.COLLECTION_CHANGE, branch_collectionChangeHandler);
			
			var n:int = branch.length;
			var i:int;
			var event:CollectionEvent;
			for (i = 0; i < n; i++)
			{
				var item:Object = branch.getItemAt(i);
				
				delete levelsCache[item];
				
				if (branchStartIndex >= 0)
				{
					_length--;
					event = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE,
						false, false, CollectionEventKind.REMOVE, branchStartIndex,
						-1, [ item ]);
					dispatchEvent(event);
				}
				
				
				if (parentObjectsToOpenedBranches[item])
					removeBranch(parentObjectsToOpenedBranches[item], item, branchStartIndex);
			}
			
			delete openedBranchesToParentObjects[branch];
			if (parentObject)
				delete parentObjectsToOpenedBranches[parentObject];
			openedBranchesVector.splice(openedBranchesVector.indexOf(branch), 1);
			
			delete branchLevels[branch];
		}
		
		public function closeAllChildBranches(branch:IList, parentObject:Object, cancelable:Boolean):Boolean
		{
			var n:int = branch.length;
			var success:Boolean = true;
			for (var i:int = 0; i < n; i++)
			{
				var item:Object = branch.getItemAt(i);
				var childBranch:IList = parentObjectsToOpenedBranches[item];
				if (childBranch)
					success = closeBranch(childBranch, item, cancelable) && success; // order is significant
			}
			return success;
		}
		
		public function isOpen(item:Object):Boolean
		{
			return Boolean(parentObjectsToOpenedBranches[item]);
		}
		
		public function getItemLevel(item:Object):int
		{
			if (levelsCache[item] !== undefined)
				return levelsCache[item];
			
			for (var p:* in branchLevels)
			{
				var branch:IList = IList(p);
				var n:int = branch.length;
				for (var i:int = 0; i < n; i++)
				{
					if (branch.getItemAt(i) == item)
					{
						var level:int = branchLevels[p];
						levelsCache[item] = level;
						return level;
					}
				}
			}
			return 0;
		}
		
		public function getItemParent(item:Object):Object
		{
			for (var p:* in openedBranchesToParentObjects)
			{
				var branch:IList = IList(p);
				var n:int = branch.length;
				for (var i:int = 0; i < n; i++)
				{
					if (branch.getItemAt(i) == item)
						return openedBranchesToParentObjects[branch];
				}
			}
			return null;
		}
		
		private function refreshLength():void
		{
			var n:int = openedBranchesVector.length;
			_length = 0;
			for (var i:int = 0; i < n; i++)
			{
				_length += openedBranchesVector[i].length;
			}
		}
		
		private function closeEmptyOpenBranches():void
		{
			var branchesToClose:Vector.<IList> = new Vector.<IList>();
			var branch:IList;
			for each (branch in parentObjectsToOpenedBranches)
			{
				if (branch.length == 0)
					branchesToClose.push(branch);
			}
			for each (branch in branchesToClose)
			{
				closeBranch(branch, openedBranchesToParentObjects[branch], false);
			}
		}
		
		private function removeLostBranches(currentlyRemovedObject:Object):void
		{
			var parentObjects:Vector.<Object> = new Vector.<Object>();
			var parentObject:*;
			for (parentObject in parentObjectsToOpenedBranches)
			{
				if (getItemIndex(parentObject) == -1 && parentObject != currentlyRemovedObject)
					parentObjects.push(parentObject);
			}
			for each (parentObject in parentObjects)
			{
				removeBranch(parentObjectsToOpenedBranches[parentObject], parentObject);
			}
		}
		
		private function branchLocationToGlobalIndex(location:int, branch:IList, branchStartIndex:int):int
		{
			if (location == 0 || branch.length == 0)
				return branchStartIndex;
			
			var previousObject:Object = branch.getItemAt(Math.min(location - 1, branch.length - 1));
			while (parentObjectsToOpenedBranches[previousObject])
			{
				var childBranch:IList = parentObjectsToOpenedBranches[previousObject];
				previousObject = childBranch[childBranch.length - 1];
			}
			
			return getItemIndex(previousObject) + 1;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		private function branch_collectionChangeHandler(event:CollectionEvent):void
		{
			var newEvent:CollectionEvent = CollectionEvent(event.clone());
			var parentObject:Object = openedBranchesToParentObjects[event.target];
			var branchStartIndex:int = parentObject ? getItemIndex(parentObject) + 1 : 0;
			var kind:String = newEvent.kind;
			var items:Array = newEvent.items;
			var item:Object;
			var n:int = items ? items.length : 0;
			var i:int;
			
			// it's a too complex task - keeping cache up to date because we recieve
			// update events after update has been made and we do not know which
			// items were removed from what indexes
			resetCache();
			
			// convert local locations to global
			if (newEvent.location != -1)
				newEvent.location = branchLocationToGlobalIndex(newEvent.location,
					IList(event.target), branchStartIndex);
			if (newEvent.oldLocation != -1)
				newEvent.oldLocation = branchLocationToGlobalIndex(newEvent.oldLocation,
					IList(event.target), branchStartIndex);
			
			// check if some of open branches are now empty and needs to be closed
			closeEmptyOpenBranches();
			
			// items that were open branches could be removed. Remove links to them
			// from internal tree structures to avoid memory leaks
			//			removeLostBranches(items[0]);
			
			refreshLength();
			
			// check if we need to close some child object branches that have been updated/removed
			if (kind == CollectionEventKind.REMOVE || kind == CollectionEventKind.REPLACE)
			{
				// only one item can arrive
				item = items[0];
				if (parentObjectsToOpenedBranches[item])
					removeBranch(parentObjectsToOpenedBranches[item], item, newEvent.location + 1);
				
			}
			else if (kind == CollectionEventKind.UPDATE)
			{
				var propertyEvent:PropertyChangeEvent;
				for (i = 0; i < n; i++)
				{
					propertyEvent = items[i];
					item = propertyEvent.source;
					var branch:IList = parentObjectsToOpenedBranches[item];
					// if branch was removed or changed - close it in here
					if (branch && branch != dataDescriptor.getChildren(item) &&
						parentObjectsToOpenedBranches[item] != dataDescriptor.getChildren(item))
						closeBranch(branch, item, false);
				}
			}
			else if( kind == CollectionEventKind.REFRESH )
			{
				return;
			}
			
			dispatchEvent(newEvent);
		}
		
	}
}