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

package moonshine.plugin.problems.view;

import moonshine.theme.assets.DiagnosticInfoIcon;
import moonshine.theme.assets.DiagnosticWarningIcon;
import moonshine.theme.assets.DiagnosticErrorIcon;
import openfl.display.DisplayObject;
import openfl.display.Bitmap;
import feathers.core.FeathersControl;
import moonshine.lsp.DiagnosticSeverity;

/**
	Displays an icon for the "severity" of a diagnostic.
**/
@:styleContext
class DiagnosticSeverityIcon extends FeathersControl {
	/**
		Creates a new `DiagnosticSeverityIcon` object.
	**/
	public function new() {
		super();
	}
	
	private var _currentIcon:DisplayObject;

	private var _severity:DiagnosticSeverity = Error;

	/**
		The severity of the diagnostic.
	**/
	@:flash.property
	public var severity(get, set):DiagnosticSeverity;

	private function get_severity():DiagnosticSeverity {
		return _severity;
	}

	private function set_severity(value:DiagnosticSeverity):DiagnosticSeverity {
		if (_severity == value) {
			return _severity;
		}
		_severity = value;
		setInvalid(DATA);
		return _severity;
	}

	override private function update():Void {
		var dataInvalid = isInvalid(DATA);

		if (dataInvalid) {
			refreshIcon();
		}

		measure();

		layoutContent();
	}

	private function measure():Void {
		saveMeasurements(16.0, 16.0, 16.0, 16.0);
	}
	
	private function refreshIcon():Void {
		var iconClass:Class<Dynamic> = switch(_severity) {
			case Error: DiagnosticErrorIcon;
			case Warning: DiagnosticWarningIcon;
			default: DiagnosticInfoIcon;
		}
		
		if (Std.isOfType(this._currentIcon, iconClass)) {
			// the existing icon is correct, so keep it as-is
			return;
		}
		
		if (_currentIcon != null) {
			removeChild(_currentIcon);
			_currentIcon = null;
		}
		var bitmapData = Type.createInstance(iconClass, []);
		_currentIcon = new Bitmap(bitmapData);
		addChild(_currentIcon);
	}

	private function layoutContent():Void {
		_currentIcon.x = 0.0;
		_currentIcon.y = 0.0;
		_currentIcon.width = 16.0;
		_currentIcon.height = 16.0;
	}
}
