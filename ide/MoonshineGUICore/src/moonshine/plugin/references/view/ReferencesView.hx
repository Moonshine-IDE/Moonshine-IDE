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

package moonshine.plugin.references.view;

import actionScripts.factory.FileLocation;
import actionScripts.interfaces.IViewWithTitle;
import actionScripts.valueObjects.Location;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.core.InvalidationFlag;
import feathers.data.ArrayCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import moonshine.theme.MoonshineTheme;
import openfl.events.Event;

class ReferencesView extends LayoutGroup implements IViewWithTitle {
	public static final EVENT_OPEN_SELECTED_REFERENCE = "openSelectedReference";

	public function new() {
		MoonshineTheme.initializeTheme();

		super();
	}

	private var resultsListView:ListView;

	@:flash.property
	public var title(get, never):String;

	public function get_title():String {
		return "References";
	}

	private var _references:ArrayCollection<Location> = new ArrayCollection();

	@:flash.property
	public var references(get, set):ArrayCollection<Location>;

	private function get_references():ArrayCollection<Location> {
		return this._references;
	}

	private function set_references(value:ArrayCollection<Location>):ArrayCollection<Location> {
		if (this._references == value) {
			return this._references;
		}
		this._references = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._references;
	}

	@:flash.property
	public var selectedReference(get, never):Location;

	public function get_selectedReference():Location {
		if (this.resultsListView == null) {
			return null;
		}
		return cast(this.resultsListView.selectedItem, Location);
	}

	override private function initialize():Void {
		this.layout = new AnchorLayout();

		this.resultsListView = new ListView();
		this.resultsListView.variant = ListView.VARIANT_BORDERLESS;
		this.resultsListView.itemToText = (item:Location) -> {
			var start = item.range.start;
			var fileLocation:FileLocation = new FileLocation(item.uri, true);
			return fileLocation.name + " (" + start.line + ", " + start.character + ") - " + fileLocation.fileBridge.nativePath;
		}
		this.resultsListView.layoutData = AnchorLayoutData.fill();
		this.resultsListView.addEventListener(Event.CHANGE, resultsListView_changeHandler);
		this.addChild(this.resultsListView);

		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			this.resultsListView.dataProvider = this._references;
		}

		super.update();
	}

	private function resultsListView_changeHandler(event:Event):Void {
		if (this.resultsListView.selectedItem == null) {
			return;
		}
		this.dispatchEvent(new Event(EVENT_OPEN_SELECTED_REFERENCE));
	}
}
