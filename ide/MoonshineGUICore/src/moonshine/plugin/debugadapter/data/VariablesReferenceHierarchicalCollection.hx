/*
	Copyright 2021 Prominic.NET, Inc.

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

import haxe.ds.ObjectMap;
import haxe.Json;
import openfl.events.Event;
import feathers.events.HierarchicalCollectionEvent;
import openfl.errors.RangeError;
import openfl.errors.IllegalOperationError;
import feathers.data.ArrayCollection;
import feathers.data.IHierarchicalCollection;
import openfl.events.EventDispatcher;
import moonshine.dsp.Scope;
import moonshine.dsp.Variable;

class VariablesReferenceHierarchicalCollection extends EventDispatcher implements IHierarchicalCollection<Any> {
	public function new() {
		super();
	}

	private var _scopes:ArrayCollection<Scope> = new ArrayCollection();
	private var _variablesReferenceToVariables:Map<{}, ArrayCollection<Variable>> = [];

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
			return this._scopes.length;
		}
		var scope = this._scopes.get(location[0]);
		var collection = this._variablesReferenceToVariables.get(scope);
		for (i in 1...location.length) {
			var index = location[i];
			var next = collection.get(index);
			collection = this._variablesReferenceToVariables.get(next);
		}
		return collection.length;
	}

	public function get(location:Array<Int>):Any {
		if (location == null || location.length == 0) {
			throw new RangeError('Item not found at location: ${location}');
		}
		var scope = this._scopes.get(location[0]);
		if (location.length == 1) {
			return scope;
		}
		var collection = this._variablesReferenceToVariables.get(scope);
		for (i in 1...location.length - 1) {
			var index = location[i];
			var next = collection.get(index);
			collection = this._variablesReferenceToVariables.get(next);
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
		return Reflect.hasField(item, "variablesReference") && Reflect.field(item, "variablesReference") > 0;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.locationOf`
	**/
	public function locationOf(item:Any):Array<Int> {
		if (Reflect.hasField(item, "type")) {
			var variable = (item : Variable);
			var result:Array<Int> = [];
			for (i in 0...this._scopes.length) {
				result.resize(1);
				result[0] = i;
				var scope = this._scopes.get(i);
				var collection = this._variablesReferenceToVariables.get(scope);
				if (this.findItemInBranch(collection, variable, result)) {
					return result;
				}
			}
			return null;
		}
		var scope = (item : Scope);
		var index = this._scopes.indexOf(scope);
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

	public function removeAll():Void {
		this._variablesReferenceToVariables.clear();
		this._scopes.removeAll();
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

	public function setScopes(scopes:Array<Scope>):Void {
		this._variablesReferenceToVariables.clear();
		this.populateCollectionsForParentReferences(scopes);
		this._scopes.array = scopes.copy();
		this.dispatchEvent(new HierarchicalCollectionEvent(HierarchicalCollectionEvent.RESET, null));
		this.dispatchEvent(new Event(Event.CHANGE));
	}

	public function setVariablesForScopeOrVar(variables:Array<Variable>, scopeOrVar:Any):Void {
		this.populateCollectionsForParentReferences(variables);
		var collection = this._variablesReferenceToVariables.get(scopeOrVar);
		collection.array = variables.copy();
		this.dispatchEvent(new HierarchicalCollectionEvent(HierarchicalCollectionEvent.RESET, null));
		this.dispatchEvent(new Event(Event.CHANGE));
	}

	private function populateCollectionsForParentReferences(references:Array<Any>):Void {
		for (scopeOrVar in references) {
			var variablesReference:Float = Reflect.field(scopeOrVar, "variablesReference");
			if (variablesReference > 0) {
				var collection = this._variablesReferenceToVariables.get(scopeOrVar);
				if (collection == null) {
					// everything starts out empty, but will be populated later
					this._variablesReferenceToVariables.set(scopeOrVar, new ArrayCollection());
				}
			}
		}
	}

	private function findItemInBranch(branchChildren:ArrayCollection<Variable>, itemToFind:Variable, result:Array<Int>):Bool {
		for (i in 0...branchChildren.length) {
			var item = branchChildren.get(i);
			if (item == itemToFind) {
				result.push(i);
				return true;
			}
			var itemChildren = this.isBranch(item) ? this._variablesReferenceToVariables.get(item) : null;
			if (itemChildren != null) {
				result.push(i);
				var found = this.findItemInBranch(itemChildren, itemToFind, result);
				if (found) {
					return true;
				}
				result.pop();
			}
		}
		return false;
	}
}
