////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.interfaces
{
	import flash.ui.ContextMenu;

	public interface IContextMenuBridge
	{
		function getContextMenu():ContextMenu;
		function getContextMenuItem(title:String, listener:Function = null, forState:String=null, hasSeparatorBefore:Boolean=false):Object;
		function subMenu(menuOf:Object, menuItem:Object = null, extendedListner:Function=null):void;
		function addItem(menuOf:Object, menuItem:Object):void;
	}
}