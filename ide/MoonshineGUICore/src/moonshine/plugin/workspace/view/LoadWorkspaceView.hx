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

package moonshine.plugin.workspace.view;

import feathers.layout.AnchorLayoutData;
import feathers.controls.PopUpListView;
import feathers.layout.VerticalLayout;
import feathers.controls.Button;
import feathers.controls.LayoutGroup;
import moonshine.theme.MoonshineTheme;
import moonshine.ui.ResizableTitleWindow;
import feathers.data.ArrayCollection;
import feathers.core.InvalidationFlag;
import openfl.events.Event;
import feathers.events.TriggerEvent;
import moonshine.plugin.workspace.events.WorkspaceEvent;
import actionScripts.valueObjects.WorkspaceVO;
import actionScripts.events.GlobalEventDispatcher;

class LoadWorkspaceView extends ResizableTitleWindow {
	public function new() {
		super();
			
		this.title = "Load Workspace";
		this.width = 350.0;
		this.minWidth = 300.0;
		this.minHeight = 150.0;
		this.closeEnabled = true;
		this.resizeEnabled = true;
		
	}
	
	private var loadWorkspaceButton:Button;
	private var workspacePopUpListView:PopUpListView;
	
	private var _selectedWorkspace:WorkspaceVO;
	
	@:flash.property
	public var selectedWorkspace(get, set):WorkspaceVO;
	
	private function get_selectedWorkspace():WorkspaceVO {
		return this._selectedWorkspace;
	}

	private function set_selectedWorkspace(value:WorkspaceVO):WorkspaceVO {
		if (this._selectedWorkspace == value) {
			return this._selectedWorkspace;
		}
		
		this._selectedWorkspace = value;
		this.setInvalid(InvalidationFlag.SELECTION);
		return this._selectedWorkspace;
	}
	
	private var _workspaces:ArrayCollection<WorkspaceVO> = new ArrayCollection();
	
	@:flash.property
	public var workspaces(get, set):ArrayCollection<WorkspaceVO>;

	private function get_workspaces():ArrayCollection<WorkspaceVO> {
		return this._workspaces;
	}

	private function set_workspaces(value:ArrayCollection<WorkspaceVO>):ArrayCollection<WorkspaceVO> {
		if (this._workspaces == value) {
			return this._workspaces;
		}
		
		this._workspaces = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._workspaces;
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
		
		this.workspacePopUpListView = new PopUpListView();
		this.workspacePopUpListView.width = 300;
		this.workspacePopUpListView.layoutData = AnchorLayoutData.center();
		this.workspacePopUpListView.itemToText = function(item:WorkspaceVO):String {
													 return item.label;
  												  };
		this.addChild(this.workspacePopUpListView);		
		
		var footer = new LayoutGroup();
		footer.variant = MoonshineTheme.THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR;
		this.loadWorkspaceButton = new Button();
		this.loadWorkspaceButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.loadWorkspaceButton.text = "Load Workspace";
		this.loadWorkspaceButton.addEventListener(TriggerEvent.TRIGGER, loadWorkspaceButton_triggerHandler);
		footer.addChild(this.loadWorkspaceButton);
		this.footer = footer;
		
		super.initialize();
	}
	
	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid == true) {
			this._workspaces.sortCompareFunction = this.sortWorkspaces;
			this._workspaces.refresh();
			this.workspacePopUpListView.dataProvider = this._workspaces;
		}		
		
		var selectionInvalid = this.isInvalid(InvalidationFlag.SELECTION);
		if (selectionInvalid == true) {	
			this.workspacePopUpListView.selectedItem = this._selectedWorkspace;
		}		
		
		super.update();
	}
	
	private function loadWorkspaceButton_triggerHandler(event:Event):Void {
		var workspaceEvent = new WorkspaceEvent(WorkspaceEvent.LOAD_WORKSPACE_WITH_LABEL, this.workspacePopUpListView.selectedItem.label);
		GlobalEventDispatcher.getInstance().dispatchEvent(workspaceEvent);
		
		this.dispatchEvent(new Event(Event.CLOSE));
	}
	
	private function sortWorkspaces(a:WorkspaceVO, b:WorkspaceVO):Int {
		var labelA = a.label.toLowerCase();
		var labelB = b.label.toLowerCase();
	
		if (labelA < labelB) {
			return -1;
		}	 
		else if (labelA > labelB) {
			return 1; 
		}
		else {
			return 0;
		}
	}
}