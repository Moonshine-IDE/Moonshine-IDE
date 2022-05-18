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

package moonshine.plugin.lsmonitor.view;

import moonshine.plugin.lsmonitor.vo.LanguageServerInstanceVO;
import feathers.events.GridViewEvent;
import moonshine.plugin.problems.vo.MoonshineDiagnostic;
import actionScripts.factory.FileLocation;
import actionScripts.interfaces.IViewWithTitle;
import feathers.controls.GridView;
import feathers.controls.GridViewColumn;
import feathers.controls.LayoutGroup;
import feathers.controls.TreeView;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.core.InvalidationFlag;
import feathers.data.ArrayCollection;
import feathers.data.GridViewCellState;
import feathers.data.IFlatCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.utils.DisplayObjectRecycler;
import openfl.events.Event;

class LanguageServersMonitorView extends LayoutGroup implements IViewWithTitle 
{
	public function new() 
	{
		super();
	}

	private var gridView:GridView;

	@:flash.property
	public var title(get, never):String;

	public function get_title():String {
		return "Language Servers";
	}

	private var _languageServerInstances:IFlatCollection<LanguageServerInstanceVO>;

	@:flash.property
	public var languageServerInstances(get, set):IFlatCollection<LanguageServerInstanceVO>;

	private function get_languageServerInstances():IFlatCollection<LanguageServerInstanceVO> 
	{
		return this._languageServerInstances;
	}

	private function set_languageServerInstances(value:IFlatCollection<LanguageServerInstanceVO>):IFlatCollection<LanguageServerInstanceVO> 
	{
		if (this._languageServerInstances == value) {
			return this._languageServerInstances;
		}
		this._languageServerInstances = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._languageServerInstances;
	}

	@:flash.property
	public var selectedInstance(get, never):LanguageServerInstanceVO;

	public function get_selectedInstance():LanguageServerInstanceVO 
	{
		if (this.gridView == null) {
			return null;
		}
		return cast(this.gridView.selectedItem, LanguageServerInstanceVO);
	}

	override private function initialize():Void 
	{
		this.layout = new AnchorLayout();

		this.gridView = new GridView();
		this.gridView.variant = TreeView.VARIANT_BORDERLESS;
		this.gridView.layoutData = AnchorLayoutData.fill();
		this.gridView.columns = new ArrayCollection([
			new GridViewColumn("Project", (data:LanguageServerInstanceVO) -> data.projectName),
			new GridViewColumn("Process ID", (data:LanguageServerInstanceVO) -> data.processID, 200)/*,
			new GridViewColumn("Memory", (data:LanguageServerInstanceVO) -> data.memory, 150),
			new GridViewColumn("CPU", (data:LanguageServerInstanceVO) -> data.cpu, 150)*/
		]);
		this.gridView.extendedScrollBarY = true;
		this.gridView.resizableColumns = true;
		//this.gridView.addEventListener(GridViewEvent.CELL_TRIGGER, gridView_cellTriggerHandler);
		this.addChild(this.gridView);

		super.initialize();
	}

	override private function update():Void 
	{
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		if (dataInvalid) 
		{
			this.gridView.dataProvider = this._languageServerInstances;
		}

		super.update();
	}

	private function gridView_cellTriggerHandler(event:GridViewEvent<GridViewCellState>):Void 
	{
		//this.dispatchEvent(new LanguageServersMonitorViewEvent(LanguageServersMonitorViewEvent.OPEN_PROBLEM, cast(event.state.data, MoonshineDiagnostic)));
	}
}
