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
	import flash.events.KeyboardEvent;
	
	import actionScripts.events.ChangeEvent;
	import actionScripts.ui.editor.text.change.TextChangeBase;
	import actionScripts.ui.editor.text.change.TextChangeInsert;
	
	public class UndoManager
	{
		private var editor:TextEditor;
		private var model:TextEditorModel;
		
		private var history:Vector.<TextChangeBase> = new Vector.<TextChangeBase>();
		private var future:Vector.<TextChangeBase> = new Vector.<TextChangeBase>();
		
		private var savedAt:int = 0;
		
		public function get hasChanged():Boolean
		{
			// Uses history.length to figure out if file is changed
			return (savedAt != history.length); 	
		}
		
		public function UndoManager(editor:TextEditor, model:TextEditorModel)
		{
			this.editor = editor;
			this.model = model;
			
			editor.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			editor.addEventListener(ChangeEvent.TEXT_CHANGE, handleChange);
		}
		
		public function save():void
		{
			savedAt = history.length;
		}
		
		public function undo():void
		{
			if (history.length > 0)
			{
				var change:TextChangeBase = history.pop();
				future.push(change);
				
				// Get reverse change, and dispatch to editor
				change = change.getReverse();
				if (change) editor.dispatchEvent(new ChangeEvent(ChangeEvent.TEXT_CHANGE, change, ChangeEvent.ORIGIN_UNDO));
			}
		}
		
		public function redo():void
		{
			if (future.length > 0)
			{
				var change:TextChangeBase = future.pop();
				history.push(change);
				
				// Redispatch change to editor
				editor.dispatchEvent(new ChangeEvent(ChangeEvent.TEXT_CHANGE, change, ChangeEvent.ORIGIN_UNDO));
			}
		}
		
		public function clear():void
		{
			history.length = 0;
			future.length = 0;
			savedAt = 0;
		}
		
		private function handleKeyDown(event:KeyboardEvent):void
		{
			if (event.ctrlKey && !event.altKey)
			{
				switch (event.keyCode)
				{
					case 0x59:		// Y
						redo();
						break;
					case 0x5A:		// Z
						undo();
						break;
				}
			}
		}
		
		private function handleChange(event:ChangeEvent):void
		{
			if (event.change && event.origin == ChangeEvent.ORIGIN_LOCAL) collectChange(event.change);
		}
		
		private function collectChange(change:TextChangeBase):void
		{
			// Clear any future changes
			future.length = 0;
			// Check if change can be merged into last change
			if (change is TextChangeInsert && history.length > 0 && history[history.length-1] is TextChangeInsert)
			{
				var thisChange:TextChangeInsert = TextChangeInsert(change);
				var lastChange:TextChangeInsert = TextChangeInsert(history[history.length-1]);
				
				// Merge if the last change was on the same line, and ended where this change starts
				if (
					thisChange.startLine == lastChange.startLine &&
					lastChange.textLines.length == 1 &&
					thisChange.startChar == lastChange.startChar + lastChange.textLines[0].length
				) {
					var textLines:Vector.<String> = thisChange.textLines.concat();
					textLines[0] = lastChange.textLines[0] + textLines[0];
					
					change = new TextChangeInsert(lastChange.startLine, lastChange.startChar, textLines);
					
					// Remove last change from history
					history.pop();
				}
			}
			// Add change to history
			history.push(change);
		}
	}

}