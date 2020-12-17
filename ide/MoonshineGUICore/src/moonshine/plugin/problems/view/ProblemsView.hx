/*
	Copyright 2020 Prominic.NET, Inc.

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

import feathers.data.GridViewCellState;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.utils.DisplayObjectRecycler;
import actionScripts.factory.FileLocation;
import actionScripts.interfaces.IViewWithTitle;
import actionScripts.valueObjects.Diagnostic;
import feathers.controls.GridView;
import feathers.controls.GridViewColumn;
import feathers.controls.LayoutGroup;
import feathers.controls.TreeView;
import feathers.core.InvalidationFlag;
import feathers.data.ArrayCollection;
import feathers.data.IFlatCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import moonshine.theme.MoonshineTheme;
import openfl.events.Event;

class ProblemsView extends LayoutGroup implements IViewWithTitle {
	public function new() {
		MoonshineTheme.initializeTheme();

		super();
	}

	private var gridView:GridView;

	@:flash.property
	public var title(get, never):String;

	public function get_title():String {
		return "Problems";
	}

	private var _problems:IFlatCollection<Diagnostic> = new ArrayCollection<Diagnostic>();

	@:flash.property
	public var problems(get, set):IFlatCollection<Diagnostic>;

	private function get_problems():IFlatCollection<Diagnostic> {
		return this._problems;
	}

	private function set_problems(value:IFlatCollection<Diagnostic>):IFlatCollection<Diagnostic> {
		if (this._problems == value) {
			return this._problems;
		}
		this._problems = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._problems;
	}

	@:flash.property
	public var selectedProblem(get, never):Diagnostic;

	public function get_selectedProblem():Dynamic {
		if (this.gridView == null) {
			return null;
		}
		return cast(this.gridView.selectedItem, Diagnostic);
	}

	override private function initialize():Void {
		this.layout = new AnchorLayout();

		this.gridView = new GridView();
		this.gridView.variant = TreeView.VARIANT_BORDERLESS;
		this.gridView.layoutData = AnchorLayoutData.fill();
		var problemColumn = new GridViewColumn("Problem", getMessageLabel);
		problemColumn.cellRendererRecycler = DisplayObjectRecycler.withClass(ItemRenderer, (target, state:GridViewCellState) -> {
			target.text = state.text;
			target.toolTip = state.text;
		});
		var locationColumn = new GridViewColumn("Location", getLocationLabel);
		locationColumn.cellRendererRecycler = DisplayObjectRecycler.withClass(ItemRenderer, (target, state:GridViewCellState) -> {
			target.text = state.text;
			target.toolTip = cast(state.data, Diagnostic).path;
		});
		this.gridView.columns = new ArrayCollection([problemColumn, locationColumn]);
		this.gridView.extendedScrollBarY = true;
		this.gridView.addEventListener(Event.CHANGE, gridView_changeHandler);
		this.addChild(this.gridView);

		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			this.gridView.dataProvider = this._problems;
		}

		super.update();
	}

	private function getMessageLabel(diagnostic:Diagnostic):String {
		var label = diagnostic.message;
		if (diagnostic.code != null && diagnostic.code.length > 0) {
			label += " (" + diagnostic.code + ")";
		}
		return label;
	}

	private function getLocationLabel(diagnostic:Diagnostic):String {
		var label = new FileLocation(diagnostic.path).name;
		var range = diagnostic.range;
		var start = range.start;
		if (start != null) {
			label += " (" + (start.line + 1) + ", " + (start.character + 1) + ")";
		}
		return label;
	}

	private function gridView_changeHandler(event:Event):Void {
		this.dispatchEvent(new Event(Event.CHANGE));
	}
}
