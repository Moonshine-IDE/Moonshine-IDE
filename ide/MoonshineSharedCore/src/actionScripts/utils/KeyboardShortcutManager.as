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
package actionScripts.utils
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ShortcutEvent;
	import actionScripts.locator.IDEModel;
	import actionScripts.valueObjects.KeyboardShortcut;

	public class KeyboardShortcutManager
	{
		private static var _instance:KeyboardShortcutManager;
		
		private var stage:DisplayObject;
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var currentlyWorking:Boolean = false;
		private var pendingEvent:String;
		private var lookup:Object = {};

		public function KeyboardShortcutManager(block:KeyboardShortcutManagerBlocker)
		{
			stage = IDEModel.getInstance().mainView.stage;
			if (stage)
				init();
			else
				IDEModel.getInstance().mainView.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}

		private function addedToStageHandler(e:Event):void
		{
			e.target.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage = e.target.stage;
			init();
		}

		private function init():void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true);
		}

		public function stopEvent(event:String):void
		{
			if (pendingEvent && pendingEvent == event)
				clearPendingEvent();
			dispatch(event);
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
			var event:String = pendingEvent;
			clearPendingEvent();
			dispatch(event);
		}

		private function dispatch(event:String):void
		{
			if (event &&
				dispatcher.dispatchEvent(new ShortcutEvent(
				ShortcutEvent.SHORTCUT_PRE_FIRED, false, true, event)))
				dispatcher.dispatchEvent(new Event(event));
		}

		private function clearPendingEvent():void
		{
			stage.removeEventListener(Event.ENTER_FRAME, dispatchPendingEvent);
			pendingEvent = null;
		}

		private function keyDownHandler(e:KeyboardEvent):void
		{
			if (!e.keyCode)
				return; // omit all modifier only requests

			var event:String = lookup[getKeyConfigFromEvent(e)];
			if (event)
			{
				e.stopImmediatePropagation();
				e.preventDefault();
				markEventAsPending(event);
			}
		}

		public static function getInstance():KeyboardShortcutManager
		{
			if (!_instance)
				_instance = new KeyboardShortcutManager(new KeyboardShortcutManagerBlocker());
			return _instance;
		}

		public function has(shortcut:KeyboardShortcut):Boolean
		{
			return lookup[getKeyConfigFromShortcut(shortcut)] ? true : false;

		}

		private function getKeyConfigFromShortcut(shortcut:KeyboardShortcut):String
		{
			var config:Array = [];

			if (shortcut.cmdKey || shortcut.ctrlKey)
				config.push("C");
			if (shortcut.altKey)
				config.push("A");
			if (shortcut.shiftKey)
				config.push("S");
			config.push(shortcut.keyCode);

			return config.join(" ");
		}

		private function getKeyConfigFromEvent(e:KeyboardEvent):String
		{
			var config:Array = [];
			if (e.ctrlKey || e.keyCode == 22) // keycode == 22 - CHECK COMMAND KEY VALUE FOR MACOS
				config.push("C");
			if (e.altKey)
				config.push("A");
			if (e.shiftKey)
				config.push("S");
			config.push(e.keyCode);
			return config.join(" ");

		}

		public function activate(shortcut:KeyboardShortcut):Boolean
		{
			if (!has(shortcut))
			{

				lookup[getKeyConfigFromShortcut(shortcut)] = shortcut.event;
				return true;
			}
			return false;
		}

		public function deactivate(shortcut:KeyboardShortcut):Boolean
		{
			delete lookup[getKeyConfigFromShortcut(shortcut)];
			return true;
		}
	}
}

internal class KeyboardShortcutManagerBlocker
{
};