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


package moonshine.plugin.help.view;

import feathers.core.IValidating;
import openfl.display.DisplayObject;
import feathers.core.InvalidationFlag;
import feathers.controls.dataRenderers.HierarchicalItemRenderer;

@:styleContext
class TourDeFlexHierarchicalItemRenderer extends HierarchicalItemRenderer {
	public function new() {
		super();
	}

	private var _currentActiveFileIndicator:DisplayObject;

	@:style
	public var activeFileIndicator:DisplayObject = null;

	private var _showActiveFileIndicator:Bool;

	@:flash.property
	public var showActiveFileIndicator(get, set):Bool;

	private function get_showActiveFileIndicator():Bool {
		return this._showActiveFileIndicator;
	}

	private function set_showActiveFileIndicator(value:Bool):Bool {
		if (this._showActiveFileIndicator == value) {
			return this._showActiveFileIndicator;
		}
		this._showActiveFileIndicator = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._showActiveFileIndicator;
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);

		if (stylesInvalid) {
			this.refreshActiveFileIndicator();
		}

		if (dataInvalid) {
			if (this._currentActiveFileIndicator != null) {
				this._currentActiveFileIndicator.visible = this._showActiveFileIndicator;
			}
		}

		super.update();
	}

	private function refreshActiveFileIndicator():Void {
		if (this.activeFileIndicator == this._currentActiveFileIndicator) {
			return;
		}
		if (this._currentActiveFileIndicator != null) {
			this.removeChild(this._currentActiveFileIndicator);
		}
		this._currentActiveFileIndicator = this.activeFileIndicator;
		if (this._currentActiveFileIndicator != null) {
			this.addChild(this._currentActiveFileIndicator);
		}
	}

	override private function layoutContent():Void {
		super.layoutContent();

		if (this._currentActiveFileIndicator != null) {
			if (Std.isOfType(this._currentActiveFileIndicator, IValidating)) {
				cast(this._currentActiveFileIndicator, IValidating).validateNow();
			}
			this._currentActiveFileIndicator.x = this.textField.x - this._currentActiveFileIndicator.width - 4.0;
			this._currentActiveFileIndicator.y = this.textField.y + (this.textField.height - this._currentActiveFileIndicator.height) / 2.0;
		}
	}
}
