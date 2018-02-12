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
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import actionScripts.utils.TextUtil;
	import actionScripts.valueObjects.Settings;
	
	public class TextEditorModel extends EventDispatcher
	{
		private var _selectedLineIndex:int = 0;
		private var _selectedTraceLineIndex:int=0;
		private var _caretIndex:int;
		private var _caretTraceIndex:int;
		
		public var itemRenderersInUse:Vector.<TextLineRenderer> = new Vector.<TextLineRenderer>();
		public var itemRenderersFree:Vector.<TextLineRenderer> = new Vector.<TextLineRenderer>();
		
		public var lines:Vector.<TextLineModel> = new Vector.<TextLineModel>();
		
		// View size
		public var viewWidth:Number = 0;
		public var viewHeight:Number = 0;
		
		// Vertical scrolling, in lines.
		public var scrollPosition:int = 0;
		public var renderersNeeded:int = 0;
		
		// Horizontal scrolling, in pixels.
		public var horizontalScrollPosition:int = 0;
		public var textWidth:Number = 0;
		public var _hasTraceLine:Boolean = false;
		
		public function set selectedLineIndex(idx:int):void
		{
			_selectedLineIndex = idx;
			validateSelection();
		}
		public function get selectedLineIndex():int
		{
			return _selectedLineIndex;
		}
		
		public function set selectedTraceLineIndex(idx:int):void
		{
			_selectedTraceLineIndex = idx;
			validateTraceSelection();
		}
		public function get selectedTraceLineIndex():int
		{
			return _selectedTraceLineIndex;
		}
		
		public function set caretIndex(idx:int):void
		{
			// Get current line indentation
			var indent:int = selectedLine ? TextUtil.indentAmount(selectedLine.text) : 0;
			
			// Store the index with tabs expanded
			_caretIndex = idx + Math.min(indent, idx) * (Settings.font.tabWidth - 1);
			
			validateSelection();
		}
		public function get caretIndex():int
		{
			if (selectedLine)
			{
				// Get current line indentation
				var indent:int = TextUtil.indentAmount(selectedLine.text);
				// Get the index with tabs contracted
				var idx:int = _caretIndex - indent * (Settings.font.tabWidth - 1);
				// If the index falls within the indentation, approximate
				if (idx <= indent) idx = Math.round(_caretIndex / Settings.font.tabWidth);
				
				// Limit the index by the line length
				return Math.min(idx, selectedLine.text.length);
			}
			
			return 0;
		}
		
		public function set caretTraceIndex(idx:int):void
		{
			// Get current line indentation
			var indent:int = selectedTraceLine ? TextUtil.indentAmount(selectedTraceLine.text) : 0;
			
			// Store the index with tabs expanded
			_caretTraceIndex = idx + Math.min(indent, idx) * (Settings.font.tabWidth - 1);
			
			validateTraceSelection();
		}
		public function get caretTraceIndex():int
		{
			if (selectedTraceLine)
			{
				// Get current line indentation
				var indent:int = TextUtil.indentAmount(selectedTraceLine.text);
				// Get the index with tabs contracted
				var idx:int = _caretTraceIndex - indent * (Settings.font.tabWidth - 1);
				// If the index falls within the indentation, approximate
				if (idx <= indent) idx = Math.round(_caretTraceIndex / Settings.font.tabWidth);
				
				// Limit the index by the line length
				return Math.min(idx, selectedTraceLine.text.length);
			}
			
			return 0;
		}
		
		public var selectionStartLineIndex:int = -1;
		public var selectionStartCharIndex:int = -1;
		
		public var selectionStartTraceLineIndex:int=-1;
		public var selectionStartTraceCharIndex:int=-1;
		
		public var allInstancesOfASearchStringDict:Dictionary;
		
		public function get hasMultilineSelection():Boolean
		{
			return selectionStartLineIndex > -1 && selectedLineIndex != selectionStartLineIndex;
		}
		
		public function get hasTraceSelection():Boolean
		{
			return _hasTraceLine;
		}
		public function set hasTraceSelection(v:Boolean):void
		{
			_hasTraceLine = v;
		}
		public function get hasSelection():Boolean
		{
			return selectionStartCharIndex != -1;
		}
		
		public function removeSelection():void
		{
			selectionStartLineIndex = -1;
			selectionStartCharIndex = -1;
		}
		public function removeTraceSelection():void
		{
			selectionStartTraceLineIndex = -1;
			selectionStartTraceCharIndex = -1;
		}
		
		public function getSelectionLineStart():int
		{
			if (hasMultilineSelection)
			{
				return (selectedLineIndex < selectionStartLineIndex) ? selectedLineIndex:selectionStartLineIndex;
			}
			else
			{
				return selectedLineIndex;
			}
		}
		
		public function getSelectionTraceLineStart():int
		{
			return selectedTraceLineIndex;
			
		}
		
		public function getSelectionCharStart():int
		{
			if (hasMultilineSelection)
			{
				return (selectedLineIndex < selectionStartLineIndex) ? caretIndex:selectionStartCharIndex;
			}
			else
			{
				return (caretIndex < selectionStartCharIndex) ? caretIndex:selectionStartCharIndex;
			}
		}
		public function getSelectionTraceCharStart():int
		{
			return (caretTraceIndex < selectionStartTraceCharIndex) ? caretTraceIndex:selectionStartTraceCharIndex;
			
		}
		
		public function getSelectionLineEnd():int
		{
			if (hasMultilineSelection)
			{
				return (selectedLineIndex > selectionStartLineIndex) ? selectedLineIndex:selectionStartLineIndex;
			}
			else
			{
				return selectedLineIndex;
			}
		}
		
		public function getSelectionTraceLineEnd():int
		{
			return selectedTraceLineIndex;
			
		}
		
		public function getSelectionCharEnd():int
		{
			if (hasMultilineSelection)
			{
				return (selectedLineIndex > selectionStartLineIndex) ? caretIndex:selectionStartCharIndex;
			}
			else
			{
				return (caretIndex > selectionStartCharIndex) ? caretIndex:selectionStartCharIndex;
			}
		}
		
		public function getSelectionTraceCharEnd():int
		{
			return (caretTraceIndex > selectionStartTraceCharIndex) ? caretTraceIndex:selectionStartTraceCharIndex;
			
		}
		
		public function setSelection(startLine:int, startChar:int, endLine:int, endChar:int):void
		{
			selectionStartLineIndex = startLine;
			selectionStartCharIndex = startChar;
			_selectedLineIndex = endLine;
			caretIndex = endChar; // This triggers validation
		}
		
		public function setTraceSelection(startLine:int, startChar:int, endLine:int, endChar:int):void
		{
			selectionStartTraceLineIndex = startLine;
			selectionStartTraceCharIndex = startChar;
			_selectedTraceLineIndex = endLine;
			caretTraceIndex = endChar; // This triggers validation
		}
		
		public function get selectedLine():TextLineModel
		{
			return selectedLineIndex >= 0 && selectedLineIndex < lines.length ? lines[selectedLineIndex] : null;
		}
		
		public function get selectedTraceLine():TextLineModel
		{
			return selectedLineIndex >= 0 && selectedTraceLineIndex < lines.length ? lines[selectedTraceLineIndex] : null;
		}
		
		private function validateSelection():void
		{
			if (selectionStartCharIndex == caretIndex && selectionStartLineIndex == selectedLineIndex)
			{
				removeSelection();
			}
		}
		
		private function validateTraceSelection():void
		{
			if (selectionStartTraceCharIndex == caretTraceIndex && selectionStartTraceLineIndex == selectedTraceLineIndex)
			{
				removeTraceSelection();
			}
		}
		
	}
}
