package actionScripts.plugin.console;

import haxe.Rest;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.plugin.console.ConsoleTextLineModel;
import actionScripts.ui.editor.text.TextLineModel;
import actionScripts.utils.HtmlFormatter;
import no.doomsday.console.ConsoleUtil;
import openfl.Vector;
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
		var lines:Vector<TextLineModel> = new Vector<TextLineModel>([]);
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