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
package actionScripts.plugins.ui.editor.text
{
	import flash.events.KeyboardEvent;
	
	import actionScripts.events.ChangeEvent;
	import actionScripts.plugins.help.view.VisualEditorView;
	import actionScripts.ui.editor.text.change.TextChangeBase;
	import actionScripts.ui.editor.text.change.TextChangeInsert;
	
	import view.events.PropertyEditorChangeEvent;
	import view.models.PropertyChangeReferenceVO;
	
	public class UndoManagerVisualEditor
	{
		private var editor:VisualEditorView;
		
		private var history:Vector.<PropertyChangeReferenceVO> = new Vector.<PropertyChangeReferenceVO>();
		private var future:Vector.<PropertyChangeReferenceVO> = new Vector.<PropertyChangeReferenceVO>();
		
		private var savedAt:int = 0;
		
		public function get hasChanged():Boolean
		{
			// Uses history.length to figure out if file is changed
			return (savedAt != history.length); 	
		}
		
		public function UndoManagerVisualEditor(editor:VisualEditorView)
		{
			this.editor = editor;
			
			editor.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
		}
		
		public function save():void
		{
			savedAt = history.length;
		}
		
		public function undo():void
		{
			if (history.length > 0)
			{
				var change:PropertyChangeReferenceVO = history.pop();
				future.push(change);
				
				change.reverse(editor.visualEditor);
			}
		}
		
		public function redo():void
		{
			if (future.length > 0)
			{
				var change:PropertyChangeReferenceVO = future.pop();
				history.push(change);
				
				change.restore(editor.visualEditor);
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
		
		public function handleChange(event:PropertyEditorChangeEvent):void
		{
			if (event.changedReference) 
			{
				event.changedReference.eventType = event.type;
				collectChange(event.changedReference);
			}
		}
		
		private function collectChange(change:PropertyChangeReferenceVO):void
		{
			// Clear any future changes
			future.length = 0;
			// Check if change can be merged into last change
			if (history.length > 0 && history[history.length-1] is PropertyChangeReferenceVO)
			{
				var lastChange:PropertyChangeReferenceVO = history[history.length-1];
				
				if (change === lastChange || (change.fieldClass === lastChange.fieldClass && change.fieldLastValue === lastChange.fieldLastValue && change.fieldName === lastChange.fieldName &&
						change.fieldNewValue === lastChange.fieldNewValue)) return;
			}
			// Add change to history
			history.push(change);
		}
	}
}