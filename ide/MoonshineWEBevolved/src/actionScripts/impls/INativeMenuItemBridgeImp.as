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
	import actionScripts.interfaces.INativeMenuItemBridge;
	import actionScripts.ui.menu.vo.CustomMenuItem;
	import actionScripts.valueObjects.KeyboardShortcut;
	
	public class INativeMenuItemBridgeImp implements INativeMenuItemBridge
	{
		protected var nativeMenuItem: CustomMenuItem;
		
		public function createMenu(label:String="", isSeparator:Boolean=false, listener:Function=null, enableTypes:Array=null):void
		{
			nativeMenuItem = new CustomMenuItem(label, isSeparator);
			nativeMenuItem.enableTypes = enableTypes;
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