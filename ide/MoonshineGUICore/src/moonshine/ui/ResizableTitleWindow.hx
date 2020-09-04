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

import feathers.core.IValidating;
import feathers.core.InvalidationFlag;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

class ResizableTitleWindow extends TitleWindow {
	public function new() {
		super();
	}

	private var _resizeHandle:Sprite;

	private var _resizeEnabled:Bool = true;

	@:flash.property
	public var resizeEnabled(get, set):Bool;

	private function get_resizeEnabled():Bool {
		return this._resizeEnabled;
	}

	private function set_resizeEnabled(value:Bool):Bool {
		if (this._resizeEnabled == value) {
			return this._resizeEnabled;
		}
		this._resizeEnabled = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._resizeEnabled;
	}

	private var _currentResizeHandleSkin:DisplayObject;

	@:style
	@:flash.property
	public var resizeHandleSkin:DisplayObject = null;

	override private function initialize():Void {
		super.initialize();

		if (this._resizeHandle == null) {
			this._resizeHandle = new Sprite();
			this.addRawChild(this._resizeHandle);
		}
		this._resizeHandle.addEventListener(MouseEvent.MOUSE_DOWN, resizeHandle_mouseDownHandler);
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);

		if (stylesInvalid) {
			this.updateResizeHandleSkin();
		}

		if (stylesInvalid || dataInvalid) {
			this.updateResizeHandle();
		}

		super.update();

		this.layoutResizeHandle();
	}

	private function updateResizeHandleSkin():Void {
		var oldSkin = this._currentResizeHandleSkin;
		this._currentResizeHandleSkin = this.resizeHandleSkin;
		if (this._currentResizeHandleSkin == oldSkin) {
			return;
		}
		if (oldSkin != null) {
			this._resizeHandle.removeChild(oldSkin);
		}
		if (this._currentResizeHandleSkin != null) {
			this._resizeHandle.addChild(this._currentResizeHandleSkin);
		}
	}

	private function updateResizeHandle():Void {
		if (this._currentResizeHandleSkin == null) {
			return;
		}
		this._currentResizeHandleSkin.visible = this._resizeEnabled;
	}

	private function layoutResizeHandle():Void {
		if (this._currentResizeHandleSkin == null) {
			return;
		}
		if (Std.is(this._currentResizeHandleSkin, IValidating)) {
			cast(this._currentResizeHandleSkin, IValidating).validateNow();
		}
		this._resizeHandle.x = this.actualWidth - this.paddingRight - this._currentResizeHandleSkin.width;
		this._resizeHandle.y = this.actualHeight - this.paddingBottom - this._currentResizeHandleSkin.height;

		if (this.getRawChildIndex(this._resizeHandle) != (this.numRawChildren - 1)) {
			this.setRawChildIndex(this._resizeHandle, this.numRawChildren - 1);
		}
	}

	private var _startResizeWidth:Float;
	private var _startResizeHeight:Float;
	private var _startResizeX:Float;
	private var _startResizeY:Float;

	private function resizeHandle_mouseDownHandler(event:MouseEvent):Void {
		this._startResizeX = event.stageX;
		this._startResizeY = event.stageY;
		this._startResizeWidth = this.actualWidth;
		this._startResizeHeight = this.actualHeight;

		this.stage.addEventListener(MouseEvent.MOUSE_MOVE, resizeHandle_stage_mouseMoveHandler, false, 0, true);
		this.stage.addEventListener(MouseEvent.MOUSE_UP, resizeHandle_stage_mouseUpHandler, false, 0, true);
	}

	private function resizeHandle_stage_mouseMoveHandler(event:MouseEvent):Void {
		var newWidth = this._startResizeWidth + event.stageX - this._startResizeX;
		var newHeight = this._startResizeHeight + event.stageY - this._startResizeY;

		if (newWidth < this.minWidth) {
			newWidth = this.minWidth;
		}
		if (newHeight < this.minHeight) {
			newHeight = this.minHeight;
		}

		this.width = newWidth;
		this.height = newHeight;
	}

	private function resizeHandle_stage_mouseUpHandler(event:MouseEvent):Void {
		this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, resizeHandle_stage_mouseMoveHandler);
		this.stage.removeEventListener(MouseEvent.MOUSE_UP, resizeHandle_stage_mouseUpHandler);
	}
}
