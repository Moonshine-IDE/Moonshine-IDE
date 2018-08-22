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
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.plugins.help.view.VisualEditorView;
	import actionScripts.plugins.ui.editor.VisualEditorViewer;
	import actionScripts.ui.tabview.TabEvent;
	
	import view.suportClasses.PropertyChangeReference;
	import view.suportClasses.events.PropertyEditorChangeEvent;
	
	public class UndoManagerVisualEditor
	{
		private var editor:VisualEditorView;
		
		private var history:Vector.<PropertyChangeReference> = new Vector.<PropertyChangeReference>();
		private var future:Vector.<PropertyChangeReference> = new Vector.<PropertyChangeReference>();
		
		private var savedAt:int = 0;
		private var pendingEvent:String;
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var stage:Stage;
		
		public function get hasChanged():Boolean
		{
			// Uses history.length to figure out if file is changed
			return (savedAt != history.length); 	
		}
		
		public function UndoManagerVisualEditor(editor:VisualEditorView)
		{
			this.editor = editor;
			
			editor.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			dispatcher.addEventListener(TabEvent.EVENT_TAB_SELECT, onTabChanges);
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
		
		public function dispose():void
		{
			editor.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			dispatcher.removeEventListener(TabEvent.EVENT_TAB_SELECT, onTabChanges);
			
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			stage.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.removeEventListener(Event.ENTER_FRAME, dispatchPendingEvent);
			
			editor = null;
		}
		
		private function onTabChanges(event:TabEvent):void
		{
			if (event.child is VisualEditorViewer)
			{
				if ((event.child as VisualEditorViewer).editorView != editor) stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
				else 
				{
					stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
					stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
				}
			}
		}
		
		private function addedToStageHandler(event:Event):void
		{
			stage = editor.stage;
			
			editor.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
		}
		
		private function handleKeyDown(event:KeyboardEvent):void
		{
			if ((event.keyCode == 22 || event.ctrlKey) && !event.altKey)
			{
				event.stopImmediatePropagation();
				event.preventDefault();
				
				switch (event.keyCode)
				{
					case Keyboard.Y:		// Y
						markEventAsPending('redo');
						break;
					case Keyboard.Z:		// Z
						markEventAsPending('undo');
						break;
				}
			}
		}
		
		private function markEventAsPending(event:String):void
		{
			// Since Air Default windows may or maynot disptach Event.SELECT for 
			// shortcuts we will use this pendingEvent system to delay the event
			// one frame
			pendingEvent = event;
			stage.addEventListener(Event.ENTER_FRAME, dispatchPendingEvent);
		}
		
		private function dispatchPendingEvent(e:Event):void
		{
			var lastEvent:String = pendingEvent;
			stage.removeEventListener(Event.ENTER_FRAME, dispatchPendingEvent);
			pendingEvent = null;
			
			switch (lastEvent)
			{
				case "redo":
					redo();
					break;
				case "undo":
					undo();
					break;
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