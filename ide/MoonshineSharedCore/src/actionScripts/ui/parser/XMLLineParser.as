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
	import actionScripts.ui.parser.ILineParser;
	import actionScripts.ui.parser.context.ContextSwitch;
	import actionScripts.ui.parser.context.ContextSwitchManager;
	import actionScripts.ui.parser.context.ContextSwitchParser;
	
	public class XMLLineParser extends ContextSwitchParser implements ILineParser
	{
		public static const XML_TEXT:int =			0x0;
		public static const XML_TAG:int =			0x1;
		public static const XML_COMMENT:int =		0x2;
		public static const XML_CDATA:int =			0x3;
		public static const XML_ATTR_NAME:int =		0x4;
		public static const XML_ATTR_VAL1:int =		0x5;
		public static const XML_ATTR_VAL2:int =		0x6;
		public static const XML_ATTR_OPER:int =		0x7;
		public static const XML_BACKETOPEN:int =	0x8;
		public static const XML_BACKETCLOSE:int =	0x9;

		public function XMLLineParser():void
		{
			super();
			
			defaultContext = XML_TEXT;
			
			// Context switches, order matters
			switchManager = new ContextSwitchManager(
				Vector.<ContextSwitch>([
					// Comments
					new ContextSwitch(Vector.<int>([XML_TEXT]),XML_COMMENT,/<!--/),
					new ContextSwitch(Vector.<int>([XML_COMMENT]),XML_TEXT,/-->/, true),
					// CDATA Sections
					new ContextSwitch(Vector.<int>([XML_TEXT]),XML_CDATA,/<!\[CDATA\[/),
					new ContextSwitch(Vector.<int>([XML_CDATA]),XML_TEXT,/\]\]>/, true),
					// Tags
					new ContextSwitch(Vector.<int>([XML_TEXT]),XML_BACKETOPEN,/</),
					new ContextSwitch(Vector.<int>([XML_BACKETOPEN]),XML_TAG,/[^\x00-\x39\x3B-\x40\x5B-\x5E\x60\x7B-\xBF\xD7\xF7][^\x00-\x2C\x2F\x3B-\x40\x5B-\x5E\x60\x7B-\xB6\xB8-\xBF\xD7\xF7]*/),
					new ContextSwitch(Vector.<int>([XML_TAG]),XML_BACKETCLOSE,/>/),
					new ContextSwitch(Vector.<int>([XML_BACKETCLOSE]),XML_TEXT),
					// Attributes
					new ContextSwitch(Vector.<int>([XML_TAG]),XML_ATTR_NAME,/[^\x00-\x39\x3B-\x40\x5B-\x5E\x60\x7B-\xBF\xD7\xF7]+/),
					new ContextSwitch(Vector.<int>([XML_TAG,XML_ATTR_NAME]),XML_ATTR_OPER,/[\x00-\x21\x23-\x26\x28-\x2C\x2F\x3B-\x3D\x3F\x40\x5B-\x5E\x60\x7B-\xB6\xB8-\xBF\xD7\xF7]+/),
					new ContextSwitch(Vector.<int>([XML_ATTR_NAME,XML_ATTR_OPER]),XML_TAG),
					new ContextSwitch(Vector.<int>([XML_TAG]),XML_ATTR_VAL1,/"/),
					new ContextSwitch(Vector.<int>([XML_TAG]),XML_ATTR_VAL2,/'/),
					new ContextSwitch(Vector.<int>([XML_ATTR_VAL1]),XML_TAG,/"/, true),
					new ContextSwitch(Vector.<int>([XML_ATTR_VAL2]),XML_TAG,/'/, true)
				])
			);
		}
	}
}