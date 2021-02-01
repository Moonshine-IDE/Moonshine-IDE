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

package moonshine.components;

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
		MoonshineTheme.initializeTheme();

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
