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
package actionScripts.plugin.core.mouse
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.ui.editor.text.TextEditor;

	public class MouseManagerPlugin extends PluginBase implements IPlugin
	{
		override public function get name():String			{ return "Mouse Manager Plugin"; }
		override public function get author():String		{ return "Moonshine Project Team"; }
		override public function get description():String	{ return "Mouse Manager Plugin. Esc exits."; }
		
		private var lastKnownEditor:TextEditor;
		
		override public function activate():void
		{
			super.activate();
			
			// we need to watch all the focus change event to
			// track and keep one cursor at a time
			FlexGlobals.topLevelApplication.systemManager.addEventListener(FocusEvent.FOCUS_IN, onCursorUpdated);
			FlexGlobals.topLevelApplication.stage.addEventListener(Event.DEACTIVATE, onApplicationLostFocus);
			
			// removeElement from FlexGlobals.topLevelApplication do not return focus to TextEditor
			FlexGlobals.topLevelApplication.addEventListener(FlexEvent.UPDATE_COMPLETE, onTopLevelUpdated);
		}
		
		private function onTopLevelUpdated(event:FlexEvent):void
		{
			if (lastKnownEditor) setFocusToTextEditor(lastKnownEditor, true);
		}
		
		private function onCursorUpdated(event:FocusEvent):void
		{
			// this should handle any non-input type of component focus
			if (!(event.target is TextEditor) && !event.target.hasOwnProperty("text"))
			{
				return;
			}
			
			if (lastKnownEditor && lastKnownEditor != event.target) 
			{
				setFocusToTextEditor(lastKnownEditor, false);
			}
			
			// we mainly need to manage TextEditor focus
			// since this only differ with general focus cursor
			if (event.target is TextEditor)
			{
				setFocusToTextEditor(event.target as TextEditor, true);
				lastKnownEditor = event.target as TextEditor;
			}
			else
			{
				lastKnownEditor = null;
			}
		}
		
		private function onApplicationLostFocus(event:Event):void
		{
			FlexGlobals.topLevelApplication.stage.removeEventListener(Event.DEACTIVATE, onApplicationLostFocus);
			FlexGlobals.topLevelApplication.stage.addEventListener(Event.ACTIVATE, onApplicationReturnFocus);
			
			if (lastKnownEditor) setFocusToTextEditor(lastKnownEditor, false);
		}
		
		private function onApplicationReturnFocus(event:Event):void
		{
			FlexGlobals.topLevelApplication.stage.addEventListener(Event.DEACTIVATE, onApplicationLostFocus);
			FlexGlobals.topLevelApplication.stage.removeEventListener(Event.ACTIVATE, onApplicationReturnFocus);
			
			if (lastKnownEditor) setFocusToTextEditor(lastKnownEditor, true);
		}
		
		private function setFocusToTextEditor(editor:TextEditor, value:Boolean):void
		{
			if (value) editor.setFocus();
			
			editor.hasFocus = value;
			editor.updateSelection();
		}
	}
}