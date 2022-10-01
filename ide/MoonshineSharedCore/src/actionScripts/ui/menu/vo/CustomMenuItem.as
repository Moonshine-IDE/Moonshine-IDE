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
	import actionScripts.valueObjects.KeyboardShortcut;

	public class CustomMenuItem  implements ICustomMenuItem, IMenuEntity
	{
		public function hasShortcut():Boolean
		{
			return shortcut && shortcut.event;
		}
		
		public function hasSubmenu():Boolean
		{
			return _data is ICustomMenu && (_data as ICustomMenu).items.length;
		}

		public function CustomMenuItem(label:String = "", isSeparator:Boolean = false, options:Object = null)
		{
			super();
			this.label = label;
			_isSeparator = isSeparator;
			init(options);
		}

		private function init(options:Object):void
		{
			if (options)
			{
				if (options.shortcut && options.shortcut.event && options.shortcut.key)
				{
					shortcut = new KeyboardShortcut(options.shortcut.event,options.shortcut.key, options.shortcut.mod);
				}
				if (options.data)
				{
					data = options.data;
				}
				if (options.enableTypes)
				{
					enableTypes = options.enableTypes;
				}
			}
		}

		/* INTERFACE com.moonshineproject.plugin.menu.interfaces.ICustomMenuItem */
		private var _checked:Boolean;
		public function get checked():Boolean
		{
			return _checked;
		}

		public function set checked(value:Boolean):void
		{
			_checked = value;
		}

		private var _data:Object

		public function get data():Object
		{
			return _data;
		}
		public function set data(value:Object):void
		{
			_data = value;
		}
		private var _isSeparator:Boolean;
		public function get isSeparator():Boolean
		{
			return _isSeparator;
		}

		private var _shortcut:KeyboardShortcut

		public function get shortcut():KeyboardShortcut
		{
			return _shortcut;
		}

		public function set shortcut(value:KeyboardShortcut):void
		{
			if (_shortcut == value)
				return;
			_shortcut = value;
		}
		public function get submenu():ICustomMenu
		{
			if (!data)
				return null;
			return data as ICustomMenu
		}

		public function set submenu(value:ICustomMenu):void
		{
			if (data == value)
				return;

			data = value;

		}
		
		private var _label:String;
		public function get label():String
		{
			return _label;
		}

		public function set label(value:String):void
		{
			_label = value;

		}
		
		private var _enabled:Boolean = true;
		[Bindable]
        public function set enabled(value:Boolean):void
		{
			_enabled = value;
		}
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public var enableTypes:Array;

        private var _dynamicItem:Boolean;
        public function get dynamicItem():Boolean
        {
            return _dynamicItem;
        }

        public function set dynamicItem(value:Boolean):void
        {
            _dynamicItem = value;
        }
	}
}