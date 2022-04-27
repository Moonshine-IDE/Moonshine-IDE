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

package actionScripts.events;

import openfl.events.Event;

class LineEvent extends Event {
	public static final COLOR_CHANGE:String = "colorChange";
	public static final WIDTH_CHANGE:String = "widthChange";

	private var _line:Int;

	public var line(get, never):Int;

	public function get_line():Int {
		return _line;
	}

	public function new(type:String, line:Int) {
		super(type, false, false);

		_line = line;
	}

	override function clone():Event {
		return new LineEvent(type, line);
	}
}