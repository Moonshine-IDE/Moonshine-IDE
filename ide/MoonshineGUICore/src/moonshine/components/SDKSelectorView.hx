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


package moonshine.components;

import moonshine.haxeScripts.utils.StringSorter;
import openfl.events.MouseEvent;
import actionScripts.valueObjects.SDKReferenceVO;
import actionScripts.utils.SDKUtils;
import feathers.controls.Button;
import feathers.controls.GridView;
import feathers.controls.GridViewColumn;
import feathers.controls.LayoutGroup;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.core.PopUpManager;
import feathers.data.ArrayCollection;
import feathers.data.GridViewCellState;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalLayoutData;
import feathers.utils.DisplayObjectRecycler;
import moonshine.theme.MoonshineTheme;
import moonshine.ui.ResizableTitleWindow;
import openfl.events.Event;


class SDKSelectorView extends ResizableTitleWindow {
	private static final EVENT_SDK_ADD:String = "sdkAdd";
	private static final EVENT_SDK_REMOVE:String = "sdkRemove";
	private static final EVENT_SDK_EDIT:String = "sdkEdit";

	public function new() {
		super();
		this.title = "Select SDK";
		this.width = 600.0;
		this.minWidth = 300.0;
		this.minHeight = 200.0;
		this.closeEnabled = true;
		this.resizeEnabled = true;
	}

	private var addButton:Button;
	private var removeButton:Button;
	private var editButton:Button;
	private var selectButton:Button;
	private var sdkGrid:GridView;
	private var addOrEditSDKPopUp:SDKDefineView;

	private var _sdks:ArrayCollection<SDKReferenceVO>;

	@:flash.property
	public var sdks(get, set):ArrayCollection<SDKReferenceVO>;

	private function get_sdks():ArrayCollection<SDKReferenceVO> {
		return this._sdks;
	}

	private function set_sdks(value:ArrayCollection<SDKReferenceVO>):ArrayCollection<SDKReferenceVO> {
		if (this._sdks == value) {
			return this._sdks;
		}
		this._sdks = value;
		this._sdks.sortCompareFunction = (new StringSorter("name")).sortCompareFunction;
		this._sdks.refresh();
		this.setInvalid(DATA);
		return this._sdks;
	}

	private var _selectedSDK:SDKReferenceVO;

	@:flash.property
	public var selectedSDK(get, never):SDKReferenceVO;

	private function get_selectedSDK():SDKReferenceVO {
		return this._selectedSDK;
	}

	override private function initialize():Void {
		this.layout = new AnchorLayout();

		this.sdkGrid = new GridView();
		this.sdkGrid.resizableColumns = true;
		var descriptionColumn = new GridViewColumn("Description", (sdk:SDKReferenceVO) -> sdk.name);
		descriptionColumn.cellRendererRecycler = DisplayObjectRecycler.withClass(ItemRenderer, (target, state:GridViewCellState) -> {
			target.text = state.text;
			target.toolTip = state.text;
			target.doubleClickEnabled = true;
			target.mouseChildren = false;
			target.addEventListener(MouseEvent.DOUBLE_CLICK, this.sdkGrid_doubleClickHandler);
		}, (target, state:GridViewCellState) -> {
			target.removeEventListener(MouseEvent.DOUBLE_CLICK, this.sdkGrid_doubleClickHandler);
		});
		var pathColumn = new GridViewColumn("Path", (sdk:SDKReferenceVO) -> sdk.path);
		pathColumn.cellRendererRecycler = DisplayObjectRecycler.withClass(ItemRenderer, (target, state:GridViewCellState) -> {
			target.text = state.text;
			target.toolTip = state.text;
			target.doubleClickEnabled = true;
			target.mouseChildren = false;
			target.addEventListener(MouseEvent.DOUBLE_CLICK, this.sdkGrid_doubleClickHandler);
		}, (target, state:GridViewCellState) -> {
			target.removeEventListener(MouseEvent.DOUBLE_CLICK, this.sdkGrid_doubleClickHandler);
		});
		var statusColumn = new GridViewColumn("", (sdk:SDKReferenceVO) -> sdk.status);
		statusColumn.width = 60.0;
		statusColumn.cellRendererRecycler = DisplayObjectRecycler.withClass(ItemRenderer, (target, state:GridViewCellState) -> {
			target.text = state.text;
			target.toolTip = state.text;
			target.doubleClickEnabled = true;
			target.mouseChildren = false;
			target.addEventListener(MouseEvent.DOUBLE_CLICK, this.sdkGrid_doubleClickHandler);
		}, (target, state:GridViewCellState) -> {
			target.removeEventListener(MouseEvent.DOUBLE_CLICK, this.sdkGrid_doubleClickHandler);
		});
		this.sdkGrid.columns = new ArrayCollection([descriptionColumn, pathColumn, statusColumn]);
		this.sdkGrid.layoutData = AnchorLayoutData.fill();
		this.sdkGrid.addEventListener(Event.CHANGE, sdkGrid_changeHandler);
		this.addChild(this.sdkGrid);

		var footer = new LayoutGroup();
		footer.variant = MoonshineTheme.THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR;
		this.addButton = new Button();
		this.addButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.addButton.text = "Add";
		this.addButton.addEventListener(TriggerEvent.TRIGGER, addButton_triggerHandler);
		footer.addChild(this.addButton);
		this.removeButton = new Button();
		this.removeButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.removeButton.text = "Remove";
		this.removeButton.enabled = false;
		this.removeButton.addEventListener(TriggerEvent.TRIGGER, removeButton_triggerHandler);
		footer.addChild(this.removeButton);
		this.editButton = new Button();
		this.editButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.editButton.text = "Edit";
		this.editButton.enabled = false;
		this.editButton.addEventListener(TriggerEvent.TRIGGER, editButton_triggerHandler);
		footer.addChild(this.editButton);
		var spacer = new LayoutGroup();
		spacer.layoutData = new HorizontalLayoutData(100.0);
		footer.addChild(spacer);
		this.selectButton = new Button();
		this.selectButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.selectButton.text = "Select";
		this.selectButton.enabled = false;
		this.selectButton.addEventListener(TriggerEvent.TRIGGER, selectButton_triggerHandler);
		footer.addChild(this.selectButton);
		this.footer = footer;

		super.initialize();
	}

	override private function update():Void {
		this.sdkGrid.dataProvider = this._sdks;

		super.update();
	}

	private function submit():Void {
		if (!this.selectButton.enabled) {
			return;
		}
		this._selectedSDK = cast(this.sdkGrid.selectedItem, SDKReferenceVO);
		this.dispatchEvent(new Event(Event.CLOSE));
	}

	private function sdkGrid_changeHandler(event:Event):Void {
		this.removeButton.enabled = (this.sdkGrid.selectedItem != null) && (cast(this.sdkGrid.selectedItem, SDKReferenceVO).status != SDKUtils.BUNDLED);
		this.editButton.enabled = (this.sdkGrid.selectedItem != null) && (cast(this.sdkGrid.selectedItem, SDKReferenceVO).status != SDKUtils.BUNDLED);
		this.selectButton.enabled = this.sdkGrid.selectedItem != null;
	}
	
	private function sdkGrid_doubleClickHandler(event:MouseEvent):Void
	{
		if (cast(this.sdkGrid.selectedItem, SDKReferenceVO).status != SDKUtils.BUNDLED) 
			this.editButton_triggerHandler(null);
	}

	private function addButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(EVENT_SDK_ADD));
	}

	private function removeButton_triggerHandler(event:TriggerEvent):Void {
		this._selectedSDK = cast(this.sdkGrid.selectedItem, SDKReferenceVO);
		this.dispatchEvent(new Event(EVENT_SDK_REMOVE));
		this._selectedSDK = null;
	}

	private function editButton_triggerHandler(event:TriggerEvent):Void {
		this._selectedSDK = cast(this.sdkGrid.selectedItem, SDKReferenceVO);
		this.dispatchEvent(new Event(EVENT_SDK_EDIT));
		this._selectedSDK = null;
	}

	private function selectButton_triggerHandler(event:TriggerEvent):Void {
		this.submit();
	}

	private function addOrEditSDKPopUp_closeHandler(event:Event):Void {
		PopUpManager.removePopUp(this.addOrEditSDKPopUp);
	}
}
