package flash.display;

import flash.display.NativeMenu;

/**
	This extern overrides Lime's definition of NativeMenuItem for compatiblity reasons
**/
extern class NativeMenuItem extends flash.events.EventDispatcher {
	@:flash.property var enabled(default, default):Bool;
	@:flash.property var keyEquivalent(default, default):String;
	@:flash.property var keyEquivalentModifiers(default, default):Array<Int>;
    @:flash.property var submenu(default, default):NativeMenu;
	function new(label:String = "", isSeparator:Bool = false):Void;
}
