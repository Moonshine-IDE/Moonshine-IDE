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

import feathers.layout.VerticalLayoutData;
import feathers.layout.HorizontalLayout;
import moonshine.theme.MoonshineTheme;
import feathers.layout.HorizontalLayoutData;
import openfl.events.MouseEvent;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.utils.DisplayObjectRecycler;
import feathers.events.TriggerEvent;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.TextInput;
import feathers.core.InvalidationFlag;
import feathers.data.ArrayCollection;
import feathers.layout.VerticalLayout;
import moonshine.ui.ResizableTitleWindow;
import openfl.events.Event;

class SymbolsView extends ResizableTitleWindow {
	public static final EVENT_QUERY_CHANGE = "queryChange";
	public static final EVENT_OPEN_SELECTED_SYMBOL = "openSelectedSymbol";

	public function new() {
		MoonshineTheme.initializeTheme();

		super();
		this.width = 600.0;
		this.minWidth = 300.0;
		this.minHeight = 300.0;
		this.closeEnabled = true;
		// TODO: make resizable when infinite loop issue fixed in Feathers UI
		this.resizeEnabled = false;
	}

	private var searchFieldTextInput:TextInput;
	private var resultsListView:ListView;
	private var openSymbolButton:Button;

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
		this.setInvalid(InvalidationFlag.DATA);
		return this._symbols;
	}

	@:flash.property
	public var selectedSymbol(get, never):Dynamic;

	public function get_selectedSymbol():Dynamic {
		if (this.resultsListView == null) {
			return null;
		}
		return this.resultsListView.selectedItem;
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
		this.searchFieldTextInput.addEventListener(Event.CHANGE, searchFieldTextInput_changeHandler);
		searchField.addChild(this.searchFieldTextInput);

		var resultsField = new LayoutGroup();
		var resultsFieldLayout = new VerticalLayout();
		resultsFieldLayout.horizontalAlign = JUSTIFY;
		resultsFieldLayout.gap = 10.0;
		resultsField.layout = resultsFieldLayout;
		// TODO: uncomment when infinite loop issue fixed in Feathers UI
		// resultsField.layoutData = new VerticalLayoutData(null, 100.0);
		this.addChild(resultsField);

		var resultsFieldLabel = new Label();
		resultsFieldLabel.text = "Matching items:";
		resultsField.addChild(resultsFieldLabel);

		this.resultsListView = new ListView();
		this.resultsListView.itemToText = (item) -> item.name;
		this.resultsListView.itemRendererRecycler = DisplayObjectRecycler.withFunction(() -> {
			var itemRenderer = new ItemRenderer();
			itemRenderer.doubleClickEnabled = true;
			itemRenderer.addEventListener(MouseEvent.DOUBLE_CLICK, itemRenderer_doubleClickHandler);
			return itemRenderer;
		});
		// TODO: uncomment when infinite loop issue fixed in Feathers UI
		// this.resultsListView.layoutData = new VerticalLayoutData(null, 100.0);
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

	private function searchFieldTextInput_changeHandler(event:Event):Void {
		// use the setter so that the event is dispatched
		this.query = this.searchFieldTextInput.text;
	}

	private function resultsListView_changeHandler(event:Event):Void {
		this.openSymbolButton.enabled = this.resultsListView.selectedItem != null;
	}

	private function openSymbolButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(EVENT_OPEN_SELECTED_SYMBOL));
	}

	private function itemRenderer_doubleClickHandler(event:MouseEvent):Void {
		this.dispatchEvent(new Event(EVENT_OPEN_SELECTED_SYMBOL));
	}
}
