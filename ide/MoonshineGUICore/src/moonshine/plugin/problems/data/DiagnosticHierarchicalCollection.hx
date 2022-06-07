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

package moonshine.plugin.problems.data;

import actionScripts.valueObjects.ProjectVO;
import feathers.data.IHierarchicalCollection;
import feathers.events.HierarchicalCollectionEvent;
import moonshine.plugin.problems.vo.MoonshineDiagnostic;
import openfl.errors.IllegalOperationError;
import openfl.errors.RangeError;
import openfl.events.Event;
import openfl.events.EventDispatcher;

class DiagnosticHierarchicalCollection extends EventDispatcher implements IHierarchicalCollection<Any> {
	public function new() {
		super();
	}

	private var _branches:Array<DiagnosticsByUri> = [];

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
			return this._branches.length;
		}
		if (location.length > 1) {
			throw new RangeError('Item not found at location: ${location}');
		}
		var branchIndex = location[0];
		if (branchIndex < 0 || branchIndex >= this._branches.length) {
			throw new RangeError('Expected branch index value between 0 and ${this._branches.length - 1}.');
		}
		var diagnosticsByUri = this._branches[branchIndex];
		var collection = diagnosticsByUri.diagnostics;
		return collection.length;
	}

	public function get(location:Array<Int>):Any {
		if (location == null || location.length == 0 || location.length > 2) {
			throw new RangeError('Item not found at location: ${location}');
		}
		var branchIndex = location[0];
		if (branchIndex < 0 || branchIndex >= this._branches.length) {
			throw new RangeError('Expected branch index value between 0 and ${this._branches.length - 1}.');
		}
		var diagnosticsByUri = this._branches[branchIndex];
		if (location.length == 1) {
			return diagnosticsByUri;
		}
		var collection = diagnosticsByUri.diagnostics;
		var leafIndex = location[1];
		if (leafIndex < 0 || leafIndex >= collection.length) {
			throw new RangeError('Expected leaf index value between 0 and ${collection.length - 1}.');
		}
		return collection[leafIndex];
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
		return (item is DiagnosticsByUri);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.locationOf`
	**/
	public function locationOf(item:Any):Array<Int> {
		if ((item is DiagnosticsByUri)) {
			var diagnosticsByUri = cast(item, DiagnosticsByUri);
			var index = Lambda.findIndex(this._branches, other -> {
				return other.matches(diagnosticsByUri.uri, diagnosticsByUri.project);
			});
			if (index == -1) {
				return null;
			}
			return [index];
		}
		var diagnostic = (item : MoonshineDiagnostic);
		var result:Array<Int> = [];
		for (i in 0...this._branches.length) {
			result.resize(1);
			result[0] = i;
			var diagnosticsByUri = this._branches[i];
			var collection = diagnosticsByUri.diagnostics;
			var index = collection.indexOf(diagnostic);
			if (index == -1) {
				return null;
			}
			return [i, index];
		}
		return null;
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
			if (this._branches.length == 0) {
				// nothing to remove
				return;
			}
			this._branches.resize(0);
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
		if (location == null || location.length == 0 || location.length > 2) {
			throw new RangeError('Item not found at location: ${location}');
		}
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.UPDATE_ITEM, location);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.updateAll`
	**/
	public function updateAll():Void {
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.UPDATE_ALL, null);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.refresh`
	**/
	public function refresh():Void {
		throw new IllegalOperationError("Not implemented");
	}

	public function clearDiagnostics(uri:String, project:ProjectVO):Void {
		var index = Lambda.findIndex(this._branches, other -> {
			return other.matches(uri, project);
		});
		if (index == -1) {
			return;
		}
		var removedDiagnosticsByUri = this._branches.splice(index, 1)[0];
		this.dispatchEvent(new HierarchicalCollectionEvent(HierarchicalCollectionEvent.REMOVE_ITEM, [index], null, removedDiagnosticsByUri));
		this.dispatchEvent(new Event(Event.CHANGE));
	}

	public function setDiagnostics(uri:String, project:ProjectVO, diagnostics:Array<MoonshineDiagnostic>):Void {
		diagnostics = diagnostics.filter(diagnostic -> {
			// hint diagnostics are for editor/IDE use, and they are not
			// displayed to the user
			return diagnostic.severity != Hint;
		});
		if (diagnostics.length == 0) {
			this.clearDiagnostics(uri, project);
			return;
		}
		var index = Lambda.findIndex(this._branches, other -> {
			return other.matches(uri, project);
		});
		var newDiagnosticsByUri = new DiagnosticsByUri(uri, project, diagnostics);
		if (index == -1) {
			this._branches.push(newDiagnosticsByUri);
			this.dispatchEvent(new HierarchicalCollectionEvent(HierarchicalCollectionEvent.ADD_ITEM, [this._branches.length - 1], newDiagnosticsByUri));
		} else {
			var oldDiagnosticsByUri = this._branches[index];
			this._branches[index] = newDiagnosticsByUri;
			this.dispatchEvent(new HierarchicalCollectionEvent(HierarchicalCollectionEvent.REPLACE_ITEM, [index], newDiagnosticsByUri, oldDiagnosticsByUri));
		}
		this.dispatchEvent(new Event(Event.CHANGE));
	}
}

class DiagnosticsByUri {
	public function new(uri:String, project:ProjectVO, diagnostics:Array<MoonshineDiagnostic>) {
		this.uri = uri;
		this.project = project;
		this.diagnostics = diagnostics;
	}

	public var uri:String;
	public var project:ProjectVO;
	public var diagnostics:Array<MoonshineDiagnostic>;

	public function matches(uri:String, project:ProjectVO):Bool {
		return this.uri == uri && this.project == project;
	}
}
