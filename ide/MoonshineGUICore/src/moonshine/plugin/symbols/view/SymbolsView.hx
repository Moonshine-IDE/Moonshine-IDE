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

package moonshine.plugin.symbols.view;

import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.TextInput;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.core.InvalidationFlag;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import feathers.utils.DisplayObjectRecycler;
import moonshine.theme.MoonshineTheme;
import moonshine.ui.ResizableTitleWindow;
import openfl.Lib;
import openfl.events.Event;
import openfl.events.MouseEvent;

class SymbolsView extends ResizableTitleWindow {
	public static final EVENT_QUERY_CHANGE = "queryChange";

	public function new() {
		MoonshineTheme.initializeTheme();

		super();
		this.width = 600.0;
		this.minWidth = 300.0;
		this.minHeight = 300.0;
		this.closeEnabled = true;
		this.resizeEnabled = true;

		this.addEventListener(Event.REMOVED_FROM_STAGE, symbolsView_removedFromStageHandler);
	}

	private var searchFieldTextInput:TextInput;
	private var resultsListView:ListView;
	private var openSymbolButton:Button;
	private var queryChangeTimeoutID:Int = -1;

	private var _query:String = "";

	@:flash.property
	public var query(get, set):String;

	private function get_query():String {
		return this._query;
	}

	private function set_query(value:String):String {
		if (this._query == value) {
			return this._query;
		}
		if (this.queryChangeTimeoutID != -1) {
			Lib.clearTimeout(queryChangeTimeoutID);
			this.queryChangeTimeoutID = -1;
		}
		this._query = value;
		this.setInvalid(InvalidationFlag.DATA);
		this.dispatchEvent(new Event(EVENT_QUERY_CHANGE));
		return this._query;
	}

	private var _symbols:ArrayCollection<Dynamic> = new ArrayCollection();

	@:flash.property
	public var symbols(get, set):ArrayCollection<Dynamic>;

	private function get_symbols():ArrayCollection<Dynamic> {
		return this._symbols;
	}

	private function set_symbols(value:ArrayCollection<Dynamic>):ArrayCollection<Dynamic> {
		if (this._symbols == value) {
			return this._symbols;
		}
		this._symbols = value;
		this._selectedSymbol = null;
		this.setInvalid(InvalidationFlag.DATA);
		return this._symbols;
	}

	private var _selectedSymbol:Dynamic;

	@:flash.property
	public var selectedSymbol(get, never):Dynamic;

	public function get_selectedSymbol():Dynamic {
		return this._selectedSymbol;
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
		searchFieldLabel.text = "Search for symbol by name:";
		searchField.addChild(searchFieldLabel);

		this.searchFieldTextInput = new TextInput();
		this.searchFieldTextInput.prompt = "Symbol name";
		this.searchFieldTextInput.addEventListener(Event.CHANGE, searchFieldTextInput_changeHandler);
		searchField.addChild(this.searchFieldTextInput);

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
		this.resultsListView.itemToText = (item) -> item.name;
		this.resultsListView.itemRendererRecycler = DisplayObjectRecycler.withFunction(() -> {
			var itemRenderer = new ItemRenderer();
			itemRenderer.doubleClickEnabled = true;
			// required for double-click too
			itemRenderer.mouseChildren = false;
			itemRenderer.addEventListener(MouseEvent.DOUBLE_CLICK, itemRenderer_doubleClickHandler);
			return itemRenderer;
		});
		this.resultsListView.layoutData = new VerticalLayoutData(null, 100.0);
		this.resultsListView.addEventListener(Event.CHANGE, resultsListView_changeHandler);
		resultsField.addChild(this.resultsListView);

		var footer = new LayoutGroup();
		footer.variant = MoonshineTheme.THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR;
		this.openSymbolButton = new Button();
		this.openSymbolButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.openSymbolButton.enabled = false;
		this.openSymbolButton.text = "Open Symbol";
		this.openSymbolButton.addEventListener(TriggerEvent.TRIGGER, openSymbolButton_triggerHandler);
		footer.addChild(this.openSymbolButton);
		this.footer = footer;

		super.initialize();
	}

	override private function update():Void {
		this.searchFieldTextInput.text = this._query;
		this.resultsListView.dataProvider = this._symbols;

		super.update();
	}

	private function startOrResetQueryChangeTimer():Void {
		if (this.queryChangeTimeoutID != -1) {
			// we want to "debounce" this event, so reset the timer
			Lib.clearTimeout(queryChangeTimeoutID);
			this.queryChangeTimeoutID = -1;
		}
		this.queryChangeTimeoutID = Lib.setTimeout(() -> {
			this.dispatchEvent(new Event(EVENT_QUERY_CHANGE));
		}, 150);
	}

	private function symbolsView_removedFromStageHandler(event:Event):Void {
		if (this.queryChangeTimeoutID != -1) {
			Lib.clearTimeout(queryChangeTimeoutID);
			this.queryChangeTimeoutID = -1;
		}
	}

	private function searchFieldTextInput_changeHandler(event:Event):Void {
		// set the variable so that the event isn't dispatched right away
		this._query = this.searchFieldTextInput.text;
		this.startOrResetQueryChangeTimer();
	}

	private function resultsListView_changeHandler(event:Event):Void {
		this.openSymbolButton.enabled = this.resultsListView.selectedItem != null;
	}

	private function openSymbolButton_triggerHandler(event:TriggerEvent):Void {
		if (this.resultsListView.selectedItem == null) {
			// this shouldn't happen, but to be safe...
			// TODO: show an alert message to select an item
			return;
		}
		this._selectedSymbol = this.resultsListView.selectedItem;
		this.dispatchEvent(new Event(Event.CLOSE));
	}

	private function itemRenderer_doubleClickHandler(event:MouseEvent):Void {
		this._selectedSymbol = this.resultsListView.selectedItem;
		this.dispatchEvent(new Event(Event.CLOSE));
	}
}
