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

package moonshine.ui;

import moonshine.theme.MoonshineTheme;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.popups.DropDownPopUpAdapter;
import feathers.core.InvalidationFlag;
import feathers.data.IFlatCollection;
import feathers.events.ListViewEvent;
import feathers.events.TriggerEvent;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.MouseEvent;

@:styleContext
class SideBarViewHeader extends LayoutGroup {
	public static final CHILD_VARIANT_TITLE = "sideBarViewHeader--title";
	public static final CHILD_VARIANT_CLOSE_BUTTON = "sideBarViewHeader--closeButton";
	public static final CHILD_VARIANT_MENU_BUTTON = "sideBarViewHeader--menuButton";

	public function new() {
		super();
	}

	private var _title:String;

	@:flash.property
	public var title(get, set):String;

	private function get_title():String {
		return this._title;
	}

	private function set_title(value:String):String {
		if (this._title == value) {
			return this._title;
		}
		this._title = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._title;
	}

	private var _closeEnabled:Bool = false;

	@:flash.property
	public var closeEnabled(get, set):Bool;

	private function get_closeEnabled():Bool {
		return this._closeEnabled;
	}

	private function set_closeEnabled(value:Bool):Bool {
		if (this._closeEnabled == value) {
			return this._closeEnabled;
		}
		this._closeEnabled = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._closeEnabled;
	}

	private var _popUpAdapter:DropDownPopUpAdapter;

	private var _menuDataProvider:IFlatCollection<SideBarViewHeaderMenuItem>;

	@:flash.property
	public var menuDataProvider(get, set):IFlatCollection<SideBarViewHeaderMenuItem>;

	private function get_menuDataProvider():IFlatCollection<SideBarViewHeaderMenuItem> {
		return this._menuDataProvider;
	}

	private function set_menuDataProvider(value:IFlatCollection<SideBarViewHeaderMenuItem>):IFlatCollection<SideBarViewHeaderMenuItem> {
		if (this._menuDataProvider == value) {
			return this._menuDataProvider;
		}
		this._menuDataProvider = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._menuDataProvider;
	}

	private var titleLabel:Label;
	private var closeButton:Button;
	private var menuButton:Button;
	private var menuListView:ListView;

	override private function initialize():Void {
		if (this._popUpAdapter == null) {
			var popUpAdapter = new DropDownPopUpAdapter();
			popUpAdapter.addEventListener(Event.OPEN, event -> {
				this.stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDownHandler, false, 0, true);
			});
			popUpAdapter.addEventListener(Event.CLOSE, event -> {
				this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDownHandler);
			});
			this._popUpAdapter = popUpAdapter;
		}
		if (this.titleLabel == null) {
			this.titleLabel = new Label();
			this.titleLabel.variant = CHILD_VARIANT_TITLE;
			this.addChild(this.titleLabel);
		}
		if (this.menuButton == null) {
			this.menuButton = new Button();
			this.menuButton.variant = CHILD_VARIANT_MENU_BUTTON;
			this.menuButton.focusEnabled = false;
			this.menuButton.includeInLayout = false;
			this.menuButton.visible = false;
			this.menuButton.addEventListener(TriggerEvent.TRIGGER, menuButton_triggerHandler);
			this.addChild(this.menuButton);
		}
		if (this.closeButton == null) {
			this.closeButton = new Button();
			this.closeButton.variant = CHILD_VARIANT_CLOSE_BUTTON;
			this.closeButton.focusEnabled = false;
			this.closeButton.includeInLayout = false;
			this.closeButton.visible = false;
			this.closeButton.addEventListener(TriggerEvent.TRIGGER, closeButton_triggerHandler);
			this.addChild(this.closeButton);
		}
		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			this.updateTitle();
			this.updateMenuButton();
			this.updateMenuListView();
			this.updateCloseButton();
		}

		super.update();
	}

	private function updateTitle():Void {
		this.titleLabel.text = this._title;
	}

	private function updateMenuButton():Void {
		this.menuButton.enabled = this.enabled && this._menuDataProvider != null;
		this.menuButton.visible = this._menuDataProvider != null;
		this.menuButton.includeInLayout = this._menuDataProvider != null;
	}

	private function updateMenuListView():Void {
		if (this._menuDataProvider == null) {
			if (this.menuListView != null) {
				this.menuListView.removeEventListener(ListViewEvent.ITEM_TRIGGER, menuListView_triggerHandler);
				if (this.menuListView.parent != null) {
					this.menuListView.parent.removeChild(this.menuListView);
					this.menuListView = null;
				}
			}
			return;
		}
		if (this.menuListView == null) {
			this.menuListView = new ListView();
			this.menuListView.variant = MoonshineTheme.THEME_VARIANT_MENU_LIST_VIEW;
			this.menuListView.selectable = false;
			this.menuListView.itemToText = (item:SideBarViewHeaderMenuItem) -> item.title;
			this.menuListView.addEventListener(ListViewEvent.ITEM_TRIGGER, menuListView_triggerHandler);
		}
		this.menuListView.dataProvider = this._menuDataProvider;
	}

	private function updateCloseButton():Void {
		this.closeButton.enabled = this.enabled && this._closeEnabled;
		this.closeButton.visible = this._closeEnabled;
		this.closeButton.includeInLayout = this._closeEnabled;
	}

	private function closeButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.CLOSE));
	}

	private function menuButton_triggerHandler(event:TriggerEvent):Void {
		if (this._popUpAdapter.active) {
			this._popUpAdapter.close();
		} else {
			this._popUpAdapter.open(this.menuListView, this.menuButton);
		}
	}

	private function menuListView_triggerHandler(event:ListViewEvent):Void {
		this._popUpAdapter.close();
		var menuItem = cast(event.state.data, SideBarViewHeaderMenuItem);
		menuItem.callback(menuItem);
	}

	private function stage_mouseDownHandler(event:MouseEvent):Void {
		var mouseTarget = cast(event.target, DisplayObject);
		if (this.menuListView.contains(mouseTarget) || this.menuButton.contains(mouseTarget)) {
			return;
		}
		this._popUpAdapter.close();
	}
}

class SideBarViewHeaderMenuItem {
	public var title:String;
	public var callback:(SideBarViewHeaderMenuItem) -> Void;

	public function new(title:String, callback:(SideBarViewHeaderMenuItem) -> Void) {
		this.title = title;
		this.callback = callback;
	}
}
