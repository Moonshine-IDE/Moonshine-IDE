package actionScripts.ui.menu.interfaces;

import actionScripts.valueObjects.KeyboardShortcut;

interface ICustomMenuItem {

    public var checked(get, set):Bool;
    public var data(get, set):Dynamic;
    public var isSeparator(get, never):Bool;
    public var shortcut(get, set):KeyboardShortcut;
    public var submenu(get, set):ICustomMenu;
    public var label(get, set):String;
    public var enabled(get, set):Bool;
    public var dynamicItem(get, set):Bool;
    
    public function hasShortcut():Bool;
    public function hasSubmenu():Bool;

}