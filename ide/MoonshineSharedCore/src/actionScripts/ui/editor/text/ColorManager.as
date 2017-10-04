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
package actionScripts.ui.editor.text
{
	import flash.events.Event;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.utils.getTimer;
	
	import actionScripts.events.ChangeEvent;
	import actionScripts.events.LineEvent;
	import actionScripts.ui.editor.text.change.TextChangeBase;
	import actionScripts.ui.editor.text.change.TextChangeInsert;
	import actionScripts.ui.editor.text.change.TextChangeMulti;
	import actionScripts.ui.editor.text.change.TextChangeRemove;
	import actionScripts.ui.parser.ILineParser;
	import actionScripts.valueObjects.Settings;
	
	
	public class ColorManager
	{
		private static var charWidthCache:Object = {"\t":7.82666015625*Settings.font.tabWidth};
		
		public static const CHUNK_TIMESPAN:int = 25;
		
		private var parser:ILineParser;
		private var ranges:Vector.<LineRange> = new Vector.<LineRange>();
		private var listening:Boolean = false;
		
		private var textElement:TextElement = new TextElement("",new ElementFormat(Settings.font.defaultFontDescription, 
																Settings.font.defaultFontSize,
																0x0));
		private var textBlock:TextBlock = new TextBlock(textElement);
		
		private var editor:TextEditor;
		private var model:TextEditorModel;
		
		public var styles:Object = { 0: new ElementFormat(Settings.font.defaultFontDescription, 
											Settings.font.defaultFontSize,
											0x0),
									 lineNumber: new ElementFormat(Settings.font.defaultFontDescription, 
											Settings.font.defaultFontSize,
											0x888888),
									 breakPointLineNumber: new ElementFormat(Settings.font.defaultFontDescription,
									 		Settings.font.defaultFontSize,
									 		0xffffff),
									 breakPointBackground: 0xdea5dd,
									 tracingLineColor:0xc6dbae
									};
		
		public function ColorManager(editor:TextEditor, model:TextEditorModel)
		{
			this.editor = editor;
			this.model = model;
			
			editor.addEventListener(ChangeEvent.TEXT_CHANGE, handleChange);
		}
		
		public function setParser(v:ILineParser):void
		{
			parser = v;
		}
		
		public function reset():void
		{
			ranges.length = 0;
			invalidate(0, model.lines.length - 1);
		}
		
		private function invalidate(line:int, addCount:int = 0, silent:Boolean = false):void
		{
			var merged:Boolean = false;
			
			for (var r:int = ranges.length; r--;)
			{
				var range:LineRange = ranges[r];
				
				if (range.end < line)
				{
					break;
				}
				else
				{
					if (range.start > line)
					{
						range.start += addCount;
						range.end += addCount;
					}
					else
					{
						merged = true;
						range.end += addCount;
						break;
					}
				}
			}
			
			if (!merged)
			{
				ranges.splice(r + 1, 0, new LineRange(line, line + addCount));
			}
			
			if (!listening && !silent)
			{
				startListening();
				process();
			}
		}
		
		private function process(event:Event = null):void
		{
			//if (!parser) return;
			
			var count:int = model.lines.length;
			var timeLimit:int = getTimer() + CHUNK_TIMESPAN;
			var lastContext:int = 0;
			
			while (ranges.length)
			{
				var range:LineRange = ranges[0];
				var rangeStart:int = range.start;
				var rangeEnd:int = range.end;
				
				if (parser)
					parser.setContext(rangeStart > 0 ? model.lines[rangeStart - 1].endContext : 0);
				
				for (var i:int = rangeStart; i <= rangeEnd; i++)
				{
					var line:TextLineModel = model.lines[i];
					
					// Calculate line width
					var oldWidth:Number = line.width;					
					line.width = calculateWidth(line.text);
					
					if (oldWidth != line.width)
					{
						editor.dispatchEvent(new LineEvent(LineEvent.WIDTH_CHANGE, i));
					}
					
					
					if (parser)
					{
						// Parse file for coloring
						var oldMeta:Vector.<int> = line.meta;
						var newMeta:Vector.<int> = parser.parse(line.text+"\n");
						
						line.meta = newMeta;
						
						// Notify the editor of change, to invalidate lines if needed
						if (!oldMeta || oldMeta.join() != newMeta.join())
						{
							editor.dispatchEvent(new LineEvent(LineEvent.COLOR_CHANGE, i));
						}
						
						if (i == rangeEnd && i < count - 1)
						{
							// Invalidate next line if its start context doesn't match up with this one's end context
							var nextLine:TextLineModel = model.lines[i + 1];							
							var endContext:int = line.endContext;
							var startContext:int = nextLine.startContext;
							
							if (endContext != startContext)
							{
								invalidate(i + 1);
							}
						}
						
						if (getTimer() > timeLimit)
						{
							if (i == rangeEnd) ranges.splice(0, 1);
							else range.start = i + 1;
							
							return;
						}
					}
				}
				
				ranges.splice(0, 1);
			}
			
			stopListening();
		}
		
		public function calculateWidth(text:String):Number
		{
			var chars:String = "";
			var c:String;
			var i:int;
			var width:Number = 0;
			
			// Collect uncached characters
			for (i = text.length; i--; )
			{
				c = text.charAt(i);
				
				if (!charWidthCache[c])
				{
					chars += c;
					charWidthCache[c] = -1;
				}
			}
			// Measure uncached characters
			if (chars.length > 0)
			{
				var textLine:TextLine;
				
				textElement.text = chars;
				textLine = textBlock.createTextLine()
				for (i = chars.length; i--; )
				{
					c = chars.charAt(i);
					charWidthCache[c] = textLine.getAtomBounds(textLine.getAtomIndexAtCharIndex(i)).width;
				}
			}
			// Calculate line width
			for (i = text.length; i--; )
			{
				width += charWidthCache[text.charAt(i)];
			}
			
			return width;
		}
		
		private function handleChange(event:ChangeEvent):void
		{
			applyChange(event.change);
		}
		
		private function applyChange(change:TextChangeBase, subChange:Boolean = false):void
		{
			if (change is TextChangeInsert) applyChangeInsert(TextChangeInsert(change));
			if (change is TextChangeRemove) applyChangeRemove(TextChangeRemove(change));
			if (change is TextChangeMulti) applyChangeMulti(TextChangeMulti(change));
			
			if (!subChange)
			{
				if (ranges.length == 0)
				{
					stopListening();
				}
				else if (!listening)
				{
					startListening();
					process();
				}
			}
		}
		
		private function applyChangeInsert(change:TextChangeInsert):void
		{
			invalidate(change.startLine, change.textLines.length - 1, true);
		}
		
		private function applyChangeRemove(change:TextChangeRemove):void
		{
			for (var r:int = ranges.length; r--;)
			{
				var range:LineRange = ranges[r];
				
				if (change.startLine > range.end)
				{
					break;
				}
				else
				{
					var lines:int = Math.min(change.endLine, range.end) - change.startLine;
					
					range.start = Math.min(range.start, change.startLine);
					range.end -= lines;
					
					if (range.end < range.start) ranges.splice(r, 1);
				}
			}
			
			if (change.startChar > 0 || change.endChar > 0) invalidate(change.startLine, 0, true);
		}
		
		private function applyChangeMulti(change:TextChangeMulti):void
		{
			for each (var subchange:TextChangeBase in change.changes)
			{
				applyChange(subchange, true);
			}
		}
		
		private function startListening():void
		{
			if (!listening)
			{
				listening = true;
				editor.addEventListener(Event.ENTER_FRAME, process);
			}
		}
		
		private function stopListening():void
		{
			if (listening)
			{
				listening = false;
				editor.removeEventListener(Event.ENTER_FRAME, process);
			}
		}
	}
}

class LineRange
{
	public var start:int;
	public var end:int;
	
	function LineRange(start:int, end:int)
	{
		this.start = start;
		this.end = end;
	}
}