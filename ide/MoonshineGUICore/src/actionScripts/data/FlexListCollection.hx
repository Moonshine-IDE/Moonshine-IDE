////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2025. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.data;

import feathers.data.IFlatCollection;
import feathers.events.FeathersEvent;
import feathers.events.FlatCollectionEvent;
import mx.collections.ArrayList;
import mx.collections.ICollectionView;
import mx.collections.IList;
import mx.collections.Sort;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import openfl.errors.IllegalOperationError;
import openfl.errors.RangeError;
import openfl.events.Event;
import openfl.events.EventDispatcher;

/**
	Exposes a Flex `IList` to Feathers UI using the `IFlatCollection` interface.
**/
class FlexListCollection extends EventDispatcher implements IFlatCollection<Dynamic> {
	/**
		Creates a `FlexListCollection` instance.
	**/
	public function new(?source:IList) {
		super();
		if (source == null) {
			source = new ArrayList();
		}
		this.list = source;
	}

	private var _ignoreCollectionChange:Bool = false;

	/**
		The underlying Flex `IList`.
	**/
	@:bindable("reset")
	public var list(default, set):IList;

	public function set_list(value:IList):IList {
		if (list == value) {
			return list;
		}
		if (list != null) {
			list.removeEventListener(CollectionEvent.COLLECTION_CHANGE, flexListCollection_list_collectionChangeHandler);
		}
		if (value == null) {
			value = new ArrayList();
		}
		list = value;
		list.addEventListener(CollectionEvent.COLLECTION_CHANGE, flexListCollection_list_collectionChangeHandler);
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.RESET, -1);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return list;
	}

	/**
		@see `feathers.data.IFlatCollection.length`
	**/
	@:bindable("change")
	public var length(get, never):Int;

	private function get_length():Int {
		return list.length;
	}

	/**
		@see `feathers.data.IFlatCollection.filterFunction`
	**/
	@:bindable("filterChange")
	public var filterFunction(get, set):(Dynamic) -> Bool;

	private function get_filterFunction():(Dynamic) -> Bool {
		if ((list is ICollectionView)) {
			var collectionView:ICollectionView = cast list;
			return collectionView.filterFunction;
		}
		return null;
	}

	private function set_filterFunction(value:(Dynamic) -> Bool):(Dynamic) -> Bool {
		if ((list is ICollectionView)) {
			var collectionView:ICollectionView = cast list;
			collectionView.filterFunction = value;
			collectionView.refresh();
			return collectionView.filterFunction;
		}
		throw new IllegalOperationError("filterFunction requires list to implement ICollectionView");
	}

	private var _sortCompareFunction:(Dynamic, Dynamic) -> Int;

	/**
		@see `feathers.data.IFlatCollection.sortCompareFunction`
	**/
	@:bindable("sortChange")
	public var sortCompareFunction(get, set):(Dynamic, Dynamic) -> Int;

	private function get_sortCompareFunction():(Dynamic, Dynamic) -> Int {
		return _sortCompareFunction;
	}

	private function set_sortCompareFunction(value:(Dynamic, Dynamic) -> Int):(Dynamic, Dynamic) -> Int {
		if ((list is ICollectionView)) {
			var collectionView:ICollectionView = cast list;
			_sortCompareFunction = value;
			if (_sortCompareFunction != null) {
				var sort = new Sort();
				sort.compareFunction = function(a:Dynamic, b:Dynamic, fields:Array<String> = null):Int {
					return _sortCompareFunction(a, b);
				};
				collectionView.sort = sort;
			} else {
				collectionView.sort = null;
			}
			collectionView.refresh();
			return _sortCompareFunction;
		}
		throw new IllegalOperationError("sortCompareFunction requires list to implement ICollectionView");
	}

	/**
		@see `feathers.data.IFlatCollection.get`
	**/
	@:bindable("change")
	public function get(index:Int):Dynamic {
		return list.getItemAt(index);
	}

	/**
		@see `feathers.data.IFlatCollection.set`
	**/
	public function set(index:Int, item:Dynamic):Void {
		if (index == list.length) {
			// for some reason, using setItemAt() to insert at the end throws a
			// RangeError, so use addItem() instead
			list.addItem(item);
		} else {
			var oldItem = list.getItemAt(index);
			var oldIgnoreCollectionChange = _ignoreCollectionChange;
			_ignoreCollectionChange = true;
			list.setItemAt(item, index);
			_ignoreCollectionChange = oldIgnoreCollectionChange;
			var filterFunction = this.filterFunction;
			if (filterFunction != null) {
				var includeItem = filterFunction(item);
				if (includeItem) {
					FlatCollectionEvent.dispatch(this, FlatCollectionEvent.REPLACE_ITEM, index, item, oldItem);
					FeathersEvent.dispatch(this, Event.CHANGE);
				} else {
					// if the new item is excluded, the old item at this index
					// is removed instead of being replaced by the new item
					FlatCollectionEvent.dispatch(this, FlatCollectionEvent.REMOVE_ITEM, index, null, oldItem);
					FeathersEvent.dispatch(this, Event.CHANGE);
				}
			} else {
				FlatCollectionEvent.dispatch(this, FlatCollectionEvent.REPLACE_ITEM, index, item, oldItem);
				FeathersEvent.dispatch(this, Event.CHANGE);
			}
		}
	}

	/**
		@see `feathers.data.IFlatCollection.add`
	**/
	public function add(item:Dynamic):Void {
		list.addItem(item);
	}

	/**
		@see `feathers.data.IFlatCollection.addAt`
	**/
	public function addAt(item:Dynamic, index:Int):Void {
		list.addItemAt(item, index);
	}

	/**
		@see `feathers.data.IFlatCollection.addAll`
	**/
	public function addAll(collection:IFlatCollection<Dynamic>):Void {
		for (item in collection) {
			this.add(item);
		}
	}

	/**
		@see `feathers.data.IFlatCollection.addAllAt`
	**/
	public function addAllAt(collection:IFlatCollection<Dynamic>, index:Int):Void {
		for (item in collection) {
			this.addAt(item, index);
			index++;
		}
	}

	/**
		@see `feathers.data.IFlatCollection.reset`
	**/
	public function reset(collection:IFlatCollection<Dynamic> = null):Void {
		list.removeAll();
		if (collection != null) {
			for (item in collection) {
				list.addItem(item);
			}
		}
	}

	/**
		@see `feathers.data.IFlatCollection.remove`
	**/
	public function remove(item:Dynamic):Void {
		var index = list.getItemIndex(item);
		if (index == -1) {
			return;
		}
		list.removeItemAt(index);
	}

	/**
		@see `feathers.data.IFlatCollection.removeAt`
	**/
	public function removeAt(index:Int):Dynamic {
		return list.removeItemAt(index);
	}

	/**
		@see `feathers.data.IFlatCollection.removeAll`
	**/
	public function removeAll():Void {
		if (list.length == 0) {
			// nothing to remove
			return;
		}
		var oldIgnoreCollectionChange = _ignoreCollectionChange;
		_ignoreCollectionChange = true;
		list.removeAll();
		_ignoreCollectionChange = oldIgnoreCollectionChange;
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.REMOVE_ALL, -1);
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	/**
		@see `feathers.data.IFlatCollection.indexOf`
	**/
	public function indexOf(item:Dynamic):Int {
		return list.getItemIndex(item);
	}

	/**
		@see `feathers.data.IFlatCollection.contains`
	**/
	public function contains(item:Dynamic):Bool {
		return this.indexOf(item) != -1;
	}

	/**
		@see `feathers.data.IFlatCollection.iterator`
	**/
	public function iterator():Iterator<Dynamic> {
		return new FlexListIterator(list);
	}

	/**
		@see `feathers.data.IFlatCollection.updateAt`
	**/
	public function updateAt(index:Int):Void {
		if (index < 0 || index >= this.length) {
			throw new RangeError('Failed to update item at index ${index}. Expected a value between 0 and ${this.length - 1}.');
		}
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.UPDATE_ITEM, index);
	}

	/**
		@see `feathers.data.IFlatCollection.updateAll`
	**/
	public function updateAll():Void {
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.UPDATE_ALL, -1);
	}

	/**
		@see `feathers.data.IFlatCollection.refresh`
	**/
	public function refresh():Void {
		if ((list is ICollectionView)) {
			var collectionView:ICollectionView = cast list;
			collectionView.refresh();
			if (collectionView.filterFunction != null) {
				FlatCollectionEvent.dispatch(this, FlatCollectionEvent.FILTER_CHANGE, -1);
			}
			if (collectionView.sort != null) {
				FlatCollectionEvent.dispatch(this, FlatCollectionEvent.SORT_CHANGE, -1);
			}
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function flexListCollection_list_collectionChangeHandler(event:CollectionEvent):Void {
		if (_ignoreCollectionChange) {
			return;
		}
		switch (event.kind) {
			case CollectionEventKind.ADD:
				for (i in 0...event.items.length) {
					var item = event.items[i];
					var location = event.location + i;
					FlatCollectionEvent.dispatch(this, FlatCollectionEvent.ADD_ITEM, location, item);
					FeathersEvent.dispatch(this, Event.CHANGE);
				}
			case CollectionEventKind.MOVE:
				for (i in 0...event.items.length) {
					var item = event.items[i];
					var oldLocation = event.oldLocation + i;
					var location = event.location + i;
					FlatCollectionEvent.dispatch(this, FlatCollectionEvent.REMOVE_ITEM, oldLocation, item);
					FlatCollectionEvent.dispatch(this, FlatCollectionEvent.ADD_ITEM, location, item);
					FeathersEvent.dispatch(this, Event.CHANGE);
				}
			case CollectionEventKind.REPLACE:
				for (i in 0...event.items.length) {
					var item = event.items[i];
					var location = event.location + i;
					FlatCollectionEvent.dispatch(this, FlatCollectionEvent.REPLACE_ITEM, location, item);
					FeathersEvent.dispatch(this, Event.CHANGE);
				}
			case CollectionEventKind.REMOVE:
				for (i in 0...event.items.length) {
					var item = event.items[i];
					var location = event.location + i;
					FlatCollectionEvent.dispatch(this, FlatCollectionEvent.REMOVE_ITEM, location, item);
					FeathersEvent.dispatch(this, Event.CHANGE);
				}
			case CollectionEventKind.RESET:
				FlatCollectionEvent.dispatch(this, FlatCollectionEvent.RESET, -1);
				FeathersEvent.dispatch(this, Event.CHANGE);
			case CollectionEventKind.UPDATE:
				for (i in 0...event.items.length) {
					var item = event.items[i];
					var location = event.location + i;
					FlatCollectionEvent.dispatch(this, FlatCollectionEvent.UPDATE_ITEM, location, item);
				}
		}
	}
}
