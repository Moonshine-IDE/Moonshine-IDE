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

package moonshine.plugin.locations.view;

import actionScripts.factory.FileLocation;
import actionScripts.valueObjects.Location;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.core.InvalidationFlag;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import feathers.utils.DisplayObjectRecycler;
import moonshine.theme.MoonshineTheme;
import moonshine.ui.ResizableTitleWindow;
import openfl.events.Event;
import openfl.events.MouseEvent;

class LocationsView extends ResizableTitleWindow {
	public function new() {
		MoonshineTheme.initializeTheme();

		super();
		this.title = "Go To Location";
		this.width = 600.0;
		this.minWidth = 300.0;
		this.minHeight = 300.0;
		this.closeEnabled = true;
		this.resizeEnabled = true;
	}

	private var resultsListView:ListView;
	private var openLocationButton:Button;

	private var _locations:ArrayCollection<Location> = new ArrayCollection();

	@:flash.property
	public var locations(get, set):ArrayCollection<Location>;

	private function get_locations():ArrayCollection<Location> {
		return this._locations;
	}

	private function set_locations(value:ArrayCollection<Location>):ArrayCollection<Location> {
		if (this._locations == value) {
			return this._locations;
		}
		this._locations = value;
		this._selectedLocation = null;
		this.setInvalid(InvalidationFlag.DATA);
		return this._locations;
	}

	private var _selectedLocation:Location;

	@:flash.property
	public var selectedLocation(get, never):Location;

	public function get_selectedLocation():Location {
		return this._selectedLocation;
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

		var resultsFieldLabel = new Label();
		resultsFieldLabel.text = "Matching locations:";
		this.addChild(resultsFieldLabel);

		this.resultsListView = new ListView();
		this.resultsListView.itemToText = (item:Location) -> {
			var start = item.range.start;
			var fileLocation:FileLocation = new FileLocation(item.uri, true);
			return fileLocation.name + " (" + start.line + ", " + start.character + ") - " + fileLocation.fileBridge.nativePath;
		};
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
		this.addChild(this.resultsListView);

		var footer = new LayoutGroup();
		footer.variant = MoonshineTheme.THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR;
		this.openLocationButton = new Button();
		this.openLocationButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.openLocationButton.enabled = false;
		this.openLocationButton.text = "Open Location";
		this.openLocationButton.addEventListener(TriggerEvent.TRIGGER, openLocationButton_triggerHandler);
		footer.addChild(this.openLocationButton);
		this.footer = footer;

		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			this.resultsListView.dataProvider = this._locations;
		}

		super.update();
	}

	private function resultsListView_changeHandler(event:Event):Void {
		this.openLocationButton.enabled = this.resultsListView.selectedItem != null;
	}

	private function openLocationButton_triggerHandler(event:TriggerEvent):Void {
		if (this.resultsListView.selectedItem == null) {
			// this shouldn't happen, but to be safe...
			// TODO: show an alert message to select an item
			return;
		}
		this._selectedLocation = cast(this.resultsListView.selectedItem, Location);
		this.dispatchEvent(new Event(Event.CLOSE));
	}

	private function itemRenderer_doubleClickHandler(event:MouseEvent):Void {
		this._selectedLocation = cast(this.resultsListView.selectedItem, Location);
		this.dispatchEvent(new Event(Event.CLOSE));
	}
}
