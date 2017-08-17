////////////////////////////////////////////////////////////////////////////////
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
// 
////////////////////////////////////////////////////////////////////////////////
package actionScripts.valueObjects
{
	import flash.ui.Keyboard;

	public class KeyboardShortcut
	{
		public var altKey:Boolean
		public var ctrlKey:Boolean
		public var cmdKey:Boolean
		public var shiftKey:Boolean
		public var keyCode:uint
		private var _event:String

		private static const SHIFT_KEYCODE_CHAR_MAP:Object = {

				192:["`", "~"],
				220:["\\", "|"],
				188:[",", "<"],
				187:["=", "+"],
				219:["[", "{"],
				189:["-", "_"],
				190:[".", ">"],
				222:["'", "\""],
				221:["]", "}"],
				191:["/", "?"],
				186:[";", ":"]
			}
		private static const STRING_KEYCODE_TEXT_CONVERSION:Object = {
				"\n":[Keyboard.ENTER, "Enter"],
				" ":[Keyboard.SPACE, "Space"]
			};

		private static var KEYCODE_STRING_TEXT_CONVERSION:Object = {};


		private static var SHIFT_CHAR_KEYCODE_MAP:Object = {};

		// setup mapping once and only once
		init();

		private static function init():void
		{
			for (var keyCode:String in SHIFT_KEYCODE_CHAR_MAP)
			{
				SHIFT_CHAR_KEYCODE_MAP[SHIFT_KEYCODE_CHAR_MAP[keyCode][0]] = keyCode; // Non Shift
				SHIFT_CHAR_KEYCODE_MAP[SHIFT_KEYCODE_CHAR_MAP[keyCode][1]] = keyCode; // Shift

			}
			for (var str:String in STRING_KEYCODE_TEXT_CONVERSION)
			{
				KEYCODE_STRING_TEXT_CONVERSION[STRING_KEYCODE_TEXT_CONVERSION[str][0]] = [str, STRING_KEYCODE_TEXT_CONVERSION[str][1]];
			}


		}

		public function KeyboardShortcut(event:String, key:String, modifiers:Array=null):void
		{
			_event = event;
			parse(key, modifiers || []);
		}

		public function toString():String
		{
			var keys:Array = [];
			if (altKey)
				keys.push("Alt");
			if (ctrlKey)
				keys.push("Ctrl");
			if (shiftKey)
				keys.push("Shift");
			if (cmdKey)
				keys.push("Cmd");


			if (SHIFT_KEYCODE_CHAR_MAP[keyCode])
			{
				keys.push(shiftKey ? SHIFT_KEYCODE_CHAR_MAP[keyCode][1] : SHIFT_KEYCODE_CHAR_MAP[keyCode][0]);
			}
			else if (keyCode >= 112 && keyCode <= 123)
			{ // function keys			
				keys.push("F" + String((keyCode % 112) + 1));
			}
			else if (keyCode > 64 && keyCode < 91)
			{
				var char:String = String.fromCharCode("0x" + Number(keyCode).toString(16));
				keys.push(shiftKey ? char.toUpperCase() : char.toLowerCase());
			}
			else if (KEYCODE_STRING_TEXT_CONVERSION[keyCode])
			{
				keys.push(KEYCODE_STRING_TEXT_CONVERSION[keyCode][1]) // String translation
			}

			return keys.join("+");
		}

		private function parse(key:String, modifiers:Array):void
		{
			if (modifiers.indexOf(Keyboard.ALTERNATE) != -1)
				altKey = true;
			if (modifiers.indexOf(Keyboard.COMMAND) != -1)
				cmdKey = true;
			if (modifiers.indexOf(Keyboard.CONTROL) != -1)
				ctrlKey = true;
			if (modifiers.indexOf(Keyboard.SHIFT) != -1)
				shiftKey = true;

			var charCode:int = key.charCodeAt(0);
			if (charCode > 64 && charCode < 91) // isUpperCase
				shiftKey = true;

			if (STRING_KEYCODE_TEXT_CONVERSION[key])
			{
				keyCode = STRING_KEYCODE_TEXT_CONVERSION[key][0];
				return;
			}

			key = key.toUpperCase();
			if (Keyboard[key])
			{
				keyCode = Keyboard[key];
			}
			else if (Keyboard["NUMBER_" + key])
			{
				keyCode = Keyboard["NUMBER_" + key];
			}
			else if (!isNaN(parseInt(key)))
			{
				keyCode = parseInt(key);
			}
			else if (SHIFT_CHAR_KEYCODE_MAP[key])
			{
				keyCode = SHIFT_CHAR_KEYCODE_MAP[key];
			}
		}

		public function get event():String
		{
			return _event;
		}
	}
}