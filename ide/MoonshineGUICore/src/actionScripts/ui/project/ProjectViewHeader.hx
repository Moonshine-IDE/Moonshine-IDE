////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2025. All rights reserved.
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

package actionScripts.ui.project;

import actionScripts.events.GlobalEventDispatcher;
import actionScripts.valueObjects.WorkspaceVO;
import feathers.controls.Button;
import feathers.controls.LayoutGroup;
import feathers.controls.PopUpListView;
import feathers.data.IFlatCollection;
import feathers.events.TriggerEvent;
import moonshine.plugin.workspace.events.WorkspaceEvent;
import openfl.events.Event;

@:meta(Event(name="scrollFromSource",type="flash.events.Event"))
@:meta(Event(name="close",type="flash.events.Event"))
@:styleContext
class ProjectViewHeader extends LayoutGroup {
	public static final CHILD_VARIANT_WORKSPACE_LIST_VIEW = "projectViewHeader--workspaceListView";
	public static final CHILD_VARIANT_SCROLL_FROM_SOURCE_BUTTON = "projectViewHeader--scrollFromSourceButton";
	public static final CHILD_VARIANT_CLOSE_BUTTON = "projectViewHeader--closeButton";

	public function new() {
		super();
	}

	private var workspaceListView:PopUpListView;
	private var scrollFromSourceButton:Button;
	private var closeButton:Button;

	private var _ignoreWorkspaceChange:Bool = false;

	private var _closeEnabled:Bool = true;

	@:flash.property
	public var closeEnabled(get, set):Bool;

	private function get_closeEnabled():Bool {
		return _closeEnabled;
	}

	private function set_closeEnabled(value:Bool):Bool {
		if (_closeEnabled == value) {
			return _closeEnabled;
		}
		_closeEnabled = value;
		setInvalid(DATA);
		return _closeEnabled;
	}

	private var _workspaces:IFlatCollection<WorkspaceVO>;

	@:flash.property
	public var workspaces(get, set):IFlatCollection<WorkspaceVO>;

	private function get_workspaces():IFlatCollection<WorkspaceVO> {
		return _workspaces;
	}

	private function set_workspaces(value:IFlatCollection<WorkspaceVO>):IFlatCollection<WorkspaceVO> {
		if (_workspaces == value) {
			return _workspaces;
		}
		_workspaces = value;
		setInvalid(DATA);
		return _workspaces;
	}

	private var _selectedWorkspace:WorkspaceVO;

	@:flash.property
	public var selectedWorkspace(get, set):WorkspaceVO;

	private function get_selectedWorkspace():WorkspaceVO {
		return _selectedWorkspace;
	}

	private function set_selectedWorkspace(value:WorkspaceVO):WorkspaceVO {
		if (_selectedWorkspace == value) {
			return _selectedWorkspace;
		}
		_selectedWorkspace = value;
		setInvalid(SELECTION);
		return _selectedWorkspace;
	}

	override private function initialize():Void {
		if (workspaceListView == null) {
			workspaceListView = new PopUpListView();
			workspaceListView.variant = CHILD_VARIANT_WORKSPACE_LIST_VIEW;
			workspaceListView.itemToText = (workspace:WorkspaceVO) -> {
				if (workspace == workspaceListView.selectedItem)
				{
					return "Workspace: " + workspace.label;
				}
				return workspace.label;
			}
			workspaceListView.addEventListener(Event.CHANGE, workspaceListView_changeHandler);
			addChild(workspaceListView);
		}
		if (scrollFromSourceButton == null) {
			scrollFromSourceButton = new Button();
			scrollFromSourceButton.variant = CHILD_VARIANT_SCROLL_FROM_SOURCE_BUTTON;
			scrollFromSourceButton.focusEnabled = false;
			scrollFromSourceButton.addEventListener(TriggerEvent.TRIGGER, scrollFromSourceButton_triggerHandler);
			addChild(scrollFromSourceButton);
		}
		if (closeButton == null) {
			closeButton = new Button();
			closeButton.variant = CHILD_VARIANT_CLOSE_BUTTON;
			closeButton.focusEnabled = false;
			closeButton.includeInLayout = false;
			closeButton.visible = false;
			closeButton.addEventListener(TriggerEvent.TRIGGER, closeButton_triggerHandler);
			addChild(closeButton);
		}
		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = isInvalid(DATA);
		var selectionInvalid = isInvalid(SELECTION);

		if (dataInvalid || selectionInvalid) {
			_ignoreWorkspaceChange = true;
			workspaceListView.dataProvider = _workspaces;
			workspaceListView.selectedItem = _selectedWorkspace;
			var index = workspaceListView.dataProvider.indexOf(_selectedWorkspace);
			if (index != -1) {
				workspaceListView.dataProvider.updateAt(index);
			}
			_ignoreWorkspaceChange = false;
			closeButton.visible = closeEnabled;
			closeButton.includeInLayout = closeEnabled;
		}

		super.update();
	}

	private function scrollFromSourceButton_triggerHandler(event:TriggerEvent):Void {
		dispatchEvent(new Event("scrollFromSource"));
	}

	private function closeButton_triggerHandler(event:TriggerEvent):Void {
		dispatchEvent(new Event(Event.CLOSE));
	}

	private function workspaceListView_changeHandler(event:Event):Void {
		if (_ignoreWorkspaceChange || workspaceListView.selectedItem == null) {
			return;
		}
		GlobalEventDispatcher.getInstance().dispatchEvent(
				new WorkspaceEvent(WorkspaceEvent.LOAD_WORKSPACE_WITH_LABEL, workspaceListView.selectedItem.label)
		);
	}
}