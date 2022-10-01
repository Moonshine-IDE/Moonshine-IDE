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
package actionScripts.ui.menu.vo 
{
	import actionScripts.ui.menu.interfaces.ICustomMenu;
	import actionScripts.ui.menu.interfaces.ICustomMenuItem;
	import actionScripts.ui.menu.interfaces.IMenuEntity;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class CustomMenu implements ICustomMenu, IMenuEntity
	{
		public var dynamicItem:Boolean;

		private var _items:Vector.<ICustomMenuItem> = new Vector.<ICustomMenuItem>();
		public function get items():Vector.<ICustomMenuItem>
		{
			return _items;
		}

		public function get numItems():int
		{
			return items.length;
		}

		private var _label:String;
		public function get label():String
		{
			return _label;
		}

		public function set label(value:String):void
		{
			if (label == value)  return;
			_label = value;
		}

		public function CustomMenu(label:String="",items:Vector.<IMenuEntity>=null)
		{
			this.label = label;			
		}

		public function addItem(item:ICustomMenuItem):ICustomMenuItem
		{
			// TODO : Check if item is bound to another ICustomMenu
			items.push(item);
			return item;
		}

		public function addItemAt(item:ICustomMenuItem, index:int):ICustomMenuItem
		{
			var pos:int = index;
			if(index > items.length)
				pos = items.length;

			var removeIndex:int = getItemIndex(item);
			if(removeIndex ==-1)
			{
				items.splice(removeIndex, 1);
			}

			items.splice(pos,0,item);

			return item;
		}
		public function addSubmenu(submenu:ICustomMenu, label:String=null):ICustomMenuItem
		{
			return addItem(new CustomMenuItem(label||submenu.label,false,{
				data:submenu
			}));
		}
		public function addSubMenuAt(submenu:ICustomMenu, index:int, label:String=null):ICustomMenuItem
		{
			return addItemAt(new CustomMenuItem(label || submenu.label,false,{
				data:submenu
			}),index);
			
		}
		
		public function containsItem(item:ICustomMenuItem):Boolean
		{
			return false;
		}		
		
		public function getItemAt(index:int):ICustomMenuItem
		{
			if(index > items.length || index <0)
			{
				return null;
			}

			return items[index];
		}

		public function getItemByName(name:String):ICustomMenuItem
		{
			for each(var entity:ICustomMenuItem in items)
			{
				if(!entity) continue;
				if(entity.label == name) return entity;
			}
			return null;
		}

		public function getItemIndex(item:ICustomMenuItem):int
		{
			return _items.indexOf(item);
			
		}

		public function removeItemAt(index:int):ICustomMenuItem
		{
			if(index > items.length || index <0)
			{
				return null;
			}

			var removedItem:ICustomMenuItem = this.getItemAt(index);
			items.splice(index, 1);

			return removedItem;
		}

		public function get menu():ICustomMenu
		{
			return null;
		}
		
		public function set menu(value:ICustomMenu):void
		{
			
		}
	}
}
