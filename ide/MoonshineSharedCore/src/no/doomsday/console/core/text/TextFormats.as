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
package no.doomsday.console.core.text 
{
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public final class TextFormats
	{
		public static const debugTformatInput:TextFormat = new TextFormat("_typewriter", 11, 0xFFD900, null, null, null, null, null, null, 0, 0, 0,0);
		public static const debugTformatOld:TextFormat = new TextFormat("_typewriter", 11, 0xBBBBBB, null, null, null, null, null, null, 0, 0, 0, 0);
		public static const debugTformatNew:TextFormat = new TextFormat("_typewriter", 11, 0xFFFFFF, null, null, null, null, null, null, 0, 0, 0, 0);
		public static const debugTformatSystem:TextFormat = new TextFormat("_typewriter", 11, 0x00DD00, null, null, null, null, null, null, 0, 0, 0, 0);
		public static const debugTformatTimeStamp:TextFormat = new TextFormat("_typewriter", 11, 0xAAAAAA, null, null, null, null, null, null, 0, 0, 0, 0);
		public static const debugTformatError:TextFormat = new TextFormat("_typewriter", 11, 0xEE0000, null, null, null, null, null, null, 0, 0, 0, 0);
		public static const debugTformatHelp:TextFormat = new TextFormat("_typewriter", 10, 0xbbbbbb, null, null, null, null, null, null, 0, 0, 0, 0);
		public static const debugTformatTrace:TextFormat = new TextFormat("_typewriter", 11, 0x9CB79B, null, null, null, null, null, null, 0, 0, 0, 0);
		public static const debugTformatEvent:TextFormat = new TextFormat("_typewriter", 11, 0x009900, null, null, null, null, null, null, 0, 0, 0, 0);
		public static const debugTformatWarning:TextFormat = new TextFormat("_typewriter", 11, 0xFFD900, null, null, null, null, null, null, 0, 0, 0, 0);
		
		public static const windowTitleFormat:TextFormat = new TextFormat("_sans", 10, 0xeeeeee, null, null, null, null, null, null, 0, 0, 0, 0);
		public static const windowDefaultFormat:TextFormat = new TextFormat("_sans", 10, 0x111111, null, null, null, null, null, null, 0, 0, 0, 0);
		public function TextFormats() 
		{
		}
		public static function setTheme(input:uint, oldMessage:uint, newMessage:uint, system:uint, timestamp:uint, error:uint, help:uint, trace:uint,event:uint,warning:uint):void {
			debugTformatInput.color = input;
			debugTformatOld.color = oldMessage;
			debugTformatNew.color = newMessage;
			debugTformatSystem.color = system;
			debugTformatTimeStamp.color = timestamp;
			debugTformatError.color = error;
			debugTformatHelp.color = help;
			debugTformatTrace.color = trace;
			
			debugTformatEvent.color = event;
			debugTformatWarning.color = warning;
		}
		/**
		 * Returns a textformat copy with inverted color
		 * @param	tformat
		 * @return
		 */
		public static function getInverse(tformat:TextFormat):TextFormat {
			var newFormat:TextFormat = new TextFormat(tformat.font, tformat.size, tformat.color, tformat.bold, tformat.italic, tformat.underline, tformat.url, tformat.target, tformat.align, tformat.leftMargin, tformat.rightMargin, tformat.indent, tformat.leading);
			newFormat.color = 0xFFFFFF - uint(tformat.color);
			return newFormat;
		}
		
	}

}