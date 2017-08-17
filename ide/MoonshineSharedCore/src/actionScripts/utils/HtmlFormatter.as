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
package actionScripts.utils
{
	public class HtmlFormatter
	{
		/*
			HTML encode replacements. Use %s for substitution.
		*/
		public static function sprintf(str:String, ...replacements):String
		{
			// TODO: Use the sprintf lib that is on google code instead? (MIT)
			var repl:int = 0;
			
			return str.replace(
				/%[%sxd]/g,
				function ():String {
					var token:String = arguments[0];
					switch (token) {
						case "%x":
							return repl < replacements.length ? TextUtil.htmlEscape(replacements[repl++]) : "";
						case "%s":
							return repl < replacements.length ? replacements[repl++] : "";
						case "%d":
							return repl < replacements.length ? Number(replacements[repl++]).toString() : "";
						default:
							return "%";
					}
				}
			);
		}
		
		// sprintf shorthand to remove ... syntaxing
		public static function sprintfa(str:String, replacements:Array):String
		{
			if (!replacements) return str;
			
			replacements.unshift(str);	
			return sprintf.apply(HtmlFormatter, replacements);
		}

	}
}