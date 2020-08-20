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

package moonshine.plugin.findreplace.view;

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

class GoToLineView extends ResizableTitleWindow {
	public function new() {
		MoonshineTheme.initializeTheme();

		super();
		this.title = "Go To Line";
		this.width = 400.0;
		this.minWidth = 300.0;
		this.minHeight = 170.0;
		this.closeEnabled = true;
		this.resizeEnabled = true;
	}

	private var lineNumberFieldLabel:Label;
	private var lineNumberTextInput:TextInput;
	private var goToLineButton:Button;

	private var _lineNumber:Int = -1;

	@:flash.property
	public var lineNumber(get, never):Int;

	private function get_lineNumber():Int {
		return this._lineNumber;
	}

	private var _maxLineNumber:Int = 1;

	@:flash.property
	public var maxLineNumber(get, set):Int;

	private function get_maxLineNumber():Int {
		return this._maxLineNumber;
	}

	private function set_maxLineNumber(value:Int):Int {
		if (this._maxLineNumber == value) {
			return this._maxLineNumber;
		}
		this._maxLineNumber = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._maxLineNumber;
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

		var lineNumberField = new LayoutGroup();
		var searchFieldLayout = new VerticalLayout();
		searchFieldLayout.horizontalAlign = JUSTIFY;
		searchFieldLayout.gap = 10.0;
		lineNumberField.layout = searchFieldLayout;
		this.addChild(lineNumberField);

		this.lineNumberFieldLabel = new Label();
		// setting text in update() because it depends on the max value
		lineNumberField.addChild(this.lineNumberFieldLabel);

		this.lineNumberTextInput = new TextInput();
		this.lineNumberTextInput.prompt = "#";
		this.lineNumberTextInput.restrict = "0-9";
		this.lineNumberTextInput.addEventListener(Event.CHANGE, lineNumberTextInput_changeHandler);
		this.lineNumberTextInput.addEventListener(KeyboardEvent.KEY_DOWN, lineNumberTextInput_keyDownHandler);
		lineNumberField.addChild(this.lineNumberTextInput);

		var footer = new LayoutGroup();
		footer.variant = MoonshineTheme.THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR;
		this.goToLineButton = new Button();
		this.goToLineButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.goToLineButton.enabled = false;
		this.goToLineButton.text = "Go To Line";
		this.goToLineButton.addEventListener(TriggerEvent.TRIGGER, goToLineButton_triggerHandler);
		footer.addChild(this.goToLineButton);
		this.footer = footer;

		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			this.lineNumberFieldLabel.text = 'Enter line number: (1 - ${this._maxLineNumber})';
		}

		super.update();
	}

	private function parseLineNumber():Int {
		if (this.lineNumberTextInput == null || this.lineNumberTextInput.text.length == 0) {
			return -1;
		}
		return Std.parseInt(this.lineNumberTextInput.text);
	}

	private function submit():Void {
		if (!this.goToLineButton.enabled) {
			return;
		}
		this._lineNumber = this.parseLineNumber();
		this.dispatchEvent(new Event(Event.CLOSE));
	}

	private function lineNumberTextInput_changeHandler(event:Event):Void {
		var lineNumber = this.parseLineNumber();
		this.goToLineButton.enabled = lineNumber >= 1 && lineNumber <= this._maxLineNumber;
	}

	private function goToLineButton_triggerHandler(event:TriggerEvent):Void {
		this.submit();
	}

	private function lineNumberTextInput_keyDownHandler(event:KeyboardEvent):Void {
		switch (event.keyCode) {
			case Keyboard.ENTER:
				this.submit();
		}
	}
}
