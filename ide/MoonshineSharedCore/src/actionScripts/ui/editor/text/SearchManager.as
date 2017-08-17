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
	import flash.geom.Point;
	
	import actionScripts.events.ChangeEvent;
	import actionScripts.ui.editor.text.change.TextChangeBase;
	import actionScripts.ui.editor.text.change.TextChangeInsert;
	import actionScripts.ui.editor.text.change.TextChangeMulti;
	import actionScripts.ui.editor.text.change.TextChangeRemove;
	import actionScripts.ui.editor.text.vo.SearchResult;
	import actionScripts.utils.TextUtil;
	
	public class SearchManager
	{
		private var model:TextEditorModel;
		private var editor:TextEditor;
		
		public function SearchManager(editor:TextEditor, model:TextEditorModel)
		{
			this.editor = editor;
			this.model = model;
		}		

		public function search(search:*, replace:String, all:Boolean=false, backwards:Boolean=false):SearchResult
		{
			// Get string once (it's built dynamically)
			var str:String = editor.dataProvider;
			
			// Starting point for search
			var startLine:int = model.selectedLineIndex;
			var startChar:int = model.caretIndex;
			
			// When going backwards, start at the left edge of the selection
			if (backwards && model.hasSelection)
			{
				startLine = model.getSelectionLineStart();
				startChar = model.getSelectionCharStart();
			}
			
			// Map to '1-d space'
			var startCharIndex:int = TextUtil.lineCharIdx2charIdx(
						str, 
						startLine, 
						startChar, 
						editor.lineDelim);
			
			var result:int = -1;
			var results:Array = [];
			var wrapped:Boolean;
			var match:Object;
			var selectedIndex:int;
			
			
			// Search with regexp
			if (search is RegExp)
			{
				// Find first occurance
				match = search.exec(str);
				
				// Find other occurances 
	         	while (match != null) 
	         	{
					if(match.toString())// match return infinite string for somekind of regexp like /L*/ /?*/
					{
						results.push(match);
						match = search.exec(str);
					}
					else
					{
						match = null;
						break;
					}
	         	}
	         	
	         	// Figure out which one we want to select
	         	var resultLength:int = results.length;
	         	if (backwards)
	         	{
	         		for (var i:int = resultLength-1; i >= 0; i--)
					{
						if (results[i].index < startCharIndex)
						{
							result = results[i].index;
							match = results[i];
							selectedIndex = i;
							break;	
						}
					}
	         	}
	         	else
	         	{
	         		for (i = 0; i < resultLength; i++)
					{
						if (results[i].index > startCharIndex)
						{
							result = results[i].index;
							match = results[i];
							selectedIndex = i;
							break;	
						}
					}
	         	}
				
				// No match, wrap search
				if (result == -1 && results.length)
				{
					if (backwards)
					{
						selectedIndex = results.length-1;
						match = results[selectedIndex];
						result = match.index;
					}
					else 
					{
						selectedIndex = 0;
						match = results[selectedIndex];
						result = match.index;
					}
					wrapped = true;
				}
			}
			else // Search is string
			{
				// Find first occurance
				var current:int = str.indexOf(search);
				
				// Find other occurances
				while(current != -1)
				{
					results.push(current);
					current = str.indexOf(search, current+1);
				}
				
				// Figure out which one we want to select
				resultLength = results.length;
				if (backwards)
	         	{
	         		for (i = resultLength-1; i >= 0; i--)
					{
						if (results[i] < startCharIndex)
						{
							result = results[i];
							selectedIndex = i;
							break;	
						}
					}
	         	}
	         	else
	         	{
	         		for (i = 0; i < resultLength; i++)
					{
						if (results[i] >= startCharIndex)
						{
							result = results[i];
							selectedIndex = i;
							break;	
						}
					}
	         	}
				
				// No match, wrap search
				if (result == -1 && results.length)
				{
					if (backwards) 
					{
						selectedIndex = results.length-1;
						result = results[selectedIndex];
					}
					else
					{ 
						selectedIndex = 0;
						result = results[selectedIndex];
					}
					wrapped = true;
				}
			}
			
			var res:SearchResult = new SearchResult();

			if (result != -1 && replace != null)
			{
				res = this.replace(str, search, replace, results, all);
				applySearch(res);
				return res;
			}
			
			
			// Did we find anything?
			if (result != -1)
			{
				var lc:Point = TextUtil.charIdx2LineCharIdx(str, result, editor.lineDelim);
				res.startLineIndex = lc.x;
				res.endLineIndex = lc.x;
				
				res.startCharIndex = lc.y;
				if (search is RegExp)
				{
					res.endCharIndex = lc.y + match[0].length;
				}
				else
				{
					res.endCharIndex = lc.y + search.length;
				}

				res.didWrap = wrapped;
				res.totalMatches = results.length;
				
				res.selectedIndex = selectedIndex;
	
				// Display
				applySearch(res);
			}
			
			return res; 
		}
		
		private function replace(str:String, search:*, replace:String, results:Array, all:Boolean):SearchResult
		{
			var regexp:Boolean = search is RegExp;
			
			// Get leftmost selection edge, so we can replace something that's selected
			var startLine:int = model.getSelectionLineStart();
			var startChar:int = model.getSelectionCharStart();
			
			var startCharIndex:int = TextUtil.lineCharIdx2charIdx(
						str, 
						startLine, 
						startChar, 
						editor.lineDelim);
			
			// Build search results
			var res:SearchResult = new SearchResult();
			res.totalMatches = results.length;
			res.selectedIndex = res.totalMatches-1;
			
			var result:int;
			var removeText:TextChangeRemove;
			var addText:TextChangeInsert;
			var changes:Vector.<TextChangeBase> = Vector.<TextChangeBase>([]);
			var match:Object;
			
			// Replace all
			if (all)
			{
				var lastLineIndex:int = -1;
				var replaceLengthDiff:int;
				// Loop over all results and replace
				for (var i:int = 0; i < results.length; i++)
				{
					if (regexp)
					{
						match = results[i];
						result = match.index;
					}
					else
					{
						result = results[i];	
					}
					
					var lc:Point = TextUtil.charIdx2LineCharIdx(str, result, editor.lineDelim);
				
					var lineIndex:int = lc.x;
					startCharIndex = lc.y;
					var endCharIndex:int;
					
					if (search is RegExp)
					{
						endCharIndex = lc.y + match[0].length;
					}
					else
					{
						endCharIndex = lc.y + search.length;
					}
					
					
					// For new lines we have no length diff
					if (lastLineIndex != lineIndex)
					{	
						replaceLengthDiff = 0;	
					}

					// Create text change events so we can undo/redo
					removeText = new TextChangeRemove(lineIndex, 
													  startCharIndex-replaceLengthDiff, 
													  lineIndex, 
													  endCharIndex-replaceLengthDiff);
													  
					addText = new TextChangeInsert(lineIndex, 
												   startCharIndex-replaceLengthDiff, 
												   Vector.<String>([replace]));
					
					changes.push(removeText);
					changes.push(addText);
					
					lastLineIndex = lineIndex;
					
					// For multiple replaces on the same line
					//  we need to track changes in search/replace length to offset
					replaceLengthDiff += (endCharIndex-startCharIndex)-replace.length;
				}
				
				// Remove last adjustment, it's only for trailing adjustments
				//  which we have none in this context			
				replaceLengthDiff -= (endCharIndex-startCharIndex)-replace.length;
				// Apply diff (if any) so the new selection is the replace string
				startCharIndex -= replaceLengthDiff;
				
				// Since we replaced everything we shouldn't have any new matches
				res.totalReplaces = res.totalMatches;
				res.totalMatches = 0;
				
				// Dispatch change event
				var multiEvent:TextChangeMulti = new TextChangeMulti(changes);
				editor.dispatchEvent(new ChangeEvent(ChangeEvent.TEXT_CHANGE, multiEvent));
			}
			else
			{
				// Find item to replace
				for (i = 0; i < results.length; i++)
				{
					if (regexp)
					{
						if (results[i].index >= startCharIndex)
						{
							match = results[i];
							result = match.index;
							res.selectedIndex = i;
							break;
						}
					}
					else
					{
						if (results[i] >= startCharIndex)
						{
							result = results[i];
							res.selectedIndex = i;
							break;
						}	
					}
				}
				
				// Map to 2D
				lc = TextUtil.charIdx2LineCharIdx(str, result, editor.lineDelim);
				lineIndex = lc.x; 
				startCharIndex = lc.y;
				
				if (search is RegExp)
				{
					endCharIndex = lc.y + match[0].length;
				}
				else
				{
					endCharIndex = lc.y + search.length;
				}
				
				// Create text change events
				removeText = new TextChangeRemove(lineIndex, startCharIndex, lineIndex, endCharIndex);
				addText = new TextChangeInsert(lineIndex, startCharIndex, Vector.<String>([replace]));
				
				// Wrap in one undo step
				multiEvent = new TextChangeMulti(removeText, addText);
				
				// Apply
				editor.dispatchEvent(new ChangeEvent(ChangeEvent.TEXT_CHANGE, multiEvent));
				
				// We replaced one
				res.totalMatches -= 1;
				res.totalReplaces = 1;
			}
			
			res.startLineIndex = res.endLineIndex = lineIndex;
			res.startCharIndex = startCharIndex;
			res.endCharIndex = startCharIndex+replace.length;
			
			return res;
		} 
		
		// Map to TextEditor internal representation
		private function applySearch(s:SearchResult):void
		{	
			var firstLine:TextLineModel = model.lines[s.startLineIndex];
			var endLine:TextLineModel = model.lines[s.endLineIndex];
			
			model.setSelection(s.startLineIndex, s.startCharIndex, s.endLineIndex, s.endCharIndex);			
			
			// TODO: Have a bit more margin, maybe center the selected textline?	
			editor.scrollViewIfNeeded();
			editor.invalidateLines();
		}

	}
}