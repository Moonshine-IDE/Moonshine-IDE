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
	
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.FlexNativeMenu;
	import mx.core.UIComponent;
	import mx.events.FlexNativeMenuEvent;
	
	import spark.components.Button;
	
	public class INativeMenuItemBridgeImp extends CustomMenuItem implements INativeMenuItemBridge
	{
		protected var nativeMenuItem:NativeMenuItem;
		
		public function createMenu(label:String="", isSeparator:Boolean=false, listener:Function=null):void
		{
			nativeMenuItem = new NativeMenuItem(label, isSeparator);
		}
	
	    public function get keyEquivalent():String
		{
			return nativeMenuItem.keyEquivalent;
		}
		
	    public function set keyEquivalent(value:String):void
		{
			nativeMenuItem.keyEquivalent = value;
		}
		
		public function get keyEquivalentModifiers():Array
		{
			return nativeMenuItem.keyEquivalentModifiers;
		}
		
		public function set keyEquivalentModifiers(value:Array):void
		{
			nativeMenuItem.keyEquivalentModifiers = value;
		}
		
		override public function get data():Object
		{
			return nativeMenuItem.data;
		}
		
		override public function set data(value:Object):void
		{
			nativeMenuItem.data = value;
		}
		
		public function set listener(value:Function):void
		{
			if (value != null) 
				nativeMenuItem.addEventListener(Event.SELECT, value, false, 0, true);
			
		}
		
		override public function set shortcut(value:KeyboardShortcut):void
		{
			
		}
		
		public function get getNativeMenuItem():Object
		{
			return nativeMenuItem;
		}
	}
}