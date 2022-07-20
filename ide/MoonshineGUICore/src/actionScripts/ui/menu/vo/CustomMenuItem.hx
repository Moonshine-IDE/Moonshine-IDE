package actionScripts.ui.menu.vo;

import actionScripts.ui.menu.interfaces.ICustomMenu;
import actionScripts.ui.menu.interfaces.ICustomMenuItem;
import actionScripts.ui.menu.interfaces.IMenuEntity;
import actionScripts.valueObjects.KeyboardShortcut;

class CustomMenuItem implements ICustomMenuItem implements IMenuEntity {
	private var _checked:Bool;
	private var _data:Dynamic;
	private var _dynamicItem:Bool;
	private var _enabled:Bool;
	private var _isSeparator:Bool;
	private var _label:String;
	private var _shortcut:KeyboardShortcut;

	public var checked(get, set):Bool;
	public var data(get, set):Dynamic;
	public var dynamicItem(get, set):Bool;
	public var enabled(get, set):Bool;
	public var enableTypes:Array<Dynamic>;
	public var isSeparator(get, set):Bool;
	public var label(get, set):String;
	public var shortcut(get, set):KeyboardShortcut;
	public var submenu(get, set):ICustomMenu;

	private function get_checked():Bool
		return _checked;

	private function get_data():Dynamic
		return _data;

	private function get_dynamicItem():Bool
		return _dynamicItem;

	private function get_enabled():Bool
		return _enabled;

	private function get_isSeparator():Bool
		return _isSeparator;

	private function get_label():String
		return _label;

	private function get_shortcut():KeyboardShortcut
		return _shortcut;

	private function get_submenu():ICustomMenu {
		if (_data == null)
			return null;
		return cast(_data, ICustomMenu);
	};

	private function set_checked(value:Bool):Bool {
		_checked = value;
		return _checked;
	}

	private function set_data(value:Dynamic):Dynamic {
		_data = value;
		return _data;
	}

	private function set_dynamicItem(value:Bool):Bool {
		_dynamicItem = value;
		return _dynamicItem;
	}

	private function set_enabled(value:Bool):Bool {
		_enabled = value;
		return _enabled;
	}

	private function set_isSeparator(value:Bool):Bool {
		_isSeparator = value;
		return _isSeparator;
	}

	private function set_label(value:String):String {
		_label = value;
		return _label;
	}

	private function set_shortcut(value:KeyboardShortcut):KeyboardShortcut {
		_shortcut = value;
		return _shortcut;
	}

	private function set_submenu(value:ICustomMenu):ICustomMenu {
		if (_data == value)
			return value;
		_data = value;
		return value;
	}

	public function new(label:String = "", isSeparator:Bool = false, options:Dynamic = null) {
		_label = label;
		_isSeparator = isSeparator;
		_init(options);
	}

	public function hasShortcut():Bool {
		return (_shortcut != null && _shortcut.event != null);
	}

	public function hasSubmenu():Bool {
		return (Std.isOfType(_data, ICustomMenu) && cast(_data, ICustomMenu).items.length > 0);
	}

	private function _init(options:Dynamic):Void {
		if (options != null) {
			if (options.shortcut != null && options.shortcut.event != null && options.shortcut.key != null) {
				_shortcut = new KeyboardShortcut(options.shortcut.event, options.shortcut.key, options.shortcut.mod);
			}
			if (options.data != null) {
				_data = options.data;
			}
			if (options.enableTypes != null) {
				enableTypes = options.enableTypes;
			}
		}
	}
}