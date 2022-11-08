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
import moonshine.dsp.Scope;
import moonshine.dsp.Variable;
import openfl.errors.IllegalOperationError;
import openfl.errors.RangeError;
import openfl.events.Event;
import openfl.events.EventDispatcher;

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

	public function removeAll(?location:Array<Int>):Void {
		if (location == null || location.length == 0) {
			this._variablesReferenceToVariables.clear();
			this._scopes.removeAll();
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

	public function setScopes(scopes:Array<Scope>):Void {
		this._variablesReferenceToVariables.clear();
		this.populateCollectionsForParentReferences(scopes);
		this._scopes.array = scopes.copy();
		this.dispatchEvent(new HierarchicalCollectionEvent(HierarchicalCollectionEvent.RESET, null));
		this.dispatchEvent(new Event(Event.CHANGE));
	}

	public function setVariablesForScopeOrVar(variables:Array<Variable>, scopeOrVar:Any):Void {
		var location = this.locationOf(scopeOrVar);
		if (location == null) {
			return;
		}
		this.populateCollectionsForParentReferences(variables);
		var collection = this._variablesReferenceToVariables.get(scopeOrVar);
		var oldItems = collection.array;
		for (i in 0...oldItems.length) {
			location.push(i);
			this.dispatchEvent(new HierarchicalCollectionEvent(HierarchicalCollectionEvent.REMOVE_ITEM, location, null, oldItems[i]));
			location.pop();
		}
		collection.array = variables.copy();
		for (i in 0...variables.length) {
			location.push(i);
			this.dispatchEvent(new HierarchicalCollectionEvent(HierarchicalCollectionEvent.ADD_ITEM, location, variables[i], null));
			location.pop();
		}
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
