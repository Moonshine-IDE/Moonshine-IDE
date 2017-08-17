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
	import no.doomsday.console.core.gui.DropDownOption;
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class DropDownEvent extends Event 
	{
		
		public static const SELECTION:String = "selection";
		public var selectedOption:DropDownOption;
		public function DropDownEvent(type:String = SELECTION, option:DropDownOption = null) 
		{ 
			super(type, false, false);
			selectedOption = option;
			
		} 
		
		public override function clone():Event 
		{ 
			var e:DropDownEvent = new DropDownEvent(type, selectedOption);
			return e;
		} 
		
		public override function toString():String 
		{ 
			return formatToString("DropDownEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}