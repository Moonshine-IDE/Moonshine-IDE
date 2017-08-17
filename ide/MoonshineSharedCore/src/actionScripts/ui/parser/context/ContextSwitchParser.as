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
	import flash.events.EventDispatcher;
	
	import actionScripts.ui.parser.ILineParser;

	public class ContextSwitchParser extends EventDispatcher implements ILineParser
	{
		protected var context:int = 0;
		public var switchManager:ContextSwitchManager;
		public var parserManager:InlineParserManager;
		
		protected var defaultContext:int = 0;

		public function ContextSwitchParser():void
		{
			super();
		}

		public function setContext(newContext:int):void
		{
			context = newContext; 
		}

		public function parse(sourceCode:String):Vector.<int>
		{
			var result:Vector.<int> = new Vector.<int>();
			var tail:String = sourceCode;
			var pos:int = 0;
			var curContext:int;
			var curParser:InlineParser;
			
			if (switchManager) while (tail.length)
			{
				var firstMatch:Object = null;
				
				// Skip whitespace, no point in coloring it
				var whiteSpace:Object = /^\s+/.exec(tail);
				if (whiteSpace)
				{
					var whiteSpaceLen:int = whiteSpace[0].length;
					
					if (whiteSpaceLen == tail.length) break;
					
					pos += whiteSpaceLen;
					tail = sourceCode.substr(pos);
				}
				
				// Get current context, transposing to inline parser mask if available
				curContext = context || defaultContext;
				if (parserManager)
				{
					curParser = parserManager.getParser(curContext);
					if (curParser) curContext = curParser.contextMask;
				}
				
				// Get switches for current context
				var curSwitches:Vector.<ContextSwitch> = switchManager.getSwitches(curContext);
				
				// Search for the first matching switch
				if (curSwitches) for each (var swtch:ContextSwitch in curSwitches)
				{
					if (swtch.pattern != null)
					{
						var match:Object = swtch.pattern.exec(tail);
						
						if (match)
						{
							if (!firstMatch || match.index < firstMatch.index)
							{
								firstMatch = {
									swtch:swtch,
									index:match.index,
									length:match[0].length
								};
							}
						}
					}
					else
					{
						firstMatch = {
							swtch:swtch,
							index:0,
							length:0
						};
					}
					
					// Break early if matched at 0 (no point to keep processing, this is the earliest possible match)
					if (firstMatch && firstMatch.index==0) break;
				}
				
				// Apply the context switch, if one is found
				if (firstMatch)
				{
					var firstSwitch:ContextSwitch = firstMatch.swtch;
					var matchPos:int = firstMatch.index;
					var matchLen:int = firstMatch.length;
					var contextPos:int = pos + matchPos + (firstSwitch.post ? matchLen : 0);
					
					if (result.length == 0 && contextPos > 0) result.push(0, context || defaultContext);
					context = firstSwitch.to;
					// Avoid redundant context switches
					if (result.length > 0 && result[result.length-1] != context)
					{
						if (result[result.length-2] == contextPos) result[result.length-1] = context;
						else result.push(contextPos, context);
					}
					
					pos += matchPos + matchLen;
					tail = sourceCode.substr(pos);
				}
				else break;
			}
			
			if (result.length == 0) result.push(0, context || defaultContext);
			
			// Process inline contexts through inline parsers
			if (parserManager) for (var i:int = result.length-1; i > 0; i -= 2)
			{
				curContext = result[i];
				curParser = parserManager.getParser(curContext);
				
				if (curParser)
				{
					var inlinePos:int = result[i-1];
					var inlineResult:Vector.<int>;
					var inlineMask:int = curParser.contextMask;
					var inlineCutoff:int = i < result.length-1 ? result[i+1] : -1;
					
					tail = sourceCode.slice(inlinePos, inlineCutoff)+"\n";
					
					curParser.parser.setContext(curContext & ~inlineMask);
					inlineResult = curParser.parser.parse(tail);
					
					// Remove old results
					result.splice(i-1, 2);
					// Inject AS parser results, applying offsets and mask
					for (var n:int = 0; n < inlineResult.length; n += 2)
					{
						pos = inlineResult[n] + inlinePos;
						
						if (inlineCutoff < 0 || pos < inlineCutoff)
						{
							result.splice(i - 1 + n, 0, pos, inlineResult[n+1] | inlineMask);
						}
					}
					
					context = result[result.length-1];
				}
			}
			
			return result;
		}
	}
}