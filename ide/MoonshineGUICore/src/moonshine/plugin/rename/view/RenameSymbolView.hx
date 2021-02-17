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

package moonshine.plugin.rename.view;

import feathers.controls.Button;
import feathers.controls.Label;
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

class RenameSymbolView extends ResizableTitleWindow {
	public function new() {
		MoonshineTheme.initializeTheme();

		super();
		this.title = "Rename Symbol";
		this.width = 600.0;
		this.minWidth = 300.0;
		this.minHeight = 170.0;
		this.closeEnabled = true;
		this.resizeEnabled = true;
	}

	private var symbolNameFieldLabel:Label;
	private var symbolNameTextInput:TextInput;
	private var renameButton:Button;
	private var cancelButton:Button;

	private var _existingSymbolNameChanged = false;

	private var _existingSymbolName:String;

	@:flash.property
	public var existingSymbolName(get, set):String;

	private function get_existingSymbolName():String {
		return this._existingSymbolName;
	}

	private function set_existingSymbolName(value:String):String {
		if (this._existingSymbolName == value) {
			return this._existingSymbolName;
		}
		this._existingSymbolName = value;
		this._newSymbolName = null;
		this._existingSymbolNameChanged = true;
		this.setInvalid(InvalidationFlag.DATA);
		return this._existingSymbolName;
	}

	private var _newSymbolName:String;

	@:flash.property
	public var newSymbolName(get, never):String;

	private function get_newSymbolName():String {
		return this._newSymbolName;
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

		this.symbolNameFieldLabel = new Label();
		// setting text in update() because it depends on the old symbol name
		symbolNameField.addChild(this.symbolNameFieldLabel);

		this.symbolNameTextInput = new TextInput();
		this.symbolNameTextInput.prompt = "New symbol name";
		this.symbolNameTextInput.restrict = "^ ";
		this.symbolNameTextInput.addEventListener(Event.CHANGE, symbolNameTextInput_changeHandler);
		this.symbolNameTextInput.addEventListener(KeyboardEvent.KEY_DOWN, symbolNameTextInput_keyDownHandler);
		symbolNameField.addChild(this.symbolNameTextInput);

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
		if (this._existingSymbolNameChanged) {
			this._existingSymbolNameChanged = false;
			this.symbolNameTextInput.text = this._existingSymbolName;
			this.symbolNameTextInput.selectAll();
			this.symbolNameFieldLabel.text = 'Rename symbol \'${this._existingSymbolName}\' and its usages to:';
		}

		super.update();
	}

	private function submit():Void {
		if (!this.renameButton.enabled) {
			return;
		}
		this._newSymbolName = this.symbolNameTextInput.text;
		this.dispatchEvent(new Event(Event.CLOSE));
	}

	private function symbolNameTextInput_changeHandler(event:Event):Void {
		this.renameButton.enabled = this.symbolNameTextInput.text.length > 0;
	}

	private function renameButton_triggerHandler(event:TriggerEvent):Void {
		this.submit();
	}

	private function cancelButton_triggerHandler(event:TriggerEvent):Void {
		this._newSymbolName = null;
		this.dispatchEvent(new Event(Event.CLOSE));
	}

	private function symbolNameTextInput_keyDownHandler(event:KeyboardEvent):Void {
		switch (event.keyCode) {
			case Keyboard.ENTER:
				this.submit();
		}
	}
}
