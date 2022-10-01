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
package actionScripts.ui.menu.interfaces
{
	import actionScripts.valueObjects.KeyboardShortcut;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public interface ICustomMenuItem
	{

		function hasShortcut():Boolean
		function get checked():Boolean
		function set checked(value:Boolean):void

		function get data():Object
		function set data(value:Object):void
		
		function hasSubmenu():Boolean
		function get isSeparator():Boolean

		function get shortcut():KeyboardShortcut
		function set shortcut(value:KeyboardShortcut):void

		function get submenu():ICustomMenu
		function set submenu(value:ICustomMenu):void

		function get label():String
		function set label(value:String):void
		
		function set enabled(value:Boolean):void;
		function get enabled():Boolean;

		function get dynamicItem():Boolean;
		function set dynamicItem(value:Boolean):void;
	}

}