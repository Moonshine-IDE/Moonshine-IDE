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
package actionScripts.ui.parser.context
{
	public class InlineParserManager {
		private var parsers:Object = {};
		
		function InlineParserManager(parsers:Vector.<InlineParser>) {
			for each (var parser:InlineParser in parsers)
			{
				addParser(parser);
			}
		}
		
		public function addParser(parser:InlineParser):void
		{
			parsers[parser.contextMask] = parser;
		}
		
		public function getParser(context:int):InlineParser
		{
			return parsers[context & 0xF000];
		}
	}
}