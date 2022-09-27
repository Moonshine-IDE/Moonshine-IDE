/**

Copyright (C) 2016-present Prominic.NET, Inc.
 
This program is free software: you can redistribute it and/or modify
it under the terms of the Server Side Public License, version 1,
as published by MongoDB, Inc.
 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
Server Side Public License for more details.

You should have received a copy of the Server Side Public License
along with this program. If not, see
http://www.mongodb.com/licensing/server-side-public-license.

As a special exception, the copyright holders give permission to link the
code of portions of this program with the OpenSSL library under certain
conditions as described in each individual source file and distribute
linked combinations including the program with the OpenSSL library. You
must comply with the Server Side Public License in all respects for
all of the code used other than as permitted herein. If you modify file(s)
with this exception, you may extend this exception to your version of the
file(s), but you are not obligated to do so. If you do not wish to do so,
delete this exception statement from your version. If you delete this
exception statement from all source files in the program, then also delete
it in the license file.

*/

package actionScripts.ui.menu.vo;

import actionScripts.ui.menu.interfaces.ICustomMenu;
import actionScripts.ui.menu.interfaces.ICustomMenuItem;
import actionScripts.ui.menu.interfaces.IMenuEntity;
import openfl.Vector;

class CustomMenu implements ICustomMenu implements IMenuEntity {
	private var _items:Vector<ICustomMenuItem> = new Vector<ICustomMenuItem>();
	private var _label:String;

	public var dynamicItem:Bool;
	public var items(get, never):Vector<ICustomMenuItem>;
	public var label(get, set):String;
	public var numItems(get, never):Int;

	private function get_items():Vector<ICustomMenuItem>
		return _items;

	private function get_label():String
		return _label;

	private function get_numItems():Int
		return _items.length;

	private function set_label(value:String):String {
		_label = value;
		return _label;
	}

	public function new(label:String = "", items:Vector<IMenuEntity> = null) {
		_label = label;
	}

	public function addItem(item:ICustomMenuItem):ICustomMenuItem {
		// TODO : Check if item is bound to another ICustomMenu
		items.push(item);
		return item;
	}

	public function addItemAt(item:ICustomMenuItem, index:Int):ICustomMenuItem {
		var pos:Int = index;
		if (index > items.length)
			pos = items.length;

		var removeIndex:Int = getItemIndex(item);
		if (removeIndex == -1) {
			items.splice(removeIndex, 1);
		}

		items.insertAt(pos, item);

		return item;
	}

	public function addSubmenu(submenu:ICustomMenu, label:String = null):ICustomMenuItem {
		return addItem(new CustomMenuItem((label != null) ? label : submenu.label, false, {
			data: submenu
		}));
	}

	public function addSubMenuAt(submenu:ICustomMenu, index:Int, label:String = null):ICustomMenuItem {
		return addItemAt(new CustomMenuItem((label != null) ? label : submenu.label, false, {
			data: submenu
		}), index);
	}

	public function containsItem(item:ICustomMenuItem):Bool {
		return false;
	}

	public function getItemAt(index:Int):ICustomMenuItem {
		if (index > items.length || index < 0) {
			return null;
		}

		return items[index];
	}

	public function getItemByName(name:String):ICustomMenuItem {
		for (entity in items) {
			if (entity == null)
				continue;
			if (entity.label == name)
				return entity;
		}
		return null;
	}

	public function getItemIndex(item:ICustomMenuItem):Int {
		return _items.indexOf(item);
	}

	public function removeItemAt(index:Int):ICustomMenuItem {
		if (index > items.length || index < 0) {
			return null;
		}

		var removedItem:ICustomMenuItem = this.getItemAt(index);
		items.splice(index, 1);

		return removedItem;
	}
}