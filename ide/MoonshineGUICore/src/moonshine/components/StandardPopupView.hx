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

import feathers.layout.HorizontalLayout;
import openfl.display.DisplayObject;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import moonshine.theme.MoonshineTheme;

@:styleContext
class StandardPopupView extends LayoutGroup {
	public function new() {
		super();

		this.minWidth = 350.0;
		this.minHeight = 80.0;
	}

	private var messageLabel:Label;
	private var controlsGroup:LayoutGroup;

	public var data:Dynamic;

	private var _text:String = null;

	@:flash.property
	public var text(get, set):String;

	private function get_text():String {
		return this._text;
	}

	private function set_text(value:String):String {
		if (this._text == value) {
			return this._text;
		}
		this._text = value;
		this.setInvalid(DATA);
		return this._text;
	}

	private var _controls:Array<DisplayObject> = null;

	@:flash.property
	public var controls(get, set):Array<DisplayObject>;

	private function get_controls():Array<DisplayObject> {
		return this._controls;
	}

	private function set_controls(value:Array<DisplayObject>):Array<DisplayObject> {
		if (this._controls == value) {
			return this._controls;
		}
		this._controls = value;
		this.setInvalid(DATA);
		return this._controls;
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

		this.messageLabel = new Label();
		this.messageLabel.wordWrap = true;
		this.messageLabel.layoutData = new VerticalLayoutData(100.0);
		this.addChild(this.messageLabel);

		var controlsGroupLayout = new HorizontalLayout();
		controlsGroupLayout.gap = 10.0;
		this.controlsGroup = new LayoutGroup();
		this.controlsGroup.layout = controlsGroupLayout;
		this.addChild(this.controlsGroup);

		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);

		if (dataInvalid) {
			this.messageLabel.text = this._text;
			this.updateControls();
		}

		super.update();
	}

	private function updateControls():Void {
		this.controlsGroup.removeChildren();
		if (this.controls == null) {
			return;
		}
		for (control in this.controls) {
			this.controlsGroup.addChild(control);
		}
	}
}
