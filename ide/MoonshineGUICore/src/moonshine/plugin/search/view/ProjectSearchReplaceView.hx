/*
	Copyright 2022 Prominic.NET, Inc.

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

package moonshine.plugin.search.view;

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

class ProjectSearchReplaceView extends ResizableTitleWindow {
	public static final EVENT_PREVIEW = "preview";
	public static final EVENT_REPLACE = "replace";

	public function new() {
		super();
		this.width = 500.0;
		this.minWidth = 350.0;
		this.minHeight = 220.0;
		this.closeEnabled = true;
		this.resizeEnabled = true;
	}

	private var descriptionLabel:Label;
	private var searchTextInput:TextInput;
	private var replaceTextInput:TextInput;
	private var previewButton:Button;
	private var replaceButton:Button;

	private var _matchCount:Int = 0;

	@:flash.property
	public var matchCount(get, set):Int;

	private function get_matchCount():Int {
		return this._matchCount;
	}

	private function set_matchCount(value:Int):Int {
		if (this._matchCount == value) {
			return this._matchCount;
		}
		this._matchCount = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._matchCount;
	}

	private var _filesCount:Int = 0;

	@:flash.property
	public var filesCount(get, set):Int;

	private function get_filesCount():Int {
		return this._filesCount;
	}

	private function set_filesCount(value:Int):Int {
		if (this._filesCount == value) {
			return this._filesCount;
		}
		this._filesCount = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._filesCount;
	}

	private var _textToReplace:String = "";

	@:flash.property
	public var textToReplace(get, set):String;

	private function get_textToReplace():String {
		return this._textToReplace;
	}

	private function set_textToReplace(value:String):String {
		if (this._textToReplace == value) {
			return this._textToReplace;
		}
		this._textToReplace = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._textToReplace;
	}

	private var _newText:String = "";

	@:flash.property
	public var newText(get, never):String;

	private function get_newText():String {
		return this._newText;
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

		this.descriptionLabel = new Label();
		this.addChild(descriptionLabel);

		this.searchTextInput = new TextInput();
		this.searchTextInput.tabEnabled = false;
		this.searchTextInput.editable = false;
		this.addChild(this.searchTextInput);

		this.replaceTextInput = new TextInput();
		this.replaceTextInput.prompt = "New Text";
		this.addChild(this.replaceTextInput);

		var footer = new LayoutGroup();
		footer.variant = MoonshineTheme.THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR;

		this.previewButton = new Button();
		this.previewButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.previewButton.text = "Preview";
		this.previewButton.addEventListener(TriggerEvent.TRIGGER, previewButton_triggerHandler);
		footer.addChild(this.previewButton);
		this.replaceButton = new Button();
		this.replaceButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.replaceButton.text = "Replace";
		this.replaceButton.addEventListener(TriggerEvent.TRIGGER, replaceButton_triggerHandler);
		footer.addChild(this.replaceButton);

		this.footer = footer;

		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			this.searchTextInput.text = this._textToReplace;
			this.descriptionLabel.text = 'Replacing ${this._matchCount} match${(this._matchCount != 1) ? "es" : ""} in ${this._filesCount} file${(this._filesCount != 1) ? "s" : ""}';
		}

		super.update();
	}

	private function previewButton_triggerHandler(event:TriggerEvent):Void {
		this._newText = this.replaceTextInput.text;
		this.dispatchEvent(new Event(EVENT_PREVIEW));
	}

	private function replaceButton_triggerHandler(event:TriggerEvent):Void {
		this._newText = this.replaceTextInput.text;
		this.dispatchEvent(new Event(EVENT_REPLACE));
	}
}
