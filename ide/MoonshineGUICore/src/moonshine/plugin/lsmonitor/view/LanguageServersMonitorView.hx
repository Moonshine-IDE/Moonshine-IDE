/**

Copyright (C) 2016-present Prominic.NET, Inc.
 
This program is free software: you can redistribute it and/or modify
it under the terms of the Server Side Public License, version 1,
as published by MongoDB, Inc.
 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
Server Side Public License for more details.

You should have received a copy of the Server Side Public License
along with this program. If not, see
http://www.mongodb.com/licensing/server-side-public-license.

As a special exception, the copyright holders give permission to link the
code of portions of this program with the OpenSSL library under certain
conditions as described in each individual source file and distribute
linked combinations including the program with the OpenSSL library. You
must comply with the Server Side Public License in all respects for
all of the code used other than as permitted herein. If you modify file(s)
with this exception, you may extend this exception to your version of the
file(s), but you are not obligated to do so. If you do not wish to do so,
delete this exception statement from your version. If you delete this
exception statement from all source files in the program, then also delete
it in the license file.

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
		this.gridView.sortableColumns = true;
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
