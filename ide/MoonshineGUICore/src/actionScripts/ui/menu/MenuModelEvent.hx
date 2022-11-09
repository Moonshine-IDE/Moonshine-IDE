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

package actionScripts.ui.menu;

import actionScripts.ui.menu.renderers.MenuItemRenderer;
import actionScripts.ui.menu.renderers.MenuRenderer;
import openfl.events.Event;

class MenuModelEvent extends Event {

	public static final ACTIVE_ALL_MENUS:String = "activeAllMenus";
	public static final ACTIVE_MENU_ITEM_RENDERER_CHANGED:String = "activeMenuItemRendererChanged";
	public static final MENU_CLOSED:String = "menuClosed";
	public static final MENU_OPENED:String = "menuOpened";
	public static final TOP_LEVEL_MENU_CHANGED:String = "topLevelMenuChanged";

	private var _menu:MenuRenderer;
    private var _renderer:MenuItemRenderer;

    public var menu(get, never):MenuRenderer;
    public var renderer(get, never):MenuItemRenderer;

    private function get_menu():MenuRenderer return _menu;
    private function get_renderer():MenuItemRenderer return _renderer;

    public function new(type:String, bubbles:Bool=false, cancelable:Bool=false, menu:MenuRenderer=null, renderer:MenuItemRenderer=null) {

        super(type, bubbles, cancelable);
        _renderer = renderer;
        _menu = menu;

    }

}