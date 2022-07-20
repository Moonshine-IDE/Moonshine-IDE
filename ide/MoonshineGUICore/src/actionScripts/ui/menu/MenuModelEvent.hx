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