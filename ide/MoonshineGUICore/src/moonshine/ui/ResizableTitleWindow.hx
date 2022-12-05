////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
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
		if (Std.isOfType(this._currentResizeHandleSkin, IValidating)) {
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
