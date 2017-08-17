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
package no.doomsday.console.core.commands
{
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ConsoleEventCommand extends ConsoleCommand
	{
		public var event:String;
		/**
		 * Creates an instance of ConsoleEventCommand
		 * Console event commands cause the DConsole instance to dispatch a ConsoleEvent of the specified type
		 * Any trailing arguments (separated by a space) are attached to the event "args" property
		 * @param	trigger
		 * The trigger phrase
		 * @param	event
		 * The event type to be dispatched
		 */
		public function ConsoleEventCommand(trigger:String, event:String, grouping:String = "Application", helpText:String = "")
		{
			super(trigger);
			this.event = event;
			this.grouping = grouping;
			this.helpText = helpText;
		}
		
	}
	
}