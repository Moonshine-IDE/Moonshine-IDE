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

import feathers.controls.Check;
import feathers.layout.HorizontalLayout;
import feathers.controls.Radio;
import feathers.core.ToggleGroup;
import feathers.layout.HorizontalLayoutData;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
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

class FindReplaceView extends ResizableTitleWindow {
	public static final EVENT_FIND_NEXT = "findNext";
	public static final EVENT_FIND_PREVIOUS = "findPrevious";
	public static final EVENT_REPLACE_ONE = "replaceOne";
	public static final EVENT_REPLACE_ALL = "replaceAll";

	public function new() {
		MoonshineTheme.initializeTheme();

		super();
		this.width = 500.0;
		this.minWidth = 350.0;
		this.minHeight = 250.0;
		this.closeEnabled = true;
		this.resizeEnabled = true;
	}

	private var findResultCountLabel:Label;
	private var findTextInput:TextInput;
	private var replaceTextInput:TextInput;
	private var findButton:Button;
	private var replaceOneButton:Button;
	private var replaceAllButton:Button;
	private var matchCaseCheck:Check;
	private var regExpCheck:Check;
	private var escapeCharsCheck:Check;
	private var directionGroup:ToggleGroup;
	private var forwardRadio:Radio;
	private var backwardRadio:Radio;

	private var _pendingInitialFindText:String = null;

	private var _initialFindText:String = null;

	@:flash.property
	public var initialFindText(get, set):String;

	private function get_initialFindText():String {
		return this._initialFindText;
	}

	private function set_initialFindText(value:String):String {
		if (this._initialFindText == value) {
			return this._initialFindText;
		}
		this._initialFindText = value;
		this._pendingInitialFindText = value;
		this.setInvalid(DATA);
		return this._initialFindText;
	}

	private var _findText:String = "";

	@:flash.property
	public var findText(get, never):String;

	private function get_findText():String {
		return this._findText;
	}

	private var _replaceText:String = "";

	@:flash.property
	public var replaceText(get, never):String;

	private function get_replaceText():String {
		return this._replaceText;
	}

	private var _findOnly:Bool = false;

	@:flash.property
	public var findOnly(get, set):Bool;

	private function get_findOnly():Bool {
		return this._findOnly;
	}

	private function set_findOnly(value:Bool):Bool {
		if (this._findOnly == value) {
			return this._findOnly;
		}
		this._findOnly = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._findOnly;
	}

	private var _resultIndex:Int = 0;

	@:flash.property
	public var resultIndex(get, set):Int;

	private function get_resultIndex():Int {
		return this._resultIndex;
	}

	private function set_resultIndex(value:Int):Int {
		if (this._resultIndex == value) {
			return this._resultIndex;
		}
		this._resultIndex = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._resultIndex;
	}

	private var _resultCount:Int = 0;

	@:flash.property
	public var resultCount(get, set):Int;

	private function get_resultCount():Int {
		return this._resultCount;
	}

	private function set_resultCount(value:Int):Int {
		if (this._resultCount == value) {
			return this._resultCount;
		}
		this._resultCount = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._resultCount;
	}

	private var _matchCaseEnabled:Bool = false;

	@:flash.property
	public var matchCaseEnabled(get, never):Bool;

	private function get_matchCaseEnabled():Bool {
		return this._matchCaseEnabled;
	}

	private var _regExpEnabled:Bool = false;

	@:flash.property
	public var regExpEnabled(get, never):Bool;

	private function get_regExpEnabled():Bool {
		return this._regExpEnabled;
	}

	private var _escapeCharsEnabled:Bool = false;

	@:flash.property
	public var escapeCharsEnabled(get, never):Bool;

	private function get_escapeCharsEnabled():Bool {
		return this._escapeCharsEnabled;
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

		this.findTextInput = new TextInput();
		this.findTextInput.prompt = "Find";
		this.findTextInput.addEventListener(Event.CHANGE, findTextInput_changeHandler);
		this.findTextInput.addEventListener(KeyboardEvent.KEY_DOWN, findTextInput_keyDownHandler);
		this.addChild(this.findTextInput);

		this.findResultCountLabel = new Label();
		this.findResultCountLabel.variant = MoonshineTheme.THEME_VARIANT_LIGHT_LABEL;
		// TODO: switch to rightView when it's available in Feathers UI
		// this.findTextInput.rightView = this.findResultCountLabel;

		this.replaceTextInput = new TextInput();
		this.replaceTextInput.prompt = "Replace";
		this.replaceTextInput.addEventListener(Event.CHANGE, replaceTextInput_changeHandler);
		this.replaceTextInput.addEventListener(KeyboardEvent.KEY_DOWN, replaceTextInput_keyDownHandler);
		this.addChild(this.replaceTextInput);

		var optionsField = new LayoutGroup();
		var optionsFieldLayout = new HorizontalLayout();
		optionsFieldLayout.gap = 10.0;
		optionsField.layout = optionsFieldLayout;
		this.addChild(optionsField);
		this.matchCaseCheck = new Check();
		this.matchCaseCheck.text = "Match case";
		this.matchCaseCheck.addEventListener(Event.CHANGE, matchCaseCheck_changeHandler);
		optionsField.addChild(this.matchCaseCheck);
		this.regExpCheck = new Check();
		this.regExpCheck.text = "RegExp";
		this.regExpCheck.addEventListener(Event.CHANGE, regExpCheck_changeHandler);
		optionsField.addChild(this.regExpCheck);
		this.escapeCharsCheck = new Check();
		this.escapeCharsCheck.text = "Escape chars";
		this.escapeCharsCheck.addEventListener(Event.CHANGE, escapeCharsCheck_changeHandler);
		optionsField.addChild(this.escapeCharsCheck);

		this.directionGroup = new ToggleGroup();
		var directionField = new LayoutGroup();
		var directionFieldLayout = new HorizontalLayout();
		directionFieldLayout.gap = 10.0;
		directionField.layout = directionFieldLayout;
		this.addChild(directionField);
		this.forwardRadio = new Radio();
		this.forwardRadio.text = "Forward";
		this.forwardRadio.toggleGroup = this.directionGroup;
		directionField.addChild(this.forwardRadio);
		this.backwardRadio = new Radio();
		this.backwardRadio.text = "Backward";
		this.backwardRadio.toggleGroup = this.directionGroup;
		directionField.addChild(this.backwardRadio);

		var footer = new LayoutGroup();
		footer.variant = MoonshineTheme.THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR;
		this.replaceOneButton = new Button();
		this.replaceOneButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.replaceOneButton.text = "Replace/Find";
		this.replaceOneButton.addEventListener(TriggerEvent.TRIGGER, replaceOneButton_triggerHandler);
		footer.addChild(this.replaceOneButton);
		this.replaceAllButton = new Button();
		this.replaceAllButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.replaceAllButton.text = "Replace All";
		this.replaceAllButton.addEventListener(TriggerEvent.TRIGGER, replaceAllButton_triggerHandler);
		footer.addChild(this.replaceAllButton);
		var spacer = new LayoutGroup();
		spacer.layoutData = new HorizontalLayoutData(100.0);
		footer.addChild(spacer);
		// TODO: move back to TextInput when Feathers UI supports rightView
		footer.addChild(this.findResultCountLabel);
		this.findButton = new Button();
		this.findButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.findButton.enabled = false;
		this.findButton.text = "Find";
		this.findButton.addEventListener(TriggerEvent.TRIGGER, findButton_triggerHandler);
		footer.addChild(this.findButton);
		this.footer = footer;

		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			this.title = this._findOnly ? "Find" : "Find/Replace";
			this.replaceTextInput.visible = !this._findOnly;
			this.replaceTextInput.includeInLayout = !this._findOnly;
			this.replaceOneButton.visible = !this._findOnly;
			this.replaceOneButton.includeInLayout = !this._findOnly;
			this.replaceAllButton.visible = !this._findOnly;
			this.replaceAllButton.includeInLayout = !this._findOnly;
			this.findResultCountLabel.text = this._resultCount > 0 ? this._resultIndex + "/" + this._resultCount : "0";
			if (this._pendingInitialFindText != null) {
				this.findTextInput.text = this._pendingInitialFindText;
				this._pendingInitialFindText = null;
			}
		}

		super.update();
	}

	private function findNext():Void {
		if (!this.findButton.enabled) {
			return;
		}
		this.dispatchEvent(new Event(EVENT_FIND_NEXT));
	}

	private function findPrevious():Void {
		if (!this.findButton.enabled) {
			return;
		}
		this.dispatchEvent(new Event(EVENT_FIND_PREVIOUS));
	}

	private function replaceOne():Void {
		if (!this.replaceOneButton.enabled) {
			return;
		}
		this.dispatchEvent(new Event(EVENT_REPLACE_ONE));
		findNext();
	}

	private function replaceAll():Void {
		if (!this.replaceAllButton.enabled) {
			return;
		}
		this.dispatchEvent(new Event(EVENT_REPLACE_ALL));
	}

	private function findTextInput_changeHandler(event:Event):Void {
		this.findButton.enabled = this.findTextInput.text.length > 0;
		this._findText = this.findTextInput.text;
		this.resultIndex = 0;
		this.resultCount = 0;
	}

	private function findTextInput_keyDownHandler(event:KeyboardEvent):Void {
		switch (event.keyCode) {
			case Keyboard.ENTER:
				this.findNext();
		}
	}

	private function replaceTextInput_changeHandler(event:Event):Void {
		this._replaceText = this.replaceTextInput.text;
	}

	private function replaceTextInput_keyDownHandler(event:KeyboardEvent):Void {
		switch (event.keyCode) {
			case Keyboard.ENTER:
				this.replaceOne();
		}
	}

	private function findButton_triggerHandler(event:TriggerEvent):Void {
		if (this.directionGroup.selectedItem == this.forwardRadio) {
			this.findNext();
		} else {
			this.findPrevious();
		}
	}

	private function replaceOneButton_triggerHandler(event:TriggerEvent):Void {
		this.replaceOne();
	}

	private function replaceAllButton_triggerHandler(event:TriggerEvent):Void {
		this.replaceAll();
	}

	private function matchCaseCheck_changeHandler(event:Event):Void {
		this._matchCaseEnabled = this.matchCaseCheck.selected;
	}

	private function regExpCheck_changeHandler(event:Event):Void {
		this._regExpEnabled = this.regExpCheck.selected;
	}

	private function escapeCharsCheck_changeHandler(event:Event):Void {
		this._escapeCharsEnabled = this.escapeCharsCheck.selected;
	}
}
