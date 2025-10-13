package actionScripts.data;

import openfl.errors.IOError;
import openfl.errors.RangeError;
import actionScripts.valueObjects.FileWrapper;
import feathers.data.IHierarchicalCollection;
import feathers.events.FeathersEvent;
import feathers.events.HierarchicalCollectionEvent;
import openfl.errors.ArgumentError;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.EventDispatcher;

class FileWrapperHierarchicalCollection extends EventDispatcher implements IHierarchicalCollection<FileWrapper> {
	private static function defaultSortCompareFunction(a:FileWrapper, b:FileWrapper):Int {
		if (a.file.fileBridge.isDirectory && !b.file.fileBridge.isDirectory) {
			return -1;
		}
		if (!a.file.fileBridge.isDirectory && b.file.fileBridge.isDirectory) {
			return 1;
		}
		if (a.name.toLowerCase() < b.name.toLowerCase()) {
			return -1;
		}
		if (a.name.toLowerCase() > b.name.toLowerCase()) {
			return 1;
		}
		return 0;
	}

	public function new(?roots:Array<FileWrapper>) {
		super();
		this.roots = roots;
	}

	private var _childrenMap:Map<String, Array<FileWrapper>> = [];

	private var _roots:Array<FileWrapper>;

	public var roots(get, set):Array<FileWrapper>;

	private function get_roots():Array<FileWrapper> {
		return _roots;
	}

	private function set_roots(value:Array<FileWrapper>):Array<FileWrapper> {
		if (_roots == value) {
			return _roots;
		}
		_roots = value;
		_childrenMap.clear();
		if (_roots != null && _sortCompareFunction != null) {
			_roots.sort(_sortCompareFunction);
		}
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.RESET, null);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return _roots;
	}

	private var _filterFunction:(FileWrapper) -> Bool = null;

	/**
		@see `feathers.data.IHierarchicalCollection.filterFunction`
	**/
	@:bindable("filterChange")
	public var filterFunction(get, set):(FileWrapper) -> Bool;

	private function get_filterFunction():(FileWrapper) -> Bool {
		return _filterFunction;
	}

	private function set_filterFunction(value:(FileWrapper) -> Bool):(FileWrapper) -> Bool {
		if (_filterFunction == value) {
			return _filterFunction;
		}
		_filterFunction = value;
		_childrenMap.clear();
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.FILTER_CHANGE, null);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return _filterFunction;
	}

	private var _sortCompareFunction:(FileWrapper, FileWrapper) -> Int = defaultSortCompareFunction;

	/**
		@see `feathers.data.IHierarchicalCollection.sortCompareFunction`
	**/
	@:bindable("sortChange")
	public var sortCompareFunction(get, set):(FileWrapper, FileWrapper) -> Int;

	private function get_sortCompareFunction():(FileWrapper, FileWrapper) -> Int {
		return _sortCompareFunction;
	}

	private function set_sortCompareFunction(value:(FileWrapper, FileWrapper) -> Int):(FileWrapper, FileWrapper) -> Int {
		if (value == null) {
			value = defaultSortCompareFunction;
		}
		if (_sortCompareFunction == value) {
			return _sortCompareFunction;
		}
		_sortCompareFunction = value;
		_childrenMap.clear();
		if (_roots != null && _sortCompareFunction != null) {
			_roots.sort(_sortCompareFunction);
		}
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.SORT_CHANGE, null);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return _sortCompareFunction;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.getLength`
	**/
	@:bindable("change")
	public function getLength(?location:Array<Int>):Int {
		if (location == null || location.length == 0) {
			if (_roots == null) {
				return 0;
			}
			return _roots.length;
		}
		var item = getItemAtLocation(location);
		if (item == null) {
			throw new ArgumentError('File does not exist at location: ${location}');
		}
		if (!item.file.fileBridge.isDirectory) {
			return 0;
		}
		var children = getChildren(item);
		if (children == null) {
			return 0;
		}
		return children.length;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.get`
	**/
	@:bindable("change")
	public function get(location:Array<Int>):FileWrapper {
		return getItemAtLocation(location);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.isBranch`
	**/
	public function isBranch(item:FileWrapper):Bool {
		if (item == null || !item.file.fileBridge.exists) {
			return false;
		}
		return item.file.fileBridge.isDirectory;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.locationOf`
	**/
	public function locationOf(item:FileWrapper):Array<Int> {
		var location:Array<Int> = [];
		if (item == null) {
			return null;
		}
		var current:FileWrapper = item;
		while (current != null) {
			for (i in 0..._roots.length) {
				var root = _roots[i];
				if (root.nativePath == current.nativePath) {
					location.unshift(i);
					return location;
				}
			}
			var parentFileLocation = current.file.fileBridge.parent;
			if (parentFileLocation == null) {
				break;
			}
			var parentWrapper = new FileWrapper(parentFileLocation, false, current.projectReference, true);
			var filesInParent = getChildren(parentWrapper);
			if (filesInParent == null) {
				return null;
			}
			var index = Lambda.findIndex(filesInParent, fileWrapper -> fileWrapper.nativePath == current.nativePath);
			if (index == -1) {
				return null;
			}
			location.unshift(index);
			current = parentWrapper;
		}
		// if no root was found in the loop above, then this item isn't actually
		// in the collection, so return null
		return null;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.locationOf`
	**/
	public function contains(item:FileWrapper):Bool {
		return locationOf(item) != null;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.set`
	**/
	public function set(location:Array<Int>, value:FileWrapper):Void {
		if (location.length == 1) {
			var index = location[0];
			var oldValue = _roots[index];
			_roots[index] = value;
			HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REPLACE_ITEM, location, value, oldValue);
			return;
		}
		throw new Error("not supported");
	}

	/**
		@see `feathers.data.IHierarchicalCollection.addAt`
	**/
	public function addAt(itemToAdd:FileWrapper, location:Array<Int>):Void {
		if (location.length == 1) {
			var index = location[0];
			_roots.insert(index, itemToAdd);
			HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.ADD_ITEM, location, itemToAdd);
			return;
		}
		throw new Error("not supported");
	}

	/**
		@see `feathers.data.IHierarchicalCollection.removeAt`
	**/
	public function removeAt(location:Array<Int>):FileWrapper {
		if (location.length == 1) {
			var index = location[0];
			var oldValue = _roots[index];
			_roots.splice(index, 1);
			HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REMOVE_ITEM, location, null, oldValue);
			return oldValue;
		}
		throw new Error("not supported");
	}

	/**
		@see `feathers.data.IHierarchicalCollection.remove`
	**/
	public function remove(item:FileWrapper):Void {
		throw new Error("not supported");
	}

	/**
		@see `feathers.data.IHierarchicalCollection.removeAll`
	**/
	public function removeAll(?location:Array<Int>):Void {
		throw new Error("not supported");
	}

	/**
		@see `feathers.data.IHierarchicalCollection.updateAt`
	**/
	public function updateAt(location:Array<Int>):Void {
		var item = getItemAtLocation(location, false, false);
		if (item != null) {
			// clear from the cache, if possible
			var items:Array<FileWrapper> = [item];
			while (items.length > 0) {
				var current = items.shift();
				this.removeFromCache(current, items);
			}
		}
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.UPDATE_ITEM, location);
	}

	public function updateItem(item:FileWrapper):Void {
		if (item == null) {
			return;
		}
		var items:Array<FileWrapper> = [item];
		while (items.length > 0) {
			var current = items.shift();
			this.removeFromCache(current, items);
		}
		var location = locationOf(item);
		if (location == null) {
			return;
		}
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.UPDATE_ITEM, location);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.updateAll`
	**/
	public function updateAll():Void {
		_childrenMap.clear();
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.UPDATE_ALL, null);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.refresh`
	**/
	public function refresh():Void {
		_childrenMap.clear();
	}

	private function getItemAtLocation(location:Array<Int>, useCache:Bool = true, validate:Bool = true):FileWrapper {
		if (location == null || location.length == 0) {
			return null;
		}
		var rootIndex = location[0];
		if (rootIndex >= _roots.length) {
			if (validate) {
				throw new RangeError('Expected location index less than ${roots.length}, but actual index is ${rootIndex}. Full location: <${location}>');
			} else {
				return null;
			}
		}
		var current:FileWrapper = _roots[rootIndex];
		var i = 1;
		while (i < location.length) {
			if (!current.file.fileBridge.isDirectory) {
				if (validate) {
					throw new IOError('Item is not a directory: ${current.nativePath}');
				} else {
					return null;
				}
			}
			var children = getChildren(current, useCache);
			if (children == null) {
				if (validate) {
					throw new IOError('Cannot read directory: ${current.nativePath}');
				} else {
					return null;
				}
			}
			var childIndex = location[i];
			if (childIndex >= children.length) {
				if (validate) {
					throw new RangeError('Expected location index less than ${children.length}, but actual index is ${childIndex}. Full location: <${location}>');
				} else {
					return null;
				}
				return null;
			}
			current = children[childIndex];
			if (current == null) {
				// this probably shouldn't happen, and maybe an exception
				// should be thrown instead?
				return null;
			}
			i++;
		}
		return current;
	}

	private function getChildren(fileWrapper:FileWrapper, useCache:Bool = true):Array<FileWrapper> {
		var children:Array<FileWrapper> = null;
		if (useCache) {
			children = _childrenMap.get(fileWrapper.nativePath);
			if (children != null) {
				return children;
			}
		}
		try {
			// we have our own cache, so don't worry about the FileWrapper's
			// also, don't check shallUpdateChildren because it is commonly false
			fileWrapper.updateChildren();
			children = fileWrapper.children;
		} catch (e:Dynamic) {
			return null;
		}
		if (children == null) {
			if (fileWrapper.file.fileBridge.isDirectory) {
				// this probably shouldn't happen, but better to be safe
				children = [];
			} else {
				return null;
			}
		}
		
		if (_filterFunction != null) {
			children = children.filter(_filterFunction);
		}
		if (_sortCompareFunction != null) {
			if (_filterFunction == null) {
				// don't use the original array returned by FileWrapper because
				// FileWrapper may modify it, and our sorting could be lost
				children = children.copy();
			}
			children.sort(_sortCompareFunction);
		}
		if (useCache) {
			_childrenMap.set(fileWrapper.nativePath, children);
		}
		return children;
	}

	private function removeFromCache(item:FileWrapper, items:Array<FileWrapper>):Void {
		if (item == null) {
			return;
		}	
		var children = _childrenMap.get(item.nativePath);
		_childrenMap.remove(item.nativePath);
		if (children != null) {
			for (child in children) {
				items.push(child);
			}
		}
	}
}
