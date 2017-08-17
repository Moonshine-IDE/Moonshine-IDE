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
	import flash.geom.Point;
	import flash.xml.XMLNode;
	
	public class TextUtil
	{
		private static const NON_WORD_CHARACTERS:Vector.<String> = new <String>[" ", "\t", ".", ":", ";", ",", "?", "+", "-", "*", "/", "%", "=", "!", "&", "|", "(", ")", "[", "]", "{", "}", "<", ">"];

		public static function startOfWord(line:String, charIndex:int):int
		{
			var startChar:int = 0;
			for(var i:int = charIndex - 1; i >= 0; i--)
			{
				var char:String = line.charAt(i);
				if(NON_WORD_CHARACTERS.indexOf(char) !== -1)
				{
					//include the next character, but not this
					//one, because it's not part of the word
					startChar = i + 1;
					break;
				}
			}
			return startChar;
		}

		public static function endOfWord(line:String, charIndex:int):int
		{
			var endChar:int = line.length;
			for(var i:int = charIndex + 1; i < endChar; i++)
			{
				var char:String = line.charAt(i);
				if(NON_WORD_CHARACTERS.indexOf(char) !== -1)
				{
					endChar = i;
					break;
				}
			}
			return endChar;
			
		}
		
		// Find word boundary from the beginning of the line
		public static function wordBoundaryForward(line:String):int
		{
			return line.length - line.replace(/^(?:\s+|[^\s,(){}\[\]\-+*%\/="'~!&|<>?:;.]+\s*|[,(){}\[\]\-+*%\/="'~!&|<>?:;.]+\s*)/,"").length; 
		}
		
		// Find word boundary from the end of the line
		public static function wordBoundaryBackward(line:String):int
		{
			return line.length - line.replace(/(?:\s+|[^\s,(){}\[\]\-+*%\/="'~!&|<>?:;.]+\s*|[,(){}\[\]\-+*%\/="'~!&|<>?:;.]+\s*)$/,"").length; 
		}
		
		// Get amount of indentation on line
		public static function indentAmount(line:String):int
		{
			return Math.max(0, line.length - line.replace(/^\t+/,"").length);
		}
		
		// Count digits in decimal number
		public static function digitCount(num:int):int
		{
			return Math.floor(Math.log(num)/Math.log(10))+1;
		}
		
		// Escape a string so it can be fed into a new RegExp
		public static function escapeRegex(str:String):String {
			return str.replace(/[\$\(\)\*\+\.\[\]\?\\\^\{\}\|]/g,"\\$&");
		}
		
		// Repeats a string N times
		public static function repeatStr(str:String, count:uint):String {
			return new Array(count+1).join(str);
		}
		
		// Pad a string to 'len' length with 'char' characters
		public static function padLeft(str:String, len:uint, char:String = "0"):String {
			return repeatStr(char, len - str.length) + str;
		}
		
		// Return lineIdx/charIdx from charIdx
		public static function charIdx2LineCharIdx(str:String, charIdx:int, lineDelim:String):Point
		{
			var line:int = str.substr(0,charIdx).split(lineDelim).length - 1;
			var chr:int = line > 0 ? charIdx - str.lastIndexOf(lineDelim, charIdx - 1) - lineDelim.length : charIdx;
        	return new Point(line, chr);
		} 
		
		// Return charIdx from lineIdx/charIdx
		public static function lineCharIdx2charIdx(str:String, lineIdx:int, charIdx:int, lineDelim:String):int
		{
			return (
				str.split(lineDelim).slice(0,lineIdx).join("").length	// Predecing lines' lengths
				+ lineIdx * lineDelim.length							// Preceding delimiters' lengths
				+ charIdx												// Current line's length
			);
		}
		
		public static function htmlUnescape(str:String):String
		{
    		return new XML(str).firstChild.nodeValue;
		}
		
		public static function htmlEscape(str:String):String
		{
    		return new XMLNode( 3, str ).toString();
		}

	}
}