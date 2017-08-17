/*
	See COPYRIGHT.txt in this directory for full copyright text.
	
	Pretty resumable parser
	Inspired by Google Code Prettify
	Which was ported by Anirudh Sasikumar to AS3

   	Modified and simplified to be able to handle on-the-fly changes,
	by parsing one line at a time, which can be spread out over multiple frames
	as to emulate threading in a Flash runtime.
	
	You need to populate wordBoundaries, patterns, endPatterns & keywords.
	See AS3LineParser for an example	
*/

package actionScripts.ui.parser
{
	import flash.events.EventDispatcher;

	public class LineParser extends EventDispatcher implements ILineParser
	{
		protected var wordBoundaries:RegExp;
		
		protected var patterns:Array;
		protected var endPatterns:Array;
		protected var keywords:Array;
		
		// Generated based on keywords array		
		protected var keywordSet:Object = {};
		
		// Will start assuming this context						
		protected var context:int = 0x1;
		// If nothing is found this context is set
		protected var defaultContext:int = 0x1;
		protected var result:Vector.<int>;

		public function LineParser():void
		{
			for (var i:int = 0; i < keywords.length; i++) 
			{
				var k:Array = keywords[i];
				for (var j:int = 0; j < k[1].length; j++)
				{ 
					keywordSet[ k[1][j] ] = k[0];
				}
			}
			
		}

		public function setContext(newContext:int):void
		{
			context = newContext; 
		}

		public function parse(sourceCode:String):Vector.<int>
		{
			result = new Vector.<int>();
			
			for (var i:int = 0; i < endPatterns.length; i++)
			{
				if (endPatterns[i][0] == context)
				{
					result.push(0, context);
					findContextEnd(sourceCode, endPatterns[i][1]);
					
					break;
				}
			}
			
			if (result.length == 0)
			{
				splitOnContext(sourceCode.toString());
			}
			
			context = result[result.length-1];
			
			return result;
		}
		
		protected function findContextEnd(source:String, endPattern:RegExp):void
		{
			var endMatch:Object = endPattern.exec(source);
			
			if (endMatch)
			{
				var matchLen:int = endMatch[0].length;
				
				splitOnContext(source.substring(endMatch.index + matchLen), endMatch.index + matchLen);
			}
		}
		
		/*
			Takes string of source code, assigns styles to this.result.
			Dives instantly when pattern is found, unlike Prettify,
			which nests decoration/result array & then runs over it again.
		*/
		protected function splitOnContext(tail:String, pos:int=0):void
		{
			var style:int = 0;
			
			var lastStyle:int = 0;
			var head:String = "";
			
			// NOTE: for longer strings this could be a for loop & could break & be returned to,
			// as to make the parsing fully psuedo-threaded.
			while (tail.length)
			{
				var match:Array;
				var token:int = 0;
				
				for (var i:int = 0; i < patterns.length; i++)
				{
					match = tail.match(patterns[i][1]);
					if (match)
					{
						token = match[0].length;
						lastStyle = style;
						style = patterns[i][0];
						break;
					}
				}
				if (token == 0)
				{
					token = 1;
					head += tail.charAt(0);
					lastStyle = style;
					style = defaultContext;
				} 
				else if (style != lastStyle && lastStyle == defaultContext)
				{
					// Decorations are set to this.result instantly by this function
					splitOnKeywords(head, pos-head.length); 
					head = "";
				}
				
				if (style != lastStyle && !head.length)
				{ 
					result.push(pos, style);
				}
				
				pos += token;
				tail = tail.substring(token);
			}
			
			// If head exists it means last matched token was unknown (defaultContext),
			// so we see if it contains keywords. 
			if (head.length) {
				splitOnKeywords(head, pos-head.length);
			}
		}
		
			
		
		protected function splitOnKeywords(source:String, pos:int):void
		{
			var m:Array = source.split(wordBoundaries);
			var s:String;
			var style:int;
			var lastStyle:int;
			for (var i:int = 0; i < m.length; i++) {
				s = m[i];
				lastStyle = style;
				if (keywordSet.hasOwnProperty(s))
				{
					style = keywordSet[s];
				}
				else if (!/^\s+$/.test(s)) { // Avoid switching styles for whitespace
					style = defaultContext;
				}
				
				if (style != lastStyle) {
					result.push(pos, style);
				}
				pos += s.length;
			}
		}

	}
}