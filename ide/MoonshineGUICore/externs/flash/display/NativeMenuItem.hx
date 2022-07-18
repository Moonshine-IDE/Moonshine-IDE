package flash.display;

import flash.display.NativeMenu;

@:require(flash10_1) extern class NativeMenuItem extends flash.events.EventDispatcher {
	@:flash.property var enabled(get,set) : Bool;
	function new( label:String = "", isSeparator:Bool = false ) : Void;
	private function get_enabled() : Bool;
	private function set_enabled(value : Bool) : Bool;
    @:flash.property var submenu(get,set) : NativeMenu;
    private function get_submenu():NativeMenu;
    private function set_submenu( value:NativeMenu ):NativeMenu;
}
