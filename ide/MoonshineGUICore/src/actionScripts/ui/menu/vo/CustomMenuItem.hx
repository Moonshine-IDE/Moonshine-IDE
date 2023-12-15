////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
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

package actionScripts.ui.menu.vo;

import actionScripts.ui.menu.interfaces.ICustomMenu;
import actionScripts.ui.menu.interfaces.ICustomMenuItem;
import actionScripts.ui.menu.interfaces.IMenuEntity;
import actionScripts.valueObjects.KeyboardShortcut;

class CustomMenuItem implements ICustomMenuItem implements IMenuEntity {
	private var _checked:Bool;
	private var _data:Dynamic;
	private var _dynamicItem:Bool;
	private var _enabled:Bool = true;
	private var _isSeparator:Bool;
	private var _label:String;
	private var _shortcut:KeyboardShortcut;

	public var checked(get, set):Bool;
	public var data(get, set):Dynamic;
	public var dynamicItem(get, set):Bool;
	public var enabled(get, set):Bool;
	public var enableTypes:Array<String>;
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
		if ( Std.isOfType( _data, ICustomMenu ) ) return cast(_data, ICustomMenu);
		return null;
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