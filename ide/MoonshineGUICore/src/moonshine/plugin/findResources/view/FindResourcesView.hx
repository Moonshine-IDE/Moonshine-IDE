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

package moonshine.plugin.findResources.view;

import actionScripts.valueObjects.ResourceVO;
import feathers.controls.Button;
import feathers.controls.Callout;
import feathers.controls.Check;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.TextInput;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.core.InvalidationFlag;
import feathers.data.ArrayCollection;
import feathers.data.ListViewItemState;
import feathers.events.ListViewEvent;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import feathers.utils.DisplayObjectRecycler;
import moonshine.theme.MoonshineTheme;
import moonshine.ui.ResizableTitleWindow;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.ui.Keyboard;

class FindResourcesView extends ResizableTitleWindow {
	public function new() {
		MoonshineTheme.initializeTheme();

		super();
		this.title = "Find Resources";
		this.width = 600.0;
		this.minWidth = 300.0;
		this.minHeight = 300.0;
		this.closeEnabled = true;
		this.resizeEnabled = true;
	}

	private var searchFieldTextInput:TextInput;
	private var filterExtensionsButton:Button;
	private var resultsListView:ListView;
	private var openResourceButton:Button;

	private var _resources:ArrayCollection<ResourceVO> = new ArrayCollection();

	@:flash.property
	public var resources(get, set):ArrayCollection<ResourceVO>;

	private function get_resources():ArrayCollection<ResourceVO> {
		return this._resources;
	}

	private function set_resources(value:ArrayCollection<ResourceVO>):ArrayCollection<ResourceVO> {
		if (this._resources == value) {
			return this._resources;
		}
		this._resources = value;
		this._selectedResource = null;
		this.updateFilterFunction();
		this.setInvalid(InvalidationFlag.DATA);
		return this._resources;
	}

	private var _patterns:ArrayCollection<Dynamic> = new ArrayCollection();

	@:flash.property
	public var patterns(get, set):ArrayCollection<Dynamic>;

	private function get_patterns():ArrayCollection<Dynamic> {
		return this._patterns;
	}

	private function set_patterns(value:ArrayCollection<Dynamic>):ArrayCollection<Dynamic> {
		if (this._patterns == value) {
			return this._patterns;
		}
		this._patterns = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._patterns;
	}

	private var _selectedResource:ResourceVO;

	@:flash.property
	public var selectedResource(get, never):ResourceVO;

	public function get_selectedResource():ResourceVO {
		return this._selectedResource;
	}

	override private function initialize():Void {
		var viewLayout = new VerticalLayout();
		viewLayout.horizontalAlign = JUSTIFY;
		viewLayout.paddingTop = 10.0;
		viewLayout.paddingRight = 10.0;
		viewLayout.paddingBottom = 10.0;
		viewLayout.paddingLeft = 10.0;
		viewLayout.gap = 10.0;
		this.layout = viewLayout;

		var searchField = new LayoutGroup();
		var searchFieldLayout = new VerticalLayout();
		searchFieldLayout.horizontalAlign = JUSTIFY;
		searchFieldLayout.gap = 10.0;
		searchField.layout = searchFieldLayout;
		this.addChild(searchField);

		var searchFieldLabel = new Label();
		searchFieldLabel.text = "Search for resource by name:";
		searchField.addChild(searchFieldLabel);

		var searchFieldContent = new LayoutGroup();
		var searchFieldContentLayout = new HorizontalLayout();
		searchFieldContentLayout.gap = 10.0;
		searchFieldContent.layout = searchFieldContentLayout;
		searchField.addChild(searchFieldContent);

		this.searchFieldTextInput = new TextInput();
		this.searchFieldTextInput.prompt = "File name";
		this.searchFieldTextInput.addEventListener(Event.CHANGE, searchFieldTextInput_changeHandler);
		this.searchFieldTextInput.layoutData = new HorizontalLayoutData(100.0);
		searchFieldContent.addChild(this.searchFieldTextInput);

		this.filterExtensionsButton = new Button();
		this.filterExtensionsButton.text = "Extensions";
		this.filterExtensionsButton.addEventListener(TriggerEvent.TRIGGER, filterExtensionsButton_triggerHandler);
		searchFieldContent.addChild(this.filterExtensionsButton);

		var resultsField = new LayoutGroup();
		var resultsFieldLayout = new VerticalLayout();
		resultsFieldLayout.horizontalAlign = JUSTIFY;
		resultsFieldLayout.gap = 10.0;
		resultsField.layout = resultsFieldLayout;
		resultsField.layoutData = new VerticalLayoutData(null, 100.0);
		this.addChild(resultsField);

		var resultsFieldLabel = new Label();
		resultsFieldLabel.text = "Matching items:";
		resultsField.addChild(resultsFieldLabel);

		this.resultsListView = new ListView();
		this.resultsListView.itemToText = (item:ResourceVO) -> item.name + " - " + item.resourcePath;
		this.resultsListView.itemRendererRecycler = DisplayObjectRecycler.withFunction(() -> {
			var itemRenderer = new ItemRenderer();
			itemRenderer.doubleClickEnabled = true;
			// required for double-click too
			itemRenderer.mouseChildren = false;
			itemRenderer.addEventListener(MouseEvent.DOUBLE_CLICK, itemRenderer_doubleClickHandler);
			return itemRenderer;
		});
		this.resultsListView.layoutData = new VerticalLayoutData(null, 100.0);
		this.resultsListView.addEventListener(KeyboardEvent.KEY_DOWN, resultsListView_keyDownHandler);
		this.resultsListView.addEventListener(Event.CHANGE, resultsListView_changeHandler);
		resultsField.addChild(this.resultsListView);

		var footer = new LayoutGroup();
		footer.variant = MoonshineTheme.THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR;
		this.openResourceButton = new Button();
		this.openResourceButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.openResourceButton.enabled = false;
		this.openResourceButton.text = "Open Resource";
		this.openResourceButton.addEventListener(TriggerEvent.TRIGGER, openResourceButton_triggerHandler);
		footer.addChild(this.openResourceButton);
		this.footer = footer;

		super.initialize();

		this.updateFilterFunction();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			this.resultsListView.dataProvider = this._resources;
		}

		super.update();
	}

	private function updateFilterFunction():Void {
		if (this._resources == null) {
			return;
		}
		var query = this.searchFieldTextInput.text.toLowerCase();
		this._resources.filterFunction = function(item:ResourceVO):Bool {
			var itemName = item.name.toLowerCase();

			if (query.length > 0 && itemName.indexOf(query) == -1) {
				return false;
			}

			var isSelected = false;
			var someSelected = false;
			for (pattern in this._patterns) {
				if (pattern.isSelected) {
					someSelected = true;
				}
				if (pattern.label == item.resourceExtension && pattern.isSelected) {
					isSelected = true;
				}
			}

			if (!isSelected && someSelected) {
				return false;
			}

			return true;
		}
	}

	private function filterExtensionsButton_triggerHandler(event:TriggerEvent):Void {
		var content = new LayoutGroup();
		var contentLayout = new VerticalLayout();
		contentLayout.horizontalAlign = JUSTIFY;
		contentLayout.paddingTop = 10.0;
		contentLayout.paddingRight = 10.0;
		contentLayout.paddingBottom = 10.0;
		contentLayout.paddingLeft = 10.0;
		contentLayout.gap = 10.0;
		content.layout = contentLayout;
		var description = new Label();
		description.text = "Reduce selection to only files of type(s):";
		content.addChild(description);
		var extensionListView = new ListView();
		extensionListView.dataProvider = this._patterns;
		extensionListView.itemToText = (item:Dynamic) -> "*." + item.label;
		extensionListView.itemRendererRecycler = DisplayObjectRecycler.withFunction(() -> {
			var itemRenderer = new ItemRenderer();
			var check = new Check();
			check.mouseEnabled = false;
			itemRenderer.icon = check;
			return itemRenderer;
		}, (itemRenderer, state : ListViewItemState) -> {
				itemRenderer.text = state.text;
				var check = cast(itemRenderer.icon, Check);
				check.selected = state.data.isSelected;
			}, (itemRenderer, state:ListViewItemState) -> {
				itemRenderer.text = null;
				var check = cast(itemRenderer.icon, Check);
				check.selected = false;
			});
		extensionListView.addEventListener(ListViewEvent.ITEM_TRIGGER, extensionsListView_itemTriggerHandler);
		extensionListView.selectable = false;
		extensionListView.layoutData = new VerticalLayoutData(null, 100.0);
		content.addChild(extensionListView);
		Callout.show(content, this.filterExtensionsButton);
	}

	private function extensionsListView_itemTriggerHandler(event:ListViewEvent):Void {
		var index = event.state.index;
		var pattern = this._patterns.get(index);
		pattern.isSelected = !pattern.isSelected;
		this._patterns.updateAt(index);

		// filter the list
		this._resources.refresh();
	}

	private function searchFieldTextInput_changeHandler(event:Event):Void {
		this.updateFilterFunction();
	}

	private function resultsListView_keyDownHandler(event:KeyboardEvent):Void {
		if (event.keyCode != Keyboard.ENTER) {
			return;
		}
		if (!this.openResourceButton.enabled) {
			return;
		}
		this._selectedResource = cast(this.resultsListView.selectedItem, ResourceVO);
		this.dispatchEvent(new Event(Event.CLOSE));
	}

	private function resultsListView_changeHandler(event:Event):Void {
		this.openResourceButton.enabled = this.resultsListView.selectedItem != null;
	}

	private function openResourceButton_triggerHandler(event:TriggerEvent):Void {
		if (this.resultsListView.selectedItem == null) {
			// this shouldn't happen, but to be safe...
			// TODO: show an alert message to select an item
			return;
		}
		this._selectedResource = cast(this.resultsListView.selectedItem, ResourceVO);
		this.dispatchEvent(new Event(Event.CLOSE));
	}

	private function itemRenderer_doubleClickHandler(event:MouseEvent):Void {
		this._selectedResource = cast(this.resultsListView.selectedItem, ResourceVO);
		this.dispatchEvent(new Event(Event.CLOSE));
	}
}
