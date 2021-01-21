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

import actionScripts.ui.FeathersUIWrapper;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.core.IFocusObject;
import feathers.core.InvalidationFlag;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.style.IStyleObject;
import feathers.style.IVariantStyleObject;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.ui.Keyboard;
#if lime
import lime.ui.KeyCode;
#end

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

	private var _dragTarget:DisplayObject;
	private var _dragStartX:Float;
	private var _dragStartY:Float;
	private var _dragStartStageX:Float;
	private var _dragStartStageY:Float;

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
			header.addEventListener(MouseEvent.MOUSE_DOWN, titleWindow_header_mouseDownHandler);
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
			#if lime
			case KeyCode.APP_CONTROL_BACK:
				{
					this.dispatchEvent(new Event(Event.CLOSE));
				}
			#end
		}
	}

	private function titleWindow_header_mouseDownHandler(event:MouseEvent):Void {
		var header = cast(event.currentTarget, DisplayObject);
		var current = cast(event.target, DisplayObject);
		while (current != null && current != header) {
			if (current == this.closeButton) {
				return;
			}
			if (Std.is(current, IFocusObject)) {
				var focusable = cast(current, IFocusObject);
				if (focusable.focusEnabled) {
					return;
				}
			}
			current = current.parent;
		}

		this._dragTarget = Std.is(this.parent, FeathersUIWrapper) ? this.parent : this;
		this._dragStartX = this._dragTarget.x;
		this._dragStartY = this._dragTarget.y;
		this._dragStartStageX = event.stageX;
		this._dragStartStageY = event.stageY;
		this.stage.addEventListener(MouseEvent.MOUSE_MOVE, titleWindow_header_stage_mouseMoveHandler, false, 0, true);
		this.stage.addEventListener(MouseEvent.MOUSE_UP, titleWindow_header_stage_mouseUpHandler, false, 0, true);
	}

	private function titleWindow_header_stage_mouseMoveHandler(event:MouseEvent):Void {
		this._dragTarget.x = this._dragStartX + event.stageX - this._dragStartStageX;
		this._dragTarget.y = this._dragStartY + event.stageY - this._dragStartStageY;
	}

	private function titleWindow_header_stage_mouseUpHandler(event:MouseEvent):Void {
		this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, titleWindow_header_stage_mouseMoveHandler);
		this.stage.removeEventListener(MouseEvent.MOUSE_UP, titleWindow_header_stage_mouseUpHandler);
		this._dragTarget = null;
	}
}
