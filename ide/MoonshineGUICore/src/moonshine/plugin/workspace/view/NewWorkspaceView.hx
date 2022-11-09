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

package moonshine.plugin.workspace.view;

import feathers.layout.HorizontalLayout;
import feathers.controls.Label;
import openfl.utils.Assets;
import flash.display.Bitmap;
import feathers.controls.Button;
import feathers.controls.LayoutGroup;
import feathers.controls.PopUpListView;
import feathers.controls.TextInput;
import feathers.core.InvalidationFlag;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayoutData;
import feathers.layout.VerticalLayout;
import moonshine.plugin.workspace.events.WorkspaceEvent;
import moonshine.theme.MoonshineTheme;
import moonshine.ui.ResizableTitleWindow;
import openfl.events.Event;
import feathers.layout.AnchorLayoutData;
import feathers.controls.LayoutGroup;
import moonshine.ui.ResizableTitleWindow;
import openfl.events.Event;
import actionScripts.valueObjects.WorkspaceVO;
import feathers.events.TriggerEvent;
import moonshine.theme.assets.ExclamationRedIcon;

class NewWorkspaceView extends ResizableTitleWindow {

	public function new() {
		super();
			
		this.title = "New Workspace";
		this.minHeight = 150.0;
		this.minWidth = 300.0;
		this.closeEnabled = true;
		this.resizeEnabled = true;
	}
	
	private var newWorkspaceButton:Button;
	private var workspaceNameTextInput:TextInput;
	private var errorContainer:LayoutGroup;
	
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
		
		this.workspaceNameTextInput = new TextInput();
		this.workspaceNameTextInput.prompt = "Workspace name";
		this.workspaceNameTextInput.addEventListener(Event.CHANGE, workspaceNameTextInput_changeHandler);
		this.addChild(this.workspaceNameTextInput);
		
		this.errorContainer = new LayoutGroup();
		this.errorContainer.layout = new HorizontalLayout();
		this.errorContainer.visible = this.errorContainer.includeInLayout = false;
		this.addChild(errorContainer);
		
		this.errorContainer.addChild(new Bitmap(new ExclamationRedIcon(0, 0)));
		
		var errorLabel:Label = new Label();
			errorLabel.text = "Workspace is already exists.";
		this.errorContainer.addChild(errorLabel);
		
		var footer = new LayoutGroup();
		footer.variant = MoonshineTheme.THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR;
		this.newWorkspaceButton = new Button();
		this.newWorkspaceButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.newWorkspaceButton.text = "Create";
		this.newWorkspaceButton.addEventListener(TriggerEvent.TRIGGER, newWorkspaceButton_triggerHandler);
		footer.addChild(this.newWorkspaceButton);
		this.footer = footer;
		
		super.initialize();
	}
	
	private function workspaceNameTextInput_changeHandler(event:Event):Void {
		this.errorContainer.visible = this.errorContainer.includeInLayout = false;			
	}	
	
	private function newWorkspaceButton_triggerHandler(event:Event):Void {
		var workspaceName = StringTools.trim(this.workspaceNameTextInput.text);
		
		if (workspaceName == null || workspaceName.length == 0) {
			return;
		}
		
		var hasWorkspace = this._workspaces.some(
				function hasWorkspace(workspace:WorkspaceVO, index:Int, arr:ArrayCollection<WorkspaceVO>):Bool {
										return workspace.label == workspaceName;
						  			});
		if (hasWorkspace) {
			this.errorContainer.visible = this.errorContainer.includeInLayout = true;	
			return;
		}
		
		var workspaceEvent = new WorkspaceEvent(WorkspaceEvent.NEW_WORKSPACE_WITH_LABEL, workspaceName);
		this.dispatchEvent(workspaceEvent);
		
		this.dispatchEvent(new Event(Event.CLOSE));
	}
}