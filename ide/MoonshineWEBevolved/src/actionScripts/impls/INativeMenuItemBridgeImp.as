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
	import actionScripts.interfaces.INativeMenuItemBridge;
	import actionScripts.ui.menu.vo.CustomMenuItem;
	import actionScripts.valueObjects.KeyboardShortcut;
	
	public class INativeMenuItemBridgeImp implements INativeMenuItemBridge
	{
		protected var nativeMenuItem: CustomMenuItem;
		
		public function createMenu(label:String="", isSeparator:Boolean=false, listener:Function=null):void
		{
			nativeMenuItem = new CustomMenuItem(label, isSeparator);
		}
		
		public function get keyEquivalent():String
		{
			return null;
		}
		
		public function set keyEquivalent(value:String):void
		{
		}
		
		public function get keyEquivalentModifiers():Array
		{
			return null;
		}
		
		public function set keyEquivalentModifiers(value:Array):void
		{
		}
		
		public function get data():Object
		{
			return nativeMenuItem.data;
		}
		
		public function set data(value:Object):void
		{
			nativeMenuItem.data = value;
		}
		
		public function set listener(value:Function):void
		{
		}
		
		public function set shortcut(value:KeyboardShortcut):void
		{
			nativeMenuItem.shortcut = value;
		}
		
		public function get getNativeMenuItem():Object
		{
			return nativeMenuItem;
		}
	}
}