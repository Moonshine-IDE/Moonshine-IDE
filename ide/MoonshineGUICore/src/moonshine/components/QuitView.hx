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

package moonshine.components;

import feathers.controls.Check;
import actionScripts.valueObjects.ConstantsCoreVO;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.events.TriggerEvent;
import feathers.layout.VerticalLayout;
import moonshine.theme.MoonshineTheme;
import moonshine.ui.ResizableTitleWindow;
import openfl.events.Event;

class QuitView extends ResizableTitleWindow {
	public function new() {
		MoonshineTheme.initializeTheme();

		super();

		this.title = ConstantsCoreVO.MOONSHINE_IDE_LABEL;
		this.width = 400.0;
		this.minWidth = 400.0;
		this.minHeight = 200.0;
		this.closeEnabled = true;
		this.resizeEnabled = false;
	}

	private var doNotAskCheck:Check;
	private var cancelButton:Button;
	private var exitButton:Button;

	private var _confirmedExit:Bool = false;

	@:flash.property
	public var confirmedExit(get, never):Bool;

	private function get_confirmedExit():Bool {
		return this._confirmedExit;
	}

	private var _alwaysConfirmExit:Bool = false;

	@:flash.property
	public var alwaysConfirmExit(get, set):Bool;

	private function get_alwaysConfirmExit():Bool {
		return this._alwaysConfirmExit;
	}

	private function set_alwaysConfirmExit(value:Bool):Bool {
		if (this._alwaysConfirmExit == value) {
			return this._alwaysConfirmExit;
		}
		this._alwaysConfirmExit = value;
		this.setInvalid(DATA);
		return this._alwaysConfirmExit;
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

		var messageLabel = new Label();
		messageLabel.text = 'Are you sure you want to exit ${ConstantsCoreVO.MOONSHINE_IDE_LABEL}?';
		messageLabel.wordWrap = true;
		this.addChild(messageLabel);

		this.doNotAskCheck = new Check();
		this.doNotAskCheck.text = "Do not ask me again";
		this.doNotAskCheck.addEventListener(Event.CHANGE, doNotAskCheck_changeHandler);
		this.addChild(this.doNotAskCheck);

		var footer = new LayoutGroup();
		footer.variant = MoonshineTheme.THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR;
		this.cancelButton = new Button();
		this.cancelButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.cancelButton.text = "Cancel";
		this.cancelButton.addEventListener(TriggerEvent.TRIGGER, cancelButton_triggerHandler);
		footer.addChild(this.cancelButton);
		this.exitButton = new Button();
		this.exitButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.exitButton.text = "Exit";
		this.exitButton.addEventListener(TriggerEvent.TRIGGER, exitButton_triggerHandler);
		footer.addChild(this.exitButton);
		this.footer = footer;

		super.initialize();
	}

	override private function update():Void {
		this.doNotAskCheck.selected = !this._alwaysConfirmExit;
		super.update();
	}

	private function cancelButton_triggerHandler(event:TriggerEvent):Void {
		this._confirmedExit = false;
		this.dispatchEvent(new Event(Event.CLOSE));
	}

	private function exitButton_triggerHandler(event:TriggerEvent):Void {
		this._confirmedExit = true;
		this.dispatchEvent(new Event(Event.CLOSE));
	}

	private function doNotAskCheck_changeHandler(event:Event):Void {
		this._alwaysConfirmExit = !this.doNotAskCheck.selected;
	}
}
