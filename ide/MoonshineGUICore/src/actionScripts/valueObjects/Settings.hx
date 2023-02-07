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


package actionScripts.valueObjects;

import openfl.sensors.Accelerometer;
import openfl.system.Capabilities;
import openfl.desktop.Clipboard;

class Settings {
	@:noCompletion
	private static var _initialized:Bool = false;
	@:noCompletion
	private static var _os:String;
	@:noCompletion
	private static var _keyboard:KeyboardSettings;
	@:noCompletion
	private static var _font:FontSettings;

	public static var os(get, never):String;

	@:getter(os)
	public static function get_os():String {
		if (!_initialized)
			_init();
		return _os;
	}

	public static var keyboard(get, never):KeyboardSettings;

	@:getter(keyboard)
	public static function get_keyboard():KeyboardSettings {
		if (!_initialized)
			_init();
		return _keyboard;
	}

	public static var font(get, never):FontSettings;

	@:getter(font)
	public static function get_font():FontSettings {
		if (!_initialized)
			_init();
		return _font;
	}

	private static function _init() {
		#if air
		_os = Capabilities.os.substr(0, 3).toLowerCase();
		#else
		_os = Capabilities.version.substr(0, 3).toLowerCase();
		#end
		_keyboard = new KeyboardSettings();
		_font = new FontSettings();

		_initialized = true;
	}

	public function new() {}

}