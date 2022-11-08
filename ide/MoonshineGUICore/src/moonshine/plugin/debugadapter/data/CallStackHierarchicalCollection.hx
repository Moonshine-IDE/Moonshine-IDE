////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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


package moonshine.plugin.debugadapter.data;

import feathers.data.ArrayCollection;
import feathers.data.IHierarchicalCollection;
import feathers.events.HierarchicalCollectionEvent;
import moonshine.dsp.StackFrame;
import moonshine.dsp.Thread;
import openfl.errors.IllegalOperationError;
import openfl.errors.RangeError;
import openfl.events.Event;
import openfl.events.EventDispatcher;

class CallStackHierarchicalCollection extends EventDispatcher implements IHierarchicalCollection<Any> {
	public function new() {
		super();
	}

	private var _threads:ArrayCollection<Thread> = new ArrayCollection();
	private var _threadsToStackFrames:Map<Thread, ArrayCollection<StackFrame>> = [];

	@:flash.property
	public var filterFunction(get, set):(Any) -> Bool;

	private function get_filterFunction():(Any) -> Bool {
		throw new IllegalOperationError("Not implemented");
	}

	private function set_filterFunction(value:(Any) -> Bool):(Any) -> Bool {
		throw new IllegalOperationError("Not implemented");
	}

	@:flash.property
	public var sortCompareFunction(get, set):(Any, Any) -> Int;

	private function get_sortCompareFunction():(Any, Any) -> Int {
		throw new IllegalOperationError("Not implemented");
	}

	private function set_sortCompareFunction(value:(Any, Any) -> Int):(Any, Any) -> Int {
		throw new IllegalOperationError("Not implemented");
	}

	/**
		@see `feathers.data.IHierarchicalCollection.getLength`
	**/
	public function getLength(?location:Array<Int>):Int {
		if (location == null || location.length == 0) {
			return this._threads.length;
		}
		if (location.length > 1) {
			throw new RangeError('Item not found at location: ${location}');
		}
		var thread = this._threads.get(location[0]);
		var collection = this._threadsToStackFrames.get(thread);
		if (collection == null) {
			return 0;
		}
		return collection.length;
	}

	public function get(location:Array<Int>):Any {
		if (location == null || location.length == 0) {
			throw new RangeError('Item not found at location: ${location}');
		}
		var thread = this._threads.get(location[0]);
		if (location.length == 1) {
			return thread;
		}
		var collection = this._threadsToStackFrames.get(thread);
		if (collection == null || location.length > 2) {
			throw new RangeError('Item not found at location: ${location}');
		}
		return collection.get(location[location.length - 1]);
	}

	public function set(location:Array<Int>, value:Any):Void {
		throw new IllegalOperationError("Not implemented");
	}

	/**
		@see `feathers.data.IHierarchicalCollection.isBranch`
	**/
	public function isBranch(item:Any):Bool {
		if (item == null) {
			return false;
		}
		if (Reflect.hasField(item, "line")) {
			return false;
		}
		var thread = (item : Thread);
		return this._threadsToStackFrames.exists(thread);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.locationOf`
	**/
	public function locationOf(item:Any):Array<Int> {
		if (Reflect.hasField(item, "line")) {
			var stackFrame = (item : StackFrame);
			var result:Array<Int> = [];
			for (i in 0...this._threads.length) {
				result[0] = i;
				var thread = this._threads.get(i);
				var index = -1;
				var collection = this._threadsToStackFrames.get(thread);
				if (collection != null) {
					index = collection.indexOf(stackFrame);
				}
				if (index != -1) {
					result[1] = index;
					return result;
				}
			}
			return null;
		}
		var thread = (item : Thread);
		var index = this._threads.indexOf(thread);
		if (index == -1) {
			return null;
		}
		return [index];
	}

	/**
		@see `feathers.data.IHierarchicalCollection.locationOf`
	**/
	public function contains(item:Any):Bool {
		return this.locationOf(item) != null;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.addAt`
	**/
	public function addAt(itemToAdd:Any, location:Array<Int>):Void {
		throw new IllegalOperationError("Not implemented");
	}

	/**
		@see `feathers.data.IHierarchicalCollection.removeAt`
	**/
	public function removeAt(location:Array<Int>):Any {
		throw new IllegalOperationError("Not implemented");
	}

	/**
		@see `feathers.data.IHierarchicalCollection.removeAt`
	**/
	public function remove(item:Any):Void {
		throw new IllegalOperationError("Not implemented");
	}

	public function removeAll(?location:Array<Int>):Void {
		if (location == null || location.length == 0) {
			this._threadsToStackFrames.clear();
			this._threads.removeAll();
			this.dispatchEvent(new HierarchicalCollectionEvent(HierarchicalCollectionEvent.REMOVE_ALL, null));
			this.dispatchEvent(new Event(Event.CHANGE));
			return;
		}
		throw new IllegalOperationError("Not implemented");
	}

	/**
		@see `feathers.data.IHierarchicalCollection.updateAt`
	**/
	public function updateAt(location:Array<Int>):Void {
		throw new IllegalOperationError("Not implemented");
	}

	/**
		@see `feathers.data.IHierarchicalCollection.updateAll`
	**/
	public function updateAll():Void {
		throw new IllegalOperationError("Not implemented");
	}

	/**
		@see `feathers.data.IHierarchicalCollection.refresh`
	**/
	public function refresh():Void {
		throw new IllegalOperationError("Not implemented");
	}

	public function setThreads(threads:Array<Thread>):Void {
		this._threadsToStackFrames.clear();
		this._threads.array = threads.copy();
		this.dispatchEvent(new HierarchicalCollectionEvent(HierarchicalCollectionEvent.RESET, null));
		this.dispatchEvent(new Event(Event.CHANGE));
	}

	public function setStackFramesForThread(stackFrames:Array<StackFrame>, thread:Thread):Void {
		if (stackFrames == null) {
			this._threadsToStackFrames.remove(thread);
		} else {
			var location = this.locationOf(thread);
			if (location == null) {
				return;
			}
			var collection = this._threadsToStackFrames.get(thread);
			if (collection == null) {
				collection = new ArrayCollection();
				this._threadsToStackFrames.set(thread, collection);
			}
			var oldItems = collection.array;
			for (i in 0...oldItems.length) {
				location.push(i);
				this.dispatchEvent(new HierarchicalCollectionEvent(HierarchicalCollectionEvent.REMOVE_ITEM, location, null, oldItems[i]));
				location.pop();
			}
			collection.array = stackFrames.copy();
			for (i in 0...stackFrames.length) {
				location.push(i);
				this.dispatchEvent(new HierarchicalCollectionEvent(HierarchicalCollectionEvent.ADD_ITEM, location, stackFrames[i], null));
				location.pop();
			}
		}
		this.dispatchEvent(new Event(Event.CHANGE));
	}
}
