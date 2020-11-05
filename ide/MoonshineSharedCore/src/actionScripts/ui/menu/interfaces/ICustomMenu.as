﻿////////////////////////////////////////////////////////////////////////////////
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
	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public interface ICustomMenu
	{
		function get items():Vector.<ICustomMenuItem>;

		//function set items(value:Vector.<ICustomMenuItem>):void

		function get numItems():int



		function get label():String


		function set label(value:String):void

	


		function addItem(item:ICustomMenuItem):ICustomMenuItem


		function addItemAt(item:ICustomMenuItem, index:int):ICustomMenuItem


		function addSubmenu(submenu:ICustomMenu, label:String=null):ICustomMenuItem


		function addSubMenuAt(submenu:ICustomMenu, index:int, label:String=null):ICustomMenuItem


		function containsItem(item:ICustomMenuItem):Boolean


		function getItemAt(index:int):ICustomMenuItem


		function getItemByName(name:String):ICustomMenuItem


		function getItemIndex(item:ICustomMenuItem):int
		
		function removeAllItems():void

	}
}




