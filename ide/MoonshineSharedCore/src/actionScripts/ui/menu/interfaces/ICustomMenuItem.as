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
package actionScripts.ui.menu.interfaces
{
	import actionScripts.valueObjects.KeyboardShortcut;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public interface ICustomMenuItem
	{

		function hasShortcut():Boolean
		/*function get checked():Boolean
		function set checked(value:Boolean):void*/

		function get data():Object
		function set data(value:Object):void
		
		function hasSubmenu():Boolean
		function get isSeparator():Boolean

		function get shortcut():KeyboardShortcut
		function set shortcut(value:KeyboardShortcut):void

		function get submenu():ICustomMenu
		function set submenu(value:ICustomMenu):void

		function get label():String
		function set label(value:String):void
		
		function set enabled(value:Boolean):void;
		function get enabled():Boolean;

	}

}