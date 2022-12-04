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
import actionScripts.events.GlobalEventDispatcher;

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
	private var hasWorkspace:Bool;
	
	private var _isSaveAs:Bool;
	@:flash.property
	public var isSaveAs(get, set):Bool;
	private function get_isSaveAs():Bool {
		return this._isSaveAs;
	}
	private function set_isSaveAs(value:Bool):Bool {
		this._isSaveAs = value;
		return this._isSaveAs;
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

	private var _workspace:WorkspaceVO;
	@:flash.property
	public var workspace(get, set):WorkspaceVO;

	private function get_workspace():WorkspaceVO {
		return this._workspace;
	}

	private function set_workspace(value:WorkspaceVO):WorkspaceVO {
		if (this._workspace == value) {
			return this._workspace;
		}
		
		this._workspace = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._workspace;
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
			errorLabel.text = "Workspace already exists.";
		this.errorContainer.addChild(errorLabel);
		
		var footer = new LayoutGroup();
		footer.variant = MoonshineTheme.THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR;
		this.newWorkspaceButton = new Button();
		this.newWorkspaceButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.newWorkspaceButton.text = (this.workspace == null) ? "Create" : "Rename";
		this.newWorkspaceButton.addEventListener(TriggerEvent.TRIGGER, newWorkspaceButton_triggerHandler);
		footer.addChild(this.newWorkspaceButton);
		this.footer = footer;
		
		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			if (this.workspace != null)
			{
				this.workspaceNameTextInput.text = this.workspace.label;
			}
		}	
		
		super.update();
	}
	
	private function workspaceNameTextInput_changeHandler(event:Event):Void 
	{
		this.hasWorkspace = this._workspaces.some(
			function(workspace:WorkspaceVO, index:Int, arr:ArrayCollection<WorkspaceVO>):Bool {
									return workspace.label == StringTools.trim(this.workspaceNameTextInput.text);
								  });
		this.errorContainer.visible = this.errorContainer.includeInLayout = this.hasWorkspace;
	}	
	
	private function newWorkspaceButton_triggerHandler(event:Event):Void {
		var workspaceName = StringTools.trim(this.workspaceNameTextInput.text);
		if (workspaceName == null || workspaceName.length == 0 || this.hasWorkspace) {
			return;
		}
		
		var workspaceEvent:WorkspaceEvent = null;
		if (this.isSaveAs)
		{
			// save-as 
			workspaceEvent = new WorkspaceEvent(WorkspaceEvent.SAVE_AS_WORKSPACE_WITH_LABEL, workspaceName);
		}
		else if (this.workspace != null)
		{
			// rename with workspace object
			workspaceEvent = new WorkspaceEvent(WorkspaceEvent.RENAME_WORKSPACE, this.workspace.label); // will help to identify the old label
			this.workspace.label = workspaceName;
			workspaceEvent.workspace = this.workspace;
		}
		else
		{
			// addition
			workspaceEvent = new WorkspaceEvent(WorkspaceEvent.NEW_WORKSPACE_WITH_LABEL, workspaceName);	
		}
		GlobalEventDispatcher.getInstance().dispatchEvent(workspaceEvent);
		
		this.dispatchEvent(new Event(Event.CLOSE));
	}
}