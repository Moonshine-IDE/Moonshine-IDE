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
package no.doomsday.console.core.input
{
	import flash.display.InteractiveObject;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	
	/**
	 * Maintains a dictionary of key up/down states
	 * @author Andreas Rønning
	 */
	public class KeyboardManager extends EventDispatcher
	{
		private static var INSTANCE:KeyboardManager;
		/**
		 * Gets a singleton instance of the input manager
		 * @return
		 */
		public static function get instance():KeyboardManager {
			if (!INSTANCE) {
				INSTANCE = new KeyboardManager();
			}
			return INSTANCE;
		}
		private var keyboardSource:* = null;
		public var keydict:Dictionary;
		
		/**
		 * Start tracking keyboard events
		 * If already tracking, previous event listeners will be removed
		 * @param	eventSource
		 * The object whose events to respond to (typically stage)
		 */
		public function setup(eventSource:InteractiveObject):void {
			try {
				shutdown();
			}catch (e:Error)
			{
				
			}
			keydict = new Dictionary(false);
			keyboardSource = eventSource;
			eventSource.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, Number.POSITIVE_INFINITY, true);
			eventSource.addEventListener(KeyboardEvent.KEY_UP, onKeyUp,false,Number.POSITIVE_INFINITY,true);
		}
		/**
		 * Stop tracking keyboard events
		 */
		public function shutdown():void {
			keyboardSource.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			keyboardSource.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			keyboardSource = null;
			keydict = new Dictionary(false);
		}
		public function get isTracking():Boolean {
			if (keyboardSource) {
				return true;
			}
			return false;
		}
		private function onKeyUp(e:KeyboardEvent):void 
		{
			keydict[e.keyCode] = false;
		}
		private function onKeyDown(e:KeyboardEvent):void 
		{
			keydict[e.keyCode] = true;
		}
		/**
		 * Check wether a given key is currently pressed
		 * @param	keyCode
		 * @return
		 */
		public function keyIsDown(keyCode:int):Boolean {
			return keydict[keyCode];
		}
	}
	
}