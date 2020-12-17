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
		MoonshineTheme.initializeTheme();

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
