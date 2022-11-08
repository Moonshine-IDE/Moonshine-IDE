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


package moonshine.plugin.search.view;

import feathers.controls.HProgressBar;
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

class ProjectSearchReplaceProgressView extends ResizableTitleWindow {
	public function new() {
		super();
		this.width = 500.0;
		this.minWidth = 350.0;
		this.minHeight = 120.0;
		this.closeEnabled = true;
		this.resizeEnabled = false;
	}

	private var progressLabel:Label;
	private var progressBar:HProgressBar;
	private var finishButton:Button;

	private var _matchCountProcessed:Int = 0;

	@:flash.property
	public var matchCountProcessed(get, set):Int;

	private function get_matchCountProcessed():Int {
		return this._matchCountProcessed;
	}

	private function set_matchCountProcessed(value:Int):Int {
		if (this._matchCountProcessed == value) {
			return this._matchCountProcessed;
		}
		this._matchCountProcessed = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._matchCountProcessed;
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

	override private function initialize():Void {
		var viewLayout = new VerticalLayout();
		viewLayout.horizontalAlign = JUSTIFY;
		viewLayout.paddingTop = 10.0;
		viewLayout.paddingRight = 10.0;
		viewLayout.paddingBottom = 10.0;
		viewLayout.paddingLeft = 10.0;
		viewLayout.gap = 10.0;
		this.layout = viewLayout;

		this.progressLabel = new Label();
		this.addChild(this.progressLabel);

		this.progressBar = new HProgressBar();
		this.addChild(this.progressBar);

		var footer = new LayoutGroup();
		footer.variant = MoonshineTheme.THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR;
		this.finishButton = new Button();
		this.finishButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.finishButton.text = "Finish";
		this.finishButton.enabled = false;
		this.finishButton.addEventListener(TriggerEvent.TRIGGER, finishButton_triggerHandler);
		footer.addChild(this.finishButton);

		this.footer = footer;

		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			this.progressLabel.text = 'Replaced: ${this._matchCountProcessed}';
			if (this._filesCount > 0) {
				this.progressBar.value = this._matchCountProcessed / this._filesCount;
			} else {
				this.progressBar.value = 0.0;
			}
			this.finishButton.enabled = this._matchCountProcessed >= this._filesCount;
		}

		super.update();
	}

	private function finishButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.CLOSE));
	}
}
