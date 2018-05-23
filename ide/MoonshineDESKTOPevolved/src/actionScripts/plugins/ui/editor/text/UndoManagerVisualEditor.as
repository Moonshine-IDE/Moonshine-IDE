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
	
	import actionScripts.plugins.help.view.VisualEditorView;

    import flash.ui.Keyboard;

    import view.suportClasses.PropertyChangeReference;
	import view.suportClasses.events.PropertyEditorChangeEvent;
	
	public class UndoManagerVisualEditor
	{
		private var editor:VisualEditorView;
		
		private var history:Vector.<PropertyChangeReference> = new Vector.<PropertyChangeReference>();
		private var future:Vector.<PropertyChangeReference> = new Vector.<PropertyChangeReference>();
		
		private var savedAt:int = 0;
		
		public function get hasChanged():Boolean
		{
			// Uses history.length to figure out if file is changed
			return (savedAt != history.length); 	
		}
		
		public function UndoManagerVisualEditor(editor:VisualEditorView)
		{
			this.editor = editor;
			
			editor.addEventListener(KeyboardEvent.KEY_UP, handleKeyDown);
		}
		
		public function save():void
		{
			savedAt = history.length;
		}
		
		public function undo():void
		{
			if (history.length > 0)
			{
				var change:PropertyChangeReference = history.pop();
				future.push(change);
				
				change.undo(editor.visualEditor);
			}
		}
		
		public function redo():void
		{
			if (future.length > 0)
			{
				var change:PropertyChangeReference = future.pop();
				history.push(change);
				
				change.redo(editor.visualEditor);
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
					case Keyboard.Y:		// Y
						redo();
						break;
					case Keyboard.Z:		// Z
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
		
		private function collectChange(change:PropertyChangeReference):void
		{
			// Clear any future changes
			future.length = 0;
			// Check if change can be merged into last change
			if (history.length > 0 && history[history.length-1] is PropertyChangeReference)
			{
				var lastChange:PropertyChangeReference = history[history.length-1];
				
				if (change === lastChange || (change.eventType == lastChange.eventType && change.fieldClass === lastChange.fieldClass && change.fieldLastValue === lastChange.fieldLastValue && change.fieldName === lastChange.fieldName &&
						change.fieldNewValue === lastChange.fieldNewValue)) return;
			}
			// Add change to history
			history.push(change);
		}
	}
}