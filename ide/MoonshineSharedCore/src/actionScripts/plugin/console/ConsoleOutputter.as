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
package actionScripts.plugin.console
{
	import flash.events.EventDispatcher;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.ui.editor.text.TextLineModel;
	import actionScripts.utils.HtmlFormatter;
	
	import no.doomsday.console.ConsoleUtil;
	
	public class ConsoleOutputter extends EventDispatcher
	{
		public static var DEBUG:Boolean = true;
		
		protected static var _name:String = "";
		public function get name():String
		{
			return _name;
		}
		
		// Console output functions, use %s for substitution
		protected function notice(str:String, ...replacements):void
		{
			formatOutput(HtmlFormatter.sprintfa(str, replacements), 'notice');
		}
		
		protected function error(str:String, ...replacements):void
		{
			formatOutput(HtmlFormatter.sprintfa(str, replacements), 'error');
		}
		
		protected function warning(str:String, ...replacements):void
		{
			formatOutput(HtmlFormatter.sprintfa(str, replacements), 'warning');
		}
		
		protected function print(str:String, ...replacements):void 
		{
			ConsoleUtil.print(str);
			formatOutput(HtmlFormatter.sprintfa(str, replacements), 'weak');
		}
		
		protected function debug(str:String, ...replacements):void
		{
			if(DEBUG)
			{
				formatOutput(HtmlFormatter.sprintfa(str, replacements), 'weak');
			}
		}
		
		
		public static function formatOutput(str:String, style:String):void
		{
			var textLines:Array =  str.split("\n");
			var lines:Vector.<TextLineModel> = Vector.<TextLineModel>([]);
			for (var i:int = 0; i < textLines.length; i++)
			{
				if (textLines[i] == "") continue;
				var text:String = HtmlFormatter.sprintf("<%x>%x:</%x> %x", style, _name, style, textLines[i]); 
				var lineModel:TextLineModel = new MarkupTextLineModel(text);
				lines.push(lineModel);
			}
			outputMsg(lines);
		}
		
		protected static function outputMsg(msg:*):void 
		{
			GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleOutputEvent(msg));
		}
		
		protected function clearOutput():void 
		{
			GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleOutputEvent("clearCommand", true));
		}

	}
}