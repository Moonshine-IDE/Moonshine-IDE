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


package moonshine.plugin.references.view;

import actionScripts.factory.FileLocation;
import actionScripts.interfaces.IViewWithTitle;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.core.InvalidationFlag;
import feathers.data.ArrayCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import moonshine.lsp.Location;
import moonshine.theme.MoonshineTheme;
import openfl.events.Event;

class ReferencesView extends LayoutGroup implements IViewWithTitle {
	public static final EVENT_OPEN_SELECTED_REFERENCE = "openSelectedReference";

	public function new() {
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
