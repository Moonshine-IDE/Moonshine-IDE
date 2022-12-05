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

package actionScripts.plugin.console;

import haxe.Rest;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.plugin.console.ConsoleTextLineModel;
import actionScripts.ui.editor.text.TextLineModel;
import actionScripts.utils.HtmlFormatter;
import no.doomsday.console.ConsoleUtil;
#if flash
import flash.Vector;
#else
import openfl.Vector;
#end
import openfl.events.EventDispatcher;

class ConsoleOutputter extends EventDispatcher {
	public static var DEBUG:Bool = true;
	public static var name(get, never):String;

	private static var _name:String = "";

	public static function get_name():String
		return _name;

	public function new() {
		super();
	}

	private function success(str:String, ...replacements):Void {
		formatOutput(HtmlFormatter.sprintfa(str, replacements), 'success');
	}

	// Console output functions, use %s for substitution
	private function notice(str:String, ...replacements):Void {
		formatOutput(HtmlFormatter.sprintfa(str, replacements), 'notice');
	}

	private function error(str:String, ...replacements):Void {
		formatOutput(HtmlFormatter.sprintfa(str, replacements), 'error');
	}

	private function warning(str:String, ...replacements):Void {
		formatOutput(HtmlFormatter.sprintfa(str, replacements), 'warning');
	}

	private function print(str:String, ...replacements:Any):Void {
		ConsoleUtil.print(str);
		formatOutput(HtmlFormatter.sprintfa(str, replacements), 'weak');
	}

	private function debug(str:String, ...replacements):Void {
		#if debug
		formatOutput(HtmlFormatter.sprintfa(str, replacements), 'weak');
		#end
	}

	public function formatOutput(str:String, style:String, showWhenDone:Bool = true):Vector<TextLineModel> {
		var textLines = str.split("\n");
		var lines:Vector<TextLineModel> = new Vector<TextLineModel>();
		for (i in textLines) {
			if (i == "")
				continue;
			var text:String = HtmlFormatter.sprintf("<%x>%x:</%x> %x", style, _name, style, i);
			var lineModel:TextLineModel = new ConsoleTextLineModel(text, style);
			lines.push(lineModel);
		}

		if (showWhenDone) {
			outputMsg(lines);
			return null;
		}

		return lines;
	}

	private function outputMsg(msg:Any):Void {
		GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, msg));
	}

	private function clearOutput():Void {
		GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_CLEAR, null, true));
	}
}