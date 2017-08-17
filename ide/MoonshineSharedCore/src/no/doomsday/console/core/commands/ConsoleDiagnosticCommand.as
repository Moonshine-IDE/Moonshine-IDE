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
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ConsoleDiagnosticCommand extends ConsoleCommand
	{
		public var dictionary:Dictionary;
		/**
		 * Creates an instance of ConsoleDiagnosticCommand
		 * Diagnostic commands provides inspection of a list of specified objects
		 * When triggered, arguments are iterated over and used to try and print properties on the object
		 * For instance "readMyMovieClip x y" will try to print out the x and y property values of the stored objects
		 * @param	trigger
		 * The trigger phrase
		 * @param	objects
		 * The objects to inspect. The references are stored in a weak dictionary
		 * WARNING: Solitary references will be GC'd!
		 */
		public function ConsoleDiagnosticCommand(trigger:String, objects:Array, grouping:String = "Application", helpText:String = "") 
		{
			super(trigger);
			this.dictionary = new Dictionary(true);
			this.grouping = grouping;
			this.helpText = helpText;
			for (var i:int = 0; i < objects.length; i++) 
			{
				dictionary["o" + i] = objects[i];
			}
		}
		
	}
	
}