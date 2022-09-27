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


package moonshine.components;

import actionScripts.factory.FileLocation;
import actionScripts.utils.SDKUtils;
import actionScripts.valueObjects.SDKReferenceVO;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.TextInput;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalLayout;
import moonshine.theme.MoonshineTheme;
import moonshine.ui.ResizableTitleWindow;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.ui.Keyboard;

class SDKDefineView extends ResizableTitleWindow {
	public function new() {
		super();
		this.title = "Define an SDK Path";
		this.width = 600.0;
		this.minWidth = 300.0;
		this.minHeight = 260.0;
		this.closeEnabled = true;
		this.resizeEnabled = true;
	}

	private var sdkNameLabel:Label;
	private var sdkNameTextInput:TextInput;
	private var sdkPathLabel:Label;
	private var sdkPathTextInput:TextInput;
	private var sdkPathBrowseButton:Button;
	private var defineSDKButton:Button;
	private var cancelButton:Button;
	private var sandboxWarningGroup:LayoutGroup;
	private var isUserNameInput:Bool;

	private var _sdk:SDKReferenceVO;

	@:flash.property
	public var sdk(get, set):SDKReferenceVO;

	private function get_sdk():SDKReferenceVO {
		return this._sdk;
	}

	private function set_sdk(value:SDKReferenceVO):SDKReferenceVO {
		if (this._sdk == value) {
			return this._sdk;
		}
		this._sdk = value;
		this.setInvalid(DATA);
		return this._sdk;
	}

	private var _showSandboxWarning:Bool;

	@:flash.property
	public var showSandboxWarning(get, set):Bool;

	private function get_showSandboxWarning():Bool {
		return this._showSandboxWarning;
	}

	private function set_showSandboxWarning(value:Bool):Bool {
		if (this._showSandboxWarning == value) {
			return this._showSandboxWarning;
		}
		this._showSandboxWarning = value;
		this.setInvalid(DATA);
		return this._showSandboxWarning;
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

		var sdkPathField = new LayoutGroup();
		var sdkPathFieldLayout = new VerticalLayout();
		sdkPathFieldLayout.horizontalAlign = JUSTIFY;
		sdkPathFieldLayout.gap = 10.0;
		sdkPathField.layout = sdkPathFieldLayout;
		this.addChild(sdkPathField);

		this.sdkPathLabel = new Label();
		this.sdkPathLabel.text = "Path";
		sdkPathField.addChild(this.sdkPathLabel);

		var sdkPathInputGroup = new LayoutGroup();
		var sdkPathInputGroupLayout = new HorizontalLayout();
		sdkPathInputGroupLayout.gap = 10.0;
		sdkPathInputGroup.layout = sdkPathInputGroupLayout;
		this.addChild(sdkPathInputGroup);

		this.sdkPathTextInput = new TextInput();
		this.sdkPathTextInput.editable = false;
		this.sdkPathTextInput.addEventListener(MouseEvent.CLICK, sdkPathTextInput_clickHandler);
		this.sdkPathTextInput.addEventListener(Event.CHANGE, sdkPathTextInput_changeHandler);
		this.sdkPathTextInput.addEventListener(KeyboardEvent.KEY_DOWN, sdkPathTextInput_keyDownHandler);
		this.sdkPathTextInput.layoutData = new HorizontalLayoutData(100.0);
		sdkPathInputGroup.addChild(this.sdkPathTextInput);
		
		var sdkNameField = new LayoutGroup();
		var sdkNameFieldLayout = new VerticalLayout();
		sdkNameFieldLayout.horizontalAlign = JUSTIFY;
		sdkNameFieldLayout.gap = 10.0;
		sdkNameField.layout = sdkNameFieldLayout;
		this.addChild(sdkNameField);

		this.sdkNameLabel = new Label();
		this.sdkNameLabel.text = "Label";
		sdkNameField.addChild(this.sdkNameLabel);

		this.sdkNameTextInput = new TextInput();
		//this.sdkNameTextInput.editable = false;
		this.sdkNameTextInput.addEventListener(Event.CHANGE, sdkNameTextInput_changeHandler);
		this.sdkNameTextInput.addEventListener(KeyboardEvent.KEY_DOWN, sdkNameTextInput_keyDownHandler);
		sdkNameField.addChild(this.sdkNameTextInput);

		this.sdkPathBrowseButton = new Button();
		this.sdkPathBrowseButton.text = "Browse";
		this.sdkPathBrowseButton.addEventListener(TriggerEvent.TRIGGER, sdkPathBrowseButton_triggerHandler);
		sdkPathInputGroup.addChild(this.sdkPathBrowseButton);

		this.sandboxWarningGroup = new LayoutGroup();
		this.sandboxWarningGroup.variant = MoonshineTheme.THEME_VARIANT_WARNING_BAR;
		this.addChild(this.sandboxWarningGroup);
		var sandboxWarningLabel = new Label();
		sandboxWarningLabel.text = "Because of restrictions with the Apple Sandbox, you will only be able to use external SDKs if they are installed within your Downloads directory.";
		sandboxWarningLabel.wordWrap = true;
		sandboxWarningLabel.layoutData = new HorizontalLayoutData(100.0);
		this.sandboxWarningGroup.addChild(sandboxWarningLabel);

		var footer = new LayoutGroup();
		footer.variant = MoonshineTheme.THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR;
		this.defineSDKButton = new Button();
		this.defineSDKButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.defineSDKButton.text = (this._sdk == null) ? "Create" : "Update";
		this.defineSDKButton.addEventListener(TriggerEvent.TRIGGER, defineSDKButton_triggerHandler);
		footer.addChild(this.defineSDKButton);
		this.cancelButton = new Button();
		this.cancelButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.cancelButton.text = "Cancel";
		this.cancelButton.addEventListener(TriggerEvent.TRIGGER, cancelButton_triggerHandler);
		footer.addChild(this.cancelButton);
		this.footer = footer;

		super.initialize();
	}

	override private function update():Void {
		if (this._sdk != null) {
			if (!this.isUserNameInput) 
				this.sdkNameTextInput.text = this._sdk.name;
			this.sdkPathTextInput.text = this._sdk.path;
			this.sdkPathTextInput.toolTip = this._sdk.path;
		}
		this.sandboxWarningGroup.visible = this._showSandboxWarning;
		this.sandboxWarningGroup.includeInLayout = this._showSandboxWarning;
		super.update();
	}

	private function submit():Void {
		if (!this.defineSDKButton.enabled) {
			return;
		}
		if (this._sdk != null) 
			this._sdk.nameUncalculated = this.sdkNameTextInput.text;
		this.dispatchEvent(new Event(Event.CLOSE));
	}

	private function browseForSDK():Void {
		var sdkPath:String = null;
		if (this._sdk != null) {
			sdkPath = this._sdk.path;
		}

		var fileLocation:FileLocation = new FileLocation(sdkPath);
		fileLocation.fileBridge.browseForDirectory("Select directory", onSDKPathBrowseSelect, null, sdkPath);
	}

	private function onSDKPathBrowseSelect(dir:Dynamic):Void {
		var fileLocation:FileLocation = new FileLocation(dir.nativePath);
		this.sdk = SDKUtils.getSDKReference(fileLocation);

		if (this._sdk == null) {
			this.sdkNameTextInput.text = "Not a valid SDK directory.";
		}
	}

	private function refreshSubmitEnabled():Void {
		this.defineSDKButton.enabled = StringTools.trim(this.sdkNameTextInput.text).length > 0 && this.sdkPathTextInput.text.length > 0;
	}

	private function sdkNameTextInput_changeHandler(event:Event):Void {
		this.refreshSubmitEnabled();
	}

	private function sdkPathTextInput_changeHandler(event:Event):Void {
		this.refreshSubmitEnabled();
	}

	private function defineSDKButton_triggerHandler(event:TriggerEvent):Void {
		this.submit();
	}

	private function cancelButton_triggerHandler(event:TriggerEvent):Void {
		this._sdk = null;
		this.dispatchEvent(new Event(Event.CLOSE));
	}

	private function sdkNameTextInput_keyDownHandler(event:KeyboardEvent):Void {
		switch (event.keyCode) {
			case Keyboard.ENTER:
				this.submit();
			default:
				this.isUserNameInput = StringTools.trim(this.sdkNameTextInput.text).length > 0;
		}
	}

	private function sdkPathTextInput_keyDownHandler(event:KeyboardEvent):Void {
		switch (event.keyCode) {
			case Keyboard.ENTER:
				this.submit();
		}
	}

	private function sdkPathTextInput_clickHandler(event:MouseEvent):Void {
		this.browseForSDK();
	}

	private function sdkPathBrowseButton_triggerHandler(event:TriggerEvent):Void {
		this.browseForSDK();
	}
}
