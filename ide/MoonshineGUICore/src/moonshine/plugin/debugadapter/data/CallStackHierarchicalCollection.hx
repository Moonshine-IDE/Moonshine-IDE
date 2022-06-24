/*
	Copyright 2022 Prominic.NET, Inc.

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License

	Author: Prominic.NET, Inc.
	No warranty of merchantability or fitness of any kind.
	Use this software at your own risk.
 */

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
			var collection = this._threadsToStackFrames.get(thread);
			if (collection == null) {
				collection = new ArrayCollection();
				this._threadsToStackFrames.set(thread, collection);
			}
			var oldItems = collection.array;
			var location = this.locationOf(thread);
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
