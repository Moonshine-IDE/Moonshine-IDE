/*
	Copyright 2022 Prominic.NET, Inc.

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

package actionScripts.valueObjects;

import flash.sensors.Accelerometer;
import flash.system.Capabilities;
import flash.desktop.Clipboard;

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

	static public function doSomething() {
		trace("1:", Clipboard.generalClipboard.formats);
		// trace( "2:", Clipboard.generalClipboard.supportsFilePromise );

		trace("Hello Pjotr!");
	}
}