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