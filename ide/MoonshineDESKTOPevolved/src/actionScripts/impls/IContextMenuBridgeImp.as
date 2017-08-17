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
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.net.registerClassAlias;
	import flash.ui.ContextMenu;
	
	import mx.utils.ObjectUtil;
	
	import actionScripts.interfaces.IContextMenuBridge;
	
	public class IContextMenuBridgeImp implements IContextMenuBridge
	{
		public function getContextMenu():ContextMenu
		{
			return (new ContextMenu());
		}
		
		public function getContextMenuItem(title:String, listener:Function=null, forState:String=null, hasSeparatorBefore:Boolean=false):Object
		{
			var tmpCMI: NativeMenuItem = title ? new NativeMenuItem(title, hasSeparatorBefore) : new NativeMenuItem(null, true);
			if (listener != null) tmpCMI.addEventListener(forState, listener, false, 0, true);
			return tmpCMI;
		}
		
		public function subMenu(menuOf:Object, menuItem:Object=null, extendedListner:Function=null):void
		{
			if (!NativeMenuItem(menuOf).submenu) NativeMenuItem(menuOf).submenu = new NativeMenu();
			
			if (menuItem && (menuItem is Array)) 
			{
				for each (var i:NativeMenuItem in menuItem)
				{
					registerClassAlias("flash.display.NativeMenuItem", NativeMenuItem);
					var tmpCMI:NativeMenuItem = ObjectUtil.copy(i) as NativeMenuItem;
					
					// object copying removes it's listeners thus adding it again
					if (extendedListner != null) tmpCMI.addEventListener(Event.SELECT, extendedListner, false, 0, true);
					
					NativeMenuItem(menuOf).submenu.addItem(tmpCMI);
				}
			}
			else if (menuItem) NativeMenuItem(menuOf).submenu.addItem(menuItem as NativeMenuItem);
		}
		
		public function addItem(menuOf:Object, menuItem:Object):void
		{
			ContextMenu(menuOf).addItem(menuItem as NativeMenuItem);
		}
	}
}