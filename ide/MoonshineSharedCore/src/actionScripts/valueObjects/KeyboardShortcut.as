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