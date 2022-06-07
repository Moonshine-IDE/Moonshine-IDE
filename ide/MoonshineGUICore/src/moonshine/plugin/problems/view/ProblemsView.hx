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

package moonshine.plugin.problems.view;

import openfl.events.Event;
import actionScripts.interfaces.IViewWithTitle;
import feathers.controls.LayoutGroup;
import feathers.controls.TreeView;
import feathers.controls.dataRenderers.HierarchicalItemRenderer;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.core.InvalidationFlag;
import feathers.data.TreeViewItemState;
import feathers.events.HierarchicalCollectionEvent;
import feathers.events.TreeViewEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.utils.DisplayObjectRecycler;
import moonshine.plugin.problems.data.DiagnosticHierarchicalCollection;
import moonshine.plugin.problems.events.ProblemsViewEvent;
import moonshine.plugin.problems.vo.MoonshineDiagnostic;

class ProblemsView extends LayoutGroup implements IViewWithTitle {
	public function new() {
		super();
		this.problems = new DiagnosticHierarchicalCollection();
	}

	private var treeView:TreeView;

	@:flash.property
	public var title(get, never):String;

	public function get_title():String {
		return "Problems";
	}

	private var _problems:DiagnosticHierarchicalCollection;

	@:flash.property
	public var problems(get, set):DiagnosticHierarchicalCollection;

	private function get_problems():DiagnosticHierarchicalCollection {
		return this._problems;
	}

	private function set_problems(value:DiagnosticHierarchicalCollection):DiagnosticHierarchicalCollection {
		if (this._problems == value) {
			return this._problems;
		}
		if (this._problems != null) {
			this._problems.removeEventListener(HierarchicalCollectionEvent.ADD_ITEM, problemsView_problems_addItemHandler);
			this._problems.removeEventListener(HierarchicalCollectionEvent.REPLACE_ITEM, problemsView_problems_replaceItemHandler);
			this._problems.removeEventListener(Event.CHANGE, problemsView_problems_changeHandler);
		}
		this._problems = value;
		if (this._problems != null) {
			this._problems.addEventListener(HierarchicalCollectionEvent.ADD_ITEM, problemsView_problems_addItemHandler, false, 0, true);
			this._problems.addEventListener(HierarchicalCollectionEvent.REPLACE_ITEM, problemsView_problems_replaceItemHandler, false, 0, true);
			this._problems.addEventListener(Event.CHANGE, problemsView_problems_changeHandler, false, 0, true);
		}
		this.setInvalid(InvalidationFlag.DATA);
		return this._problems;
	}

	private var _pendingSelectedLocation:Array<Int>;

	@:flash.property
	public var selectedProblem(get, never):MoonshineDiagnostic;

	public function get_selectedProblem():MoonshineDiagnostic {
		if (this.treeView == null) {
			return null;
		}
		var selectedItem = this.treeView.selectedItem;
		if ((selectedItem is MoonshineDiagnostic)) {
			return (selectedItem : MoonshineDiagnostic);
		}
		return null;
	}

	override private function initialize():Void {
		this.layout = new AnchorLayout();

		this.treeView = new TreeView();
		this.treeView.variant = TreeView.VARIANT_BORDERLESS;
		this.treeView.layoutData = AnchorLayoutData.fill();
		this.treeView.itemToText = item -> {
			if ((item is MoonshineDiagnostic)) {
				var diagnostic = cast(item, MoonshineDiagnostic);
				return this.getMessageLabel(diagnostic, false);
			} else if ((item is DiagnosticsByUri)) {
				var diagnosticsByUri = cast(item, DiagnosticsByUri);
				return this.getLocationLabel(diagnosticsByUri, false);
			}
			return Std.string(item);
		}
		this.treeView.itemRendererRecycler = DisplayObjectRecycler.withClass(ProblemItemRenderer);
		this.treeView.addEventListener(TreeViewEvent.ITEM_TRIGGER, problemsView_treeView_itemTriggerHandler);
		this.treeView.name = "diagnostics";
		this.addChild(this.treeView);

		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			this.treeView.dataProvider = this._problems;
		}

		super.update();
	}

	private function getMessageLabel(diagnostic:MoonshineDiagnostic, useHTML:Bool):String {
		var result = diagnostic.message;
		var hasCode = diagnostic.code != null && diagnostic.code.length > 0;
		var range = diagnostic.range;
		var start = range.start;
		var hasRangeStart = start != null;
		if (hasCode || hasRangeStart) {
			result += " ";
			if (useHTML) {
				result += "<font size='-2' color='#AFAFAF'>";
			}
			if (hasCode) {
				result += "(" + diagnostic.code + ")";
			}
			if (hasRangeStart) {
				result += " [Ln " + (start.line + 1) + ", Col " + (start.character + 1) + "]";
			}
			if (useHTML) {
				result += "</font>";
			}
		}
		return result;
	}

	private function getLocationLabel(diagnosticsByUri:DiagnosticsByUri, useHTML:Bool):String {
		var uri = diagnosticsByUri.uri;
		var index = uri.lastIndexOf("/");
		var fileName = uri.substr(index + 1);
		var result = fileName;
		if (diagnosticsByUri.project != null) {
			result += " ";
			if (useHTML) {
				result += "<font size='-2' color='#AFAFAF'>";
			}
			result += diagnosticsByUri.project.name;
			if (useHTML) {
				result += "</font>";
			}
		}
		return result;
	}

	private function problemsView_treeView_itemTriggerHandler(event:TreeViewEvent):Void {
		var item = event.state.data;
		if ((item is MoonshineDiagnostic)) {
			this.dispatchEvent(new ProblemsViewEvent(ProblemsViewEvent.OPEN_PROBLEM, cast(item, MoonshineDiagnostic)));
		} else if (treeView.dataProvider.isBranch(item)) {
			var isOpen = treeView.isBranchOpen(item);
			this.treeView.toggleBranch(item, !isOpen);
		}
	}

	private function problemsView_problems_addItemHandler(event:HierarchicalCollectionEvent):Void {
		this.treeView.toggleBranch(event.addedItem, true);
	}

	private function problemsView_problems_replaceItemHandler(event:HierarchicalCollectionEvent):Void {
		this.treeView.toggleBranch(event.addedItem, true);
		if (!this.locationContains(event.location, this.treeView.selectedLocation)) {
			return;
		}
		var branchLength = this._problems.getLength(event.location);
		var newSelectedLocation = this.treeView.selectedLocation.copy();
		var lastIndex = newSelectedLocation[newSelectedLocation.length - 1];
		if (lastIndex >= branchLength) {
			newSelectedLocation[newSelectedLocation.length - 1] = branchLength - 1;
		}
		this._pendingSelectedLocation = newSelectedLocation;
	}

	private function problemsView_problems_changeHandler(event:Event):Void {
		if (this._pendingSelectedLocation != null) {
			this.treeView.selectedLocation = this._pendingSelectedLocation;
			this._pendingSelectedLocation = null;
		}
	}

	private function locationContains(parent:Array<Int>, possibleChild:Array<Int>):Bool {
		if (parent == null || possibleChild == null || parent.length > possibleChild.length) {
			return false;
		}
		for (i in 0...parent.length) {
			if (parent[i] != possibleChild[i]) {
				return false;
			}
		}
		return true;
	}
}
