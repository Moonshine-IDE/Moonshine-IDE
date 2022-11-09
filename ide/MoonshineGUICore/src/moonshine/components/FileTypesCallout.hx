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

import feathers.layout.VerticalLayoutData;
import feathers.data.ListViewItemState;
import feathers.controls.Check;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.controls.Label;
import feathers.utils.DisplayObjectRecycler;
import feathers.core.InvalidationFlag;
import feathers.layout.VerticalLayout;
import feathers.data.ArrayCollection;
import feathers.controls.LayoutGroup;
import moonshine.components.events.FileTypesCalloutEvent;
import feathers.controls.ListView;
import feathers.events.ListViewEvent;
import feathers.data.ArrayCollection;
import feathers.data.ListViewItemState;

class FileTypesCallout extends LayoutGroup 
{
	public function new()
	{
		super();
	}
	
	private var extensionListView:ListView;
	
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
	
	override private function initialize():Void { 
		super.initialize();
		
		var contentLayout = new VerticalLayout();
		contentLayout.horizontalAlign = JUSTIFY;
		contentLayout.paddingTop = 10.0;
		contentLayout.paddingRight = 10.0;
		contentLayout.paddingBottom = 10.0;
		contentLayout.paddingLeft = 10.0;
		contentLayout.gap = 10.0;
		this.layout = contentLayout;
		var description = new Label();
		description.text = "Reduce selection to only files of type(s):";
		this.addChild(description);
		extensionListView = new ListView();
		extensionListView.itemToText = (item:Dynamic) -> "*." + item.label;
		extensionListView.itemRendererRecycler = DisplayObjectRecycler.withFunction(() -> {
			var itemRenderer = new ItemRenderer();
			var check = new Check();
			check.focusEnabled = false;
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
		
		this.addChild(extensionListView);
	}
	
	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			extensionListView.dataProvider = this._patterns;
		}

		super.update();
	}
	
	private function extensionsListView_itemTriggerHandler(event:ListViewEvent):Void {
		this.dispatchEvent(new FileTypesCalloutEvent(FileTypesCalloutEvent.SELECT_FILETYPE, event.state.index));
	}
}