package actionScripts.ui.menu.interfaces;

import openfl.Vector;

interface ICustomMenu {

    public var items(get, never):Vector<ICustomMenuItem>;
    public var numItems(get, never):Int;
    public var label(get, set):String;

    public function addItem(item:ICustomMenuItem):ICustomMenuItem;
    public function addItemAt(item:ICustomMenuItem, index:Int):ICustomMenuItem;
    public function addSubmenu(submenu:ICustomMenu, label:String=null):ICustomMenuItem;
    public function addSubMenuAt(submenu:ICustomMenu, index:Int, label:String=null):ICustomMenuItem;
    public function containsItem(item:ICustomMenuItem):Bool;
    public function getItemAt(index:Int):ICustomMenuItem;
    public function getItemByName(name:String):ICustomMenuItem;
    public function getItemIndex(item:ICustomMenuItem):Int;
    
}