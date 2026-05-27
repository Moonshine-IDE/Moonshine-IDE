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

package moonshine.data;

import actionScripts.valueObjects.ProjectVO;
import actionScripts.factory.FileLocation;
import openfl.errors.IOError;
import openfl.errors.RangeError;
import feathers.data.IHierarchicalCollection;
import feathers.events.FeathersEvent;
import feathers.events.HierarchicalCollectionEvent;
import moonshine.events.ProjectTreeViewCollectionEvent;
import openfl.errors.ArgumentError;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.EventDispatcher;

class ProjectTreeViewCollection extends EventDispatcher implements IHierarchicalCollection<ProjectTreeViewFileWrapper> {
	private static function defaultSortCompareFunction(a:ProjectTreeViewFileWrapper, b:ProjectTreeViewFileWrapper):Int {
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

	public function new(?roots:Array<ProjectTreeViewFileWrapper>) {
		super();
		this.roots = roots;
	}

	private var _childrenMap:Map<String, Array<ProjectTreeViewFileWrapper>> = [];
	private var _pendingDirectoryListings:Map<String, Bool> = [];

	private var _roots:Array<ProjectTreeViewFileWrapper>;

	public var roots(get, set):Array<ProjectTreeViewFileWrapper>;

	private function get_roots():Array<ProjectTreeViewFileWrapper> {
		return _roots;
	}

	private function set_roots(value:Array<ProjectTreeViewFileWrapper>):Array<ProjectTreeViewFileWrapper> {
		if (_roots == value) {
			return _roots;
		}
		_roots = value;
		_childrenMap.clear();
		_pendingDirectoryListings.clear();
		if (_roots != null && _sortCompareFunction != null) {
			_roots.sort(_sortCompareFunction);
		}
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.RESET, null);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return _roots;
	}

	private var _filterFunction:(ProjectTreeViewFileWrapper) -> Bool = null;

	/**
		@see `feathers.data.IHierarchicalCollection.filterFunction`
	**/
	@:bindable("filterChange")
	public var filterFunction(get, set):(ProjectTreeViewFileWrapper) -> Bool;

	private function get_filterFunction():(ProjectTreeViewFileWrapper) -> Bool {
		return _filterFunction;
	}

	private function set_filterFunction(value:(ProjectTreeViewFileWrapper) -> Bool):(ProjectTreeViewFileWrapper) -> Bool {
		if (_filterFunction == value) {
			return _filterFunction;
		}
		_filterFunction = value;
		_childrenMap.clear();
		_pendingDirectoryListings.clear();
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.FILTER_CHANGE, null);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return _filterFunction;
	}

	private var _sortCompareFunction:(ProjectTreeViewFileWrapper, ProjectTreeViewFileWrapper) -> Int = defaultSortCompareFunction;

	/**
		@see `feathers.data.IHierarchicalCollection.sortCompareFunction`
	**/
	@:bindable("sortChange")
	public var sortCompareFunction(get, set):(ProjectTreeViewFileWrapper, ProjectTreeViewFileWrapper) -> Int;

	private function get_sortCompareFunction():(ProjectTreeViewFileWrapper, ProjectTreeViewFileWrapper) -> Int {
		return _sortCompareFunction;
	}

	private function set_sortCompareFunction(value:(ProjectTreeViewFileWrapper, ProjectTreeViewFileWrapper) -> Int):(ProjectTreeViewFileWrapper, ProjectTreeViewFileWrapper) -> Int {
		if (value == null) {
			value = defaultSortCompareFunction;
		}
		if (_sortCompareFunction == value) {
			return _sortCompareFunction;
		}
		_sortCompareFunction = value;
		_childrenMap.clear();
		_pendingDirectoryListings.clear();
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
	public function get(location:Array<Int>):ProjectTreeViewFileWrapper {
		return getItemAtLocation(location);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.isBranch`
	**/
	public function isBranch(item:ProjectTreeViewFileWrapper):Bool {
		if (item == null || !item.file.fileBridge.exists) {
			return false;
		}
		return item.file.fileBridge.isDirectory;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.locationOf`
	**/
	public function locationOf(item:ProjectTreeViewFileWrapper):Array<Int> {
		var location:Array<Int> = [];
		if (item == null) {
			return null;
		}
		var current:ProjectTreeViewFileWrapper = item;
		while (current != null) {
			for (i in 0..._roots.length) {
				var root = _roots[i];
				if (root.nativePath == current.nativePath) {
					location.unshift(i);
					return location;
				}
			}
			var parentFileLocation = current.file.fileBridge.parent;
			if (parentFileLocation == null || !parentFileLocation.fileBridge.isDirectory) {
				break;
			}
			var parentWrapper = new ProjectTreeViewFileWrapper(parentFileLocation, false, current.project);
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
	public function contains(item:ProjectTreeViewFileWrapper):Bool {
		return locationOf(item) != null;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.set`
	**/
	public function set(location:Array<Int>, value:ProjectTreeViewFileWrapper):Void {
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
	public function addAt(itemToAdd:ProjectTreeViewFileWrapper, location:Array<Int>):Void {
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
	public function removeAt(location:Array<Int>):ProjectTreeViewFileWrapper {
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
	public function remove(item:ProjectTreeViewFileWrapper):Void {
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
		var item = getItemAtLocation(location, true, false);
		if (item != null) {
			// clear from the cache, if possible
			var items:Array<ProjectTreeViewFileWrapper> = [item];
			while (items.length > 0) {
				var current = items.shift();
				this.removeFromCache(current, items);
			}
		}
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.UPDATE_ITEM, location);
	}

	public function updateItem(item:ProjectTreeViewFileWrapper):Void {
		if (item == null) {
			return;
		}
		var items:Array<ProjectTreeViewFileWrapper> = [item];
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
		_pendingDirectoryListings.clear();
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.UPDATE_ALL, null);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.refresh`
	**/
	public function refresh():Void {
		_childrenMap.clear();
		_pendingDirectoryListings.clear();
	}

	private function getItemAtLocation(location:Array<Int>, useCache:Bool = true, validate:Bool = true):ProjectTreeViewFileWrapper {
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
		var current:ProjectTreeViewFileWrapper = _roots[rootIndex];
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

	private function getChildren(fileWrapper:ProjectTreeViewFileWrapper, useCache:Bool = true):Array<ProjectTreeViewFileWrapper> {
		var children:Array<ProjectTreeViewFileWrapper> = null;
		if (useCache) {
			children = _childrenMap.get(fileWrapper.nativePath);
			if (children != null) {
				return children;
			}
		}
		if (!fileWrapper.file.fileBridge.isDirectory) {
			return null;
		}

		children = [];
		if (useCache) {
			_childrenMap.set(fileWrapper.nativePath, children);
		}
		loadChildrenAsync(fileWrapper, useCache);
		return children;
	}

	private function loadChildrenAsync(fileWrapper:ProjectTreeViewFileWrapper, useCache:Bool):Void {
		var nativePath = fileWrapper.nativePath;
		if (_pendingDirectoryListings.exists(nativePath)) {
			return;
		}
		_pendingDirectoryListings.set(nativePath, true);
		fileWrapper.isWorking = true;
		fileWrapper.file.fileBridge.getDirectoryListingAsync(function(directoryListing:Array<FileLocation>):Void {
			_pendingDirectoryListings.remove(nativePath);
			fileWrapper.isWorking = false;
			var children = createChildren(fileWrapper, directoryListing);
			if (useCache) {
				_childrenMap.set(nativePath, children);
			}
			fileWrapper.children = children;
			dispatchEvent(new ProjectTreeViewCollectionEvent(ProjectTreeViewCollectionEvent.DIRECTORY_LISTING_RECEIVED, fileWrapper));
			var location = locationOf(fileWrapper);
			if (location != null) {
				HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.UPDATE_ITEM, location);
			}
		}, function(error:String):Void {
			_pendingDirectoryListings.remove(nativePath);
			fileWrapper.isWorking = false;
		});
	}

	private function createChildren(fileWrapper:ProjectTreeViewFileWrapper, directoryListing:Array<FileLocation>):Array<ProjectTreeViewFileWrapper> {
		var children:Array<ProjectTreeViewFileWrapper> = [];
		if (directoryListing == null) {
			return children;
		}
		var project = fileWrapper.project;
		var showHiddenPaths:Bool = false;
		if (project != null
				&& (Reflect.hasField(project, "showHiddenPaths") || Reflect.hasField(project, "get_showHiddenPaths"))) {
			showHiddenPaths = Reflect.getProperty(project, "showHiddenPaths") == true;
		}
		var hiddenPaths:Array<FileLocation> = null;
		if (project != null
				&& (Reflect.hasField(project, "hiddenPaths") || Reflect.hasField(project, "get_hiddenPaths"))) {
			hiddenPaths = Std.downcast(Reflect.getProperty(project, "hiddenPaths"), Array);
		}
		for (currentFile in directoryListing) {
			if (currentFile.fileBridge.isHidden) {
				continue;
			}
			if (!showHiddenPaths && isProjectHiddenPath(hiddenPaths, currentFile)) {
				continue;
			}
			var child = new ProjectTreeViewFileWrapper(currentFile, false, project);
			child.children = [];
			if (child.file.fileBridge.isDirectory) {
				child.isSourceFolder = isSourceFolder(child, project);
			}
			children.push(child);
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
		return children;
	}

	private function isProjectHiddenPath(hiddenPaths:Array<FileLocation>, currentFile:FileLocation):Bool {
		if (hiddenPaths == null) {
			return false;
		}
		var currentNativePath = currentFile.fileBridge.nativePath;
		for (i in 0...hiddenPaths.length) {
			var hiddenFile:FileLocation = hiddenPaths[i];
			if (hiddenFile != null && hiddenFile.fileBridge.nativePath == currentNativePath) {
				return true;
			}
		}
		return false;
	}

	private function isSourceFolder(wrapper:ProjectTreeViewFileWrapper, project:ProjectVO):Bool {
		if (project == null || (!Reflect.hasField(project, "sourceFolder") && !Reflect.hasField(project, "get_sourceFolder"))) {
			return false;
		}
		var sourceFolder:FileLocation = Std.downcast(Reflect.getProperty(project, "sourceFolder"), FileLocation);
		if (sourceFolder == null) {
			return false;
		}
		return wrapper.nativePath == sourceFolder.fileBridge.nativePath;
	}

	private function removeFromCache(item:ProjectTreeViewFileWrapper, items:Array<ProjectTreeViewFileWrapper>):Void {
		if (item == null) {
			return;
		}	
		var children = _childrenMap.get(item.nativePath);
		_childrenMap.remove(item.nativePath);
		_pendingDirectoryListings.remove(item.nativePath);
		if (children != null) {
			for (child in children) {
				items.push(child);
			}
		}
	}
}

class ProjectTreeViewFileWrapper {
	public function new(file:FileLocation, isRoot:Bool, project:ProjectVO) {
		this.file = file;
		this.isRoot = isRoot;
		this.project = project;
	}

	public var file(default, null):FileLocation;

	public var project(default, null):ProjectVO;

	public var isRoot(default, null):Bool;

	public var name(get, never):String;
	private function get_name():String
	{
		return file.fileBridge.name;
	}

	public var nativePath(get, never):String;
	private function get_nativePath():String
	{
		return file.fileBridge.nativePath;
	}

	public var isSourceFolder:Bool = false;

	public var children:Array<ProjectTreeViewFileWrapper>;

	public var isWorking:Bool = false;
	public var isDeleting:Bool = false;
}