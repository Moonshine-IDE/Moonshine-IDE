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

package moonshine.ui;

import feathers.layout.HorizontalLayout;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.core.InvalidationFlag;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalLayoutData;
import feathers.style.IStyleObject;
import feathers.style.IVariantStyleObject;
import lime.ui.KeyCode;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

@:styleContext
class TitleWindow extends Panel {
	public static final CHILD_VARIANT_TITLE = "titleWindow--title";
	public static final CHILD_VARIANT_CLOSE_BUTTON = "titleWindow--closeButton";

	public function new() {
		super();
		this.addEventListener(KeyboardEvent.KEY_DOWN, titleWindow_keyDownHandler);
	}

	private var _title:String;

	@:flash.property
	public var title(get, set):String;

	private function get_title():String {
		return this._title;
	}

	private function set_title(value:String):String {
		if (this._title == value) {
			return this._title;
		}
		this._title = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._title;
	}

	private var _closeEnabled:Bool = false;

	@:flash.property
	public var closeEnabled(get, set):Bool;

	private function get_closeEnabled():Bool {
		return this._closeEnabled;
	}

	private function set_closeEnabled(value:Bool):Bool {
		if (this._closeEnabled == value) {
			return this._closeEnabled;
		}
		this._closeEnabled = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._closeEnabled;
	}

	@:style
	public var customHeaderVariant:String = null;

	@:style
	public var customFooterVariant:String = null;

	private var titleLabel:Label;
	private var closeButton:Button;

	override private function initialize():Void {
		if (this.header == null) {
			var headerLayout = new HorizontalLayout();
			headerLayout.horizontalAlign = LEFT;
			headerLayout.verticalAlign = MIDDLE;
			headerLayout.paddingTop = 10.0;
			headerLayout.paddingRight = 10.0;
			headerLayout.paddingBottom = 10.0;
			headerLayout.paddingLeft = 10.0;
			headerLayout.gap = 4.0;

			var header = new LayoutGroup();
			header.layout = headerLayout;
			this.header = header;
		}
		if (this.titleLabel == null) {
			this.titleLabel = new Label();
			this.titleLabel.variant = CHILD_VARIANT_TITLE;
			this.titleLabel.layoutData = new HorizontalLayoutData(100.0);
			cast(this.header, DisplayObjectContainer).addChild(this.titleLabel);
		}
		if (this.closeButton == null) {
			this.closeButton = new Button();
			this.closeButton.variant = CHILD_VARIANT_CLOSE_BUTTON;
			this.closeButton.focusEnabled = false;
			this.closeButton.addEventListener(TriggerEvent.TRIGGER, closeButton_triggerHandler);
			cast(this.header, DisplayObjectContainer).addChild(this.closeButton);
		}
		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			this.updateTitle();
			this.updateCloseButton();
		}

		if (this.header != null && Std.is(this.header, IVariantStyleObject) && this.customHeaderVariant != null) {
			cast(this.header, IVariantStyleObject).variant = this.customHeaderVariant;
		}
		if (this.footer != null && Std.is(this.footer, IVariantStyleObject) && this.customFooterVariant != null) {
			cast(this.footer, IVariantStyleObject).variant = this.customFooterVariant;
		}

		super.update();
	}

	private function updateTitle():Void {
		this.titleLabel.text = this._title;
	}

	private function updateCloseButton():Void {
		this.closeButton.enabled = this.enabled && this._closeEnabled;
		this.closeButton.visible = this._closeEnabled;
		this.closeButton.includeInLayout = this._closeEnabled;
	}

	private function closeButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.CLOSE));
	}

	private function titleWindow_keyDownHandler(event:KeyboardEvent):Void {
		switch (event.keyCode) {
			case Keyboard.ESCAPE:
				{
					this.dispatchEvent(new Event(Event.CLOSE));
				}
			#if flash
			case Keyboard.BACK:
				{
					this.dispatchEvent(new Event(Event.CLOSE));
				}
			#end
			case KeyCode.APP_CONTROL_BACK:
				{
					this.dispatchEvent(new Event(Event.CLOSE));
				}
		}
	}
}
