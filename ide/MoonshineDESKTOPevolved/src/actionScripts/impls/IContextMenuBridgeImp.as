////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
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
		
		public function removeAll(menuOf:Object):void
		{
			if (NativeMenuItem(menuOf).submenu) NativeMenuItem(menuOf).submenu.removeAllItems();
		}
		
		public function addItem(menuOf:Object, menuItem:Object):void
		{
			ContextMenu(menuOf).addItem(menuItem as NativeMenuItem);
		}
	}
}