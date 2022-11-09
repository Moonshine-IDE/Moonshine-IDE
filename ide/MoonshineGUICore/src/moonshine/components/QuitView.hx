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
