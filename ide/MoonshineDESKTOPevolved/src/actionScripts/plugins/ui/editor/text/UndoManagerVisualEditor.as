////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
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