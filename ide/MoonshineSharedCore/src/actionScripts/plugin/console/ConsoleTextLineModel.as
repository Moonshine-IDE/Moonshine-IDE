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
	import __AS3__.vec.Vector;
	
	import actionScripts.ui.editor.text.TextLineModel;
	
	public class ConsoleTextLineModel extends TextLineModel
	{
		protected var markupText:String;
		private var consoleOutputType:String;

		public function ConsoleTextLineModel(text:String, consoleOutputType:String)
		{
			this.markupText = text;
			this.consoleOutputType = consoleOutputType;
			
			super( decode(text) );
		}

		public function getTextColor():uint
		{
			var consoleOutType:uint = ConsoleStyle.name2style[consoleOutputType];
			switch(consoleOutType)
			{
				case ConsoleStyle.ERROR:
					return 0xff6666;
					break;
				case ConsoleStyle.WARNING:
					return 0xFFBF0F;
					break;
				case ConsoleStyle.SUCCESS:
					return 0x33cc33;
                    break;
				default:
					return 0xFFFFFF;
					break;
			}
		}

		private function decode(markup:String):String
		{
			var t:String = "";
			var m:Vector.<int> = Vector.<int>([]);
			
			var style2int:Object = ConsoleStyle.name2style;
			
			XML.ignoreWhitespace = false;
			var xml:XML = new XML("<markup>" + markup + "</markup>");
			
			var kids:XMLList = xml.children();
			for each (var node:XML in kids)
			{
				// Add style position
				m[m.length] = t.length;
				
				// Add style value
				if (node.name()  && style2int.hasOwnProperty(node.name()))
				{
					m[m.length] = style2int[node.name().toString().toLowerCase()]; 
				}
				else
				{
					m[m.length] = 0; // Default style
				}
				
				// Build string without markup
				t += node.toString();
			}
			
			meta = m;
			return t;
		}
		
	}
}