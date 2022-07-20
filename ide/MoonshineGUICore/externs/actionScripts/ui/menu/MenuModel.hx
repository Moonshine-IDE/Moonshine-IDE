package actionScripts.ui.menu;

import actionScripts.ui.menu.MenuBar;
import actionScripts.ui.menu.interfaces.ICustomMenuItem;
import actionScripts.ui.menu.renderers.MenuRenderer;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;

extern class MenuModel {

    public function new(menuBar:MenuBar);
    public function addEventListener(type:String, listener:(Event)->Void):Void;
    public function displayMenu(base:DisplayObjectContainer, menuItems:Array<ICustomMenuItem>):MenuRenderer;
    public function isOpen():Bool;

}