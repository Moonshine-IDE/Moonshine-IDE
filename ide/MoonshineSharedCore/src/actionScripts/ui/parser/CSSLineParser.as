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
package actionScripts.ui.parser
{
	import actionScripts.ui.parser.context.ContextSwitch;
	import actionScripts.ui.parser.context.ContextSwitchManager;
	import actionScripts.ui.parser.context.ContextSwitchParser;

	public class CSSLineParser extends ContextSwitchParser implements ILineParser
	{
		public static const CSS_TEXT:int =			0x0;
		public static const CSS_PROPERTY:int =		0x1;
		public static const CSS_VALUE:int =			0x2;
		public static const CSS_STRING1:int =		0x3;
		public static const CSS_STRING2:int =		0x4;
		public static const CSS_STRING3:int =		0x5;
		public static const CSS_STRING4:int =		0x6;
		public static const CSS_COMMENT1:int =		0x7;
		public static const CSS_COMMENT2:int =		0x8;
		public static const CSS_COMMENT3:int =		0x9;
		public static const CSS_MEDIA:int =			0xA;
		public static const CSS_BRACEOPEN:int =		0xB;
		public static const CSS_BRACECLOSE:int =	0xC;
		public static const CSS_COLON1:int =		0xD;
		public static const CSS_COLON2:int =		0xE;
		public static const CSS_COLON3:int =		0xF;

		public function CSSLineParser():void
		{
			super();
			
			defaultContext = CSS_TEXT;
			
			// Context switches, order matters
			switchManager = new ContextSwitchManager(
				Vector.<ContextSwitch>([
					// Comments
					new ContextSwitch(Vector.<int>([CSS_TEXT]),CSS_COMMENT1,/\/\*/),
					new ContextSwitch(Vector.<int>([CSS_COMMENT1]),CSS_TEXT,/\*\//, true),
					new ContextSwitch(Vector.<int>([CSS_PROPERTY]),CSS_COMMENT2,/\/\*/),
					new ContextSwitch(Vector.<int>([CSS_COMMENT2]),CSS_PROPERTY,/\*\//, true),
					new ContextSwitch(Vector.<int>([CSS_VALUE]),CSS_COMMENT3,/\/\*/),
					new ContextSwitch(Vector.<int>([CSS_COMMENT3]),CSS_VALUE,/\*\//, true),
					// Media rules
					new ContextSwitch(Vector.<int>([CSS_TEXT]),CSS_MEDIA,/@media(?=[;{\s])/, true),
					new ContextSwitch(Vector.<int>([CSS_MEDIA]),CSS_TEXT,/[{\r\n]/),
					// Semi-colons
					new ContextSwitch(Vector.<int>([CSS_TEXT, CSS_MEDIA]),CSS_COLON1,/;/),
					new ContextSwitch(Vector.<int>([CSS_COLON1]),CSS_TEXT),
					// Selectors
					new ContextSwitch(Vector.<int>([CSS_TEXT]),CSS_BRACEOPEN,/\{/),
					new ContextSwitch(Vector.<int>([CSS_BRACEOPEN]),CSS_PROPERTY),
					new ContextSwitch(Vector.<int>([CSS_PROPERTY,CSS_VALUE]),CSS_BRACECLOSE,/\}/),
					new ContextSwitch(Vector.<int>([CSS_BRACECLOSE]),CSS_TEXT,/(?=.)/),
					// Values
					new ContextSwitch(Vector.<int>([CSS_PROPERTY]),CSS_COLON2,/:/),
					new ContextSwitch(Vector.<int>([CSS_COLON2]),CSS_VALUE),
					new ContextSwitch(Vector.<int>([CSS_VALUE]),CSS_PROPERTY,/[\r\n]/),
					new ContextSwitch(Vector.<int>([CSS_VALUE]),CSS_COLON3,/;/),
					new ContextSwitch(Vector.<int>([CSS_COLON3]),CSS_PROPERTY),
					// Strings
					new ContextSwitch(Vector.<int>([CSS_TEXT]),CSS_STRING1,/"/),
					new ContextSwitch(Vector.<int>([CSS_TEXT]),CSS_STRING2,/'/),
					new ContextSwitch(Vector.<int>([CSS_STRING1]),CSS_STRING1,/\\["\r\n]/),
					new ContextSwitch(Vector.<int>([CSS_STRING2]),CSS_STRING2,/\\['\r\n]/),
					new ContextSwitch(Vector.<int>([CSS_STRING1]),CSS_TEXT,/"|(?=[\r\n])/,true),
					new ContextSwitch(Vector.<int>([CSS_STRING2]),CSS_TEXT,/'|(?=[\r\n])/,true),
					new ContextSwitch(Vector.<int>([CSS_VALUE]),CSS_STRING3,/"/),
					new ContextSwitch(Vector.<int>([CSS_VALUE]),CSS_STRING4,/'/),
					new ContextSwitch(Vector.<int>([CSS_STRING3]),CSS_STRING3,/\\["\r\n]/),
					new ContextSwitch(Vector.<int>([CSS_STRING4]),CSS_STRING4,/\\['\r\n]/),
					new ContextSwitch(Vector.<int>([CSS_STRING3]),CSS_VALUE,/"|(?=[\r\n])/,true),
					new ContextSwitch(Vector.<int>([CSS_STRING4]),CSS_VALUE,/'|(?=[\r\n])/,true)
				])
			);
		}
	}
}