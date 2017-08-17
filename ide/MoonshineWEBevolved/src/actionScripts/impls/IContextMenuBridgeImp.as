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
package actionScripts.impls
{
	import flash.events.ContextMenuEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import actionScripts.interfaces.IContextMenuBridge;
	
	public class IContextMenuBridgeImp implements IContextMenuBridge
	{
		public function getContextMenu():ContextMenu
		{
			var cm:ContextMenu = new ContextMenu();
			cm.hideBuiltInItems();
			return cm;
		}
		
		public function getContextMenuItem(title:String, listener:Function=null, forState:String=null, hasSeparatorBefore:Boolean=false):Object
		{
			var cmi: ContextMenuItem = title ? new ContextMenuItem(title, hasSeparatorBefore) : new ContextMenuItem(null, true);
			if (listener != null) cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, listener, false, 0, true);
			return cmi;
		}
		
		public function subMenu(menuOf:Object, menuItem:Object=null, extendedListner:Function=null):void
		{
		}
		
		public function addItem(menuOf:Object, menuItem:Object):void
		{
			ContextMenu(menuOf).customItems.push(menuItem as ContextMenuItem);
		}
	}
}