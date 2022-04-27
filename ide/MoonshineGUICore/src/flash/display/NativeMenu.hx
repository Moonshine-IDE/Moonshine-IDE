package flash.display;

import flash.display.NativeMenuItem;

@:require(flash10_1) extern class NativeMenu extends flash.events.EventDispatcher {
	function new() : Void;
    function addItem( item:NativeMenuItem ):Void;
    function removeAllItems():Void;
}
