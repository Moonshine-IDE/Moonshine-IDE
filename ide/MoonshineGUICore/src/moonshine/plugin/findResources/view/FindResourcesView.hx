////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
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


package moonshine.plugin.findResources.view;

import moonshine.components.events.FileTypesCalloutEvent;
import openfl.text.TextFormatAlign;
import openfl.text.TextFormat;
import feathers.core.IUIControl;
import feathers.layout.AnchorLayoutData;
import feathers.layout.AnchorLayout;
import openfl.utils.Object;
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
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import feathers.utils.DisplayObjectRecycler;
import moonshine.theme.MoonshineTheme;
import moonshine.ui.ResizableTitleWindow;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import actionScripts.valueObjects.ResourceVO;
import moonshine.components.FileTypesCallout;

class FindResourcesView extends ResizableTitleWindow {
	public function new() {
		super();
		this.title = "Find Resources";
		this.width = 600.0;
		this.minWidth = 300.0;
		this.minHeight = 300.0;
		this.closeEnabled = true;
		this.resizeEnabled = true;
		
		this.addEventListener(Event.ADDED_TO_STAGE, findResourcesView_addedToStageHandler);
	}

	private var searchFieldTextInput:TextInput;
	private var filterExtensionsButton:Button;
	private var resultsListView:ListView;
	private var openResourceButton:Button;
	private var resultsFieldLabel:Label;

	private var _resources:ArrayCollection<Dynamic> = new ArrayCollection();

	@:flash.property
	public var resources(get, set):ArrayCollection<Dynamic>;

	private function get_resources():ArrayCollection<Dynamic> {
		return this._resources;
	}

	private function set_resources(value:ArrayCollection<Dynamic>):ArrayCollection<Dynamic> {
		if (this._resources == value) {
			return this._resources;
		}
		this._resources = value;
		this._selectedResource = null;
		this.updateFilterFunction();
		this.setInvalid(InvalidationFlag.DATA);
		return this._resources;
	}
	
	private var _isBusyState:Bool = true;
	
	@:flash.property
	public var isBusyState(get, set):Bool;

	private function get_isBusyState():Bool {
		return this._isBusyState;
	}

	private function set_isBusyState(value:Bool):Bool {
		_isBusyState = value;
		if (!value)
		{
			this.updateFilesCount();
		}		
		return this._isBusyState;
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

	private var _selectedResource:Dynamic;

	@:flash.property
	public var selectedResource(get, never):Dynamic;

	public function get_selectedResource():Dynamic {
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
		this.searchFieldTextInput.addEventListener(KeyboardEvent.KEY_DOWN, searchFieldTextInput_keyDownHandler, false, 10);
		
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
		
		resultsFieldLabel = new Label();
		resultsFieldLabel.text = "(Total: Working...)";
		resultsFieldLabel.layoutData = new HorizontalLayoutData(50, null);
		resultsFieldLabel.textFormat = new TextFormat("DejaVuSansTF", 12, 0x812137);
		resultsField.addChild(resultsFieldLabel);
		
		var resultsListViewContainer = new LayoutGroup();
		resultsListViewContainer.layoutData = new VerticalLayoutData(null, 100.0);
		resultsListViewContainer.layout = new AnchorLayout();
		resultsField.addChild(resultsListViewContainer);
		
		var resultsListViewLayoutData = new AnchorLayoutData();
		resultsListViewLayoutData.top = 0;
		resultsListViewLayoutData.bottom = 0;
		resultsListViewLayoutData.left = 0;
		resultsListViewLayoutData.right = 0;

		this.resultsListView = new ListView();
		this.resultsListView.itemToText = (item:Dynamic) -> item.name + " - " + item.labelPath;
		this.resultsListView.itemRendererRecycler = DisplayObjectRecycler.withFunction(() -> {
		var itemRenderer = new ItemRenderer();
			itemRenderer.doubleClickEnabled = true;
			// required for double-click too
			itemRenderer.mouseChildren = false;
			itemRenderer.addEventListener(MouseEvent.DOUBLE_CLICK, itemRenderer_doubleClickHandler);
			return itemRenderer;
		});
		this.resultsListView.layoutData = resultsListViewLayoutData;
		this.resultsListView.addEventListener(Event.CHANGE, resultsListView_changeHandler);
				
		resultsListViewContainer.addChild(this.resultsListView);

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
		this._resources.filterFunction = function(item:Dynamic):Bool {
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
				if (pattern.label == item.extension && pattern.isSelected) {
					isSelected = true;
				}
			}

			if (!isSelected && someSelected) {
				return false;
			}

			return true;
		}
		
		if (!this.isBusyState) 
			this.updateFilesCount();
	}
	
	private function updateFilesCount():Void
	{
		if (this._resources != null)
		{
			this.resultsFieldLabel.text = "(Total: "+ this._resources.length +" files)";
		}
	}
	
	private function findResourcesView_addedToStageHandler(event:Event):Void
	{
		this.removeEventListener(Event.ADDED_TO_STAGE, findResourcesView_addedToStageHandler);	
		this.stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);	
	}	
		
	private function stage_keyDownHandler(event:KeyboardEvent):Void {
		if (event.keyCode == Keyboard.ENTER && this.resultsListView.selectedItem != null) 
		{	
			this._selectedResource = this.resultsListView.selectedItem;
			this.dispatchEvent(new Event(Event.CLOSE));	
		}
	}	
	
	private function filterExtensionsButton_triggerHandler(event:TriggerEvent):Void {
		var fileTypesCallout = new FileTypesCallout(); 
			fileTypesCallout.patterns = this._patterns;
			fileTypesCallout.addEventListener(FileTypesCalloutEvent.SELECT_FILETYPE, extensionsListView_itemTriggerHandler);
		Callout.show(fileTypesCallout, this.filterExtensionsButton);
	}

	private function extensionsListView_itemTriggerHandler(event:FileTypesCalloutEvent):Void {
		var index = event.index;
		var pattern = this._patterns.get(index);
		pattern.isSelected = !pattern.isSelected;
		this._patterns.updateAt(index);

		// filter the list
		this._resources.refresh();
	}

	private function searchFieldTextInput_changeHandler(event:Event):Void {
		this.updateFilterFunction();
	}
	
	private function searchFieldTextInput_keyDownHandler(event:KeyboardEvent) {
		if (event.isDefaultPrevented()) {
			return;
		}
		
		var isKeyDown = event.keyCode == Keyboard.DOWN;
		var isKeyUp = event.keyCode == Keyboard.UP;
	
		if(isKeyDown || isKeyUp) {
			event.preventDefault();
			
			var focusedComponent = this.focusManager.focus;
			
			if (this.resultsListView != focusedComponent) {
				event.preventDefault();
				
				var resourceSelectedIndex = this.resultsListView.selectedIndex;
				
				if (isKeyDown) {
					if (resourceSelectedIndex < resources.length - 1)
					{
						resourceSelectedIndex = this.resultsListView.selectedIndex = resourceSelectedIndex + 1;
					}
					else if (resources.length > 0)
					{
						resourceSelectedIndex = this.resultsListView.selectedIndex = 0;
					}
				} else if (isKeyUp) {
					resourceSelectedIndex = this.resultsListView.selectedIndex - 1;
					if (resourceSelectedIndex == -1 && resources.length > 0)
					{
						resourceSelectedIndex = this.resultsListView.selectedIndex = resources.length - 1;
					}					
					else if (resourceSelectedIndex > -1)
					{
						resourceSelectedIndex = this.resultsListView.selectedIndex = resourceSelectedIndex;
					}
				}
				
				this.resultsListView.scrollToIndex(resourceSelectedIndex);
			}
		}
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
		this._selectedResource = this.resultsListView.selectedItem;
		this.dispatchEvent(new Event(Event.CLOSE));
	}
	
	private function itemRenderer_doubleClickHandler(event:MouseEvent):Void {
		this._selectedResource = this.resultsListView.selectedItem;
		this.dispatchEvent(new Event(Event.CLOSE));
	}
}
