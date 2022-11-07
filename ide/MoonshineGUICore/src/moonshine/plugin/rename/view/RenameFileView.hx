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


package moonshine.plugin.rename.view;

import actionScripts.valueObjects.FileWrapper;
import feathers.controls.Button;
import feathers.controls.LayoutGroup;
import feathers.controls.TextInput;
import feathers.core.InvalidationFlag;
import feathers.events.TriggerEvent;
import feathers.layout.VerticalLayout;
import moonshine.theme.MoonshineTheme;
import moonshine.ui.ResizableTitleWindow;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

class RenameFileView extends ResizableTitleWindow {
	public function new() {
		super();
		this.width = 600.0;
		this.minWidth = 300.0;
		this.minHeight = 170.0;
		this.closeEnabled = true;
		this.resizeEnabled = true;
	}

	private var nameTextInput:TextInput;
	private var renameButton:Button;
	private var cancelButton:Button;

	private var _fileWrapper:FileWrapper;

	@:flash.property
	public var fileWrapper(get, set):FileWrapper;

	private function get_fileWrapper():FileWrapper {
		return this._fileWrapper;
	}

	private function set_fileWrapper(value:FileWrapper):FileWrapper {
		if (this._fileWrapper == value) {
			return this._fileWrapper;
		}
		this._fileWrapper = value;
		this._newName = null;
		this.setInvalid(InvalidationFlag.DATA);
		return this._fileWrapper;
	}

	private var _fileExtension:String = "";

	private var _newName:String;

	@:flash.property
	public var newName(get, never):String;

	private function get_newName():String {
		return this._newName;
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

		var symbolNameField = new LayoutGroup();
		var symbolNameFieldLayout = new VerticalLayout();
		symbolNameFieldLayout.horizontalAlign = JUSTIFY;
		symbolNameFieldLayout.gap = 10.0;
		symbolNameField.layout = symbolNameFieldLayout;
		this.addChild(symbolNameField);

		this.nameTextInput = new TextInput();
		this.nameTextInput.prompt = "New name";
		this.nameTextInput.restrict = "^ ";
		this.nameTextInput.addEventListener(Event.CHANGE, nameTextInput_changeHandler);
		this.nameTextInput.addEventListener(KeyboardEvent.KEY_DOWN, nameTextInput_keyDownHandler);
		symbolNameField.addChild(this.nameTextInput);

		var footer = new LayoutGroup();
		footer.variant = MoonshineTheme.THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR;
		this.renameButton = new Button();
		this.renameButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.renameButton.text = "Rename";
		this.renameButton.addEventListener(TriggerEvent.TRIGGER, renameButton_triggerHandler);
		footer.addChild(this.renameButton);
		this.cancelButton = new Button();
		this.cancelButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.cancelButton.text = "Cancel";
		this.cancelButton.addEventListener(TriggerEvent.TRIGGER, cancelButton_triggerHandler);
		footer.addChild(this.cancelButton);
		this.footer = footer;

		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			if (this._fileWrapper != null) {
				if (this._fileWrapper.file.fileBridge.isDirectory) {
					this.title = "Rename Package";
				} else {
					this.title = "Rename Class";
				}
				this._fileExtension = this._fileWrapper.file.fileBridge.extension;
				if (this._fileExtension != null) {
					this._fileExtension = this._fileExtension.toLowerCase();
				}
				this.nameTextInput.text = this._fileWrapper.file.fileBridge.nameWithoutExtension;
				this.nameTextInput.selectAll();
			}
		}

		super.update();
	}

	private function submit():Void {
		if (!this.renameButton.enabled) {
			return;
		}
		this._newName = this.nameTextInput.text;
		if (this._fileExtension != null) {
			this._newName += "." + this._fileExtension;
		}
		this.dispatchEvent(new Event(Event.CLOSE));
	}

	private function nameTextInput_changeHandler(event:Event):Void {
		var newName:String = this.nameTextInput.text;
		if (this._fileExtension != null) {
			newName += "." + this._fileExtension;
		}
		var targetFile = this._fileWrapper.file.fileBridge.parent.fileBridge.resolvePath(newName);
		targetFile.fileBridge.canonicalize();

		this.renameButton.enabled = newName.length > 0 && !targetFile.fileBridge.exists;
	}

	private function renameButton_triggerHandler(event:TriggerEvent):Void {
		this.submit();
	}

	private function cancelButton_triggerHandler(event:TriggerEvent):Void {
		this._newName = null;
		this.dispatchEvent(new Event(Event.CLOSE));
	}

	private function nameTextInput_keyDownHandler(event:KeyboardEvent):Void {
		switch (event.keyCode) {
			case Keyboard.ENTER:
				this.submit();
		}
	}
}
