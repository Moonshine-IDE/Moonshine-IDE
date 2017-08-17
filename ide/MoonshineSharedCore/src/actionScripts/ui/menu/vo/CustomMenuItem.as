////////////////////////////////////////////////////////////////////////////////
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
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
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
			}
		}

		/* INTERFACE com.moonshineproject.plugin.menu.interfaces.ICustomMenuItem */

		public function get checked():Boolean
		{
			return false;
		}

		public function set checked(value:Boolean):void
		{

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
		[Bindable] public function set enabled(value:Boolean):void
		{
			_enabled = value;
		}
		public function get enabled():Boolean
		{
			return _enabled;
		}
	}
}