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
package no.doomsday.console.core.commands
{
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ArgumentSplitterUtil
	{
		private static const stringOpener1:int = "'".charCodeAt(0);
		private static const stringOpener2:int = '"'.charCodeAt(0);
		private static const objectOpener:int = "{".charCodeAt(0);
		private static const objectCloser:int = "}".charCodeAt(0);
		private static const arrayOpener:int = "[".charCodeAt(0);
		private static const arrayCloser:int = "]".charCodeAt(0);
		private static const subCommandOpener:int = "(".charCodeAt(0);
		private static const subCommandCloser:int = ")".charCodeAt(0);
		private static const space:int = " ".charCodeAt(0);
		
		public static function slice(a:String):Array {
			var position:int = 0;
			
			while (position < a.length) {
				position++;
				var char:int = a.charCodeAt(position);
				switch(char) {
					case subCommandOpener:
					position = findSubCommand(a, position);
					break;
					case space:
					var sa:String = a.substring(0, position);
					var sb:String = a.substring(position+1);
					var ar:Array = [sa, sb];
					a = ar.join("|");
					break;
					case stringOpener1:
					case stringOpener2:
					position = findString(a, position);
					break;
					case objectOpener:
					position = findObject(a, position);
					break;
					case arrayOpener:
					position = findArray(a, position);
					break;
				}
			}
			var out:Array = a.split("|");
			var str:String = "";
			for (var i:int = 0; i < out.length; i++) 
			{
				str = out[i];
				if (str.charCodeAt(0) == stringOpener1||str.charCodeAt(0) == stringOpener2) {
					out[i] = str.substring(1, str.length - 1);
				}
			}
			return out;
		}
		private static function findSubCommand(input:String,start:int):int {
			var score:int = 0;
			var l:int = input.length;
			var char:int;
			var end:int;
			for (var i:int = start; i < l; i++) 
			{
				char = input.charCodeAt(i);
				if (char == subCommandOpener) {
					score++;
				}else if (char == subCommandCloser) {
					score--;
					if (score <= 0) {
						end = i;
						break;
					}
				}
			}
			if (score > 0) {
				throw(new ArgumentError("Subcommand argument not properly terminated"));
			}
			return end;
		}
		private static function findObject(input:String,start:int):int {
			var score:int = 0;
			var l:int = input.length;
			var char:int;
			var end:int;
			for (var i:int = start; i < l; i++) 
			{
				char = input.charCodeAt(i);
				if (char == objectOpener) {
					score++;
				}else if (char == objectCloser) {
					score--;
					if (score <= 0) {
						end = i;
						break;
					}
				}
			}
			if (score > 0) {
				throw(new ArgumentError("Object argument not properly terminated"));
			}
			return end;
		}
		private static function findArray(input:String, start:int):int {
			var score:int = 0;
			var l:int = input.length;
			var char:int;
			var end:int;
			for (var i:int = start; i < l; i++) 
			{
				char = input.charCodeAt(i);
				if (char == arrayOpener) {
					score++;
				}else if (char == arrayCloser) {
					score--;
					if (score <= 0) {
						end = i;
						break;
					}
				}
			}
			if (score > 0) {
				throw(new ArgumentError("Array argument not properly terminated"));
			}
			return end;
		}
		private static function findString(input:String, start:int):int {
			var out:int = input.indexOf(input.charAt(start), start + 1);
			if (out < start) throw(new ArgumentError("String argument not properly terminated"));
			return out;
		}
		private static function findCommand(input:String):int {
			return input.split(" ").shift().length;
		}
		
	}

}