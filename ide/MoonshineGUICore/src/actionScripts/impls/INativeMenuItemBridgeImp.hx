package actionScripts.impls;

import actionScripts.interfaces.INativeMenuItemBridge;
import actionScripts.ui.menu.vo.CustomMenuItem;
import actionScripts.valueObjects.KeyboardShortcut;
import actionScripts.vo.NativeMenuItemMoonshine;
import openfl.events.Event;

class INativeMenuItemBridgeImp extends CustomMenuItem implements INativeMenuItemBridge {

    private var _nativeMenuItem:NativeMenuItemMoonshine;

    public var getNativeMenuItem(get, never):Dynamic;
    public var keyEquivalent(get, set):String;
    public var keyEquivalentModifiers(get, set):Array<Int>;
    public var listener(never, set):(Event)->Void;

	private function get_getNativeMenuItem():Dynamic return _nativeMenuItem;
    private function get_keyEquivalent():String return _nativeMenuItem.keyEquivalent;
    private function get_keyEquivalentModifiers():Array<Int> return _nativeMenuItem.keyEquivalentModifiers;

    private function set_keyEquivalent(value:String):String { _nativeMenuItem.keyEquivalent = value; return value; }
    private function set_keyEquivalentModifiers(value:Array<Int>):Array<Int> { _nativeMenuItem.keyEquivalentModifiers = value; return value; }
    private function set_listener(value:(Event)->Void):(Event)->Void { if ( value != null ) _nativeMenuItem.addEventListener( Event.SELECT, value, false, 0, true ); return value; }

	public function createMenu(label:String = "", isSeparator:Bool = false, listener:(Event) -> Void = null, enableTypes:Array<Dynamic> = null):Void {
		_nativeMenuItem = new NativeMenuItemMoonshine(label, isSeparator);
		_nativeMenuItem.enableTypes = enableTypes;
	}

}
