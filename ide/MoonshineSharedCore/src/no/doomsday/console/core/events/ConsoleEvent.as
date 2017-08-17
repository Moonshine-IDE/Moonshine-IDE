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
package no.doomsday.console.core.events
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ConsoleEvent extends Event 
	{
		public static const COMMAND:String = "consolecommand";
		public static const MESSAGE:String = "consolemessage";
		public static const PROPERTY_UPDATE:String = "onpropertyupdate";
		public var args:Array;
		public var text:String;
		/**
		 * Creates a new ConsoleEvent instance. This is a generic event class that simply holds an array of arguments
		 * @param	type
		 * @param	bubbles
		 * @param	cancelable
		 */
		public function ConsoleEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			var e:ConsoleEvent = new ConsoleEvent(type, bubbles, cancelable);
			e.args = args;
			e.text = text;
			return e;
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ConsoleEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}