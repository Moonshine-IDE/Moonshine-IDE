package actionScripts.impls;

import actionScripts.interfaces.INativeMenuItemBridge;
import actionScripts.ui.menu.vo.CustomMenuItem;
import actionScripts.vo.NativeMenuItemMoonshine;
import openfl.events.Event;

class INativeMenuItemBridgeImp extends CustomMenuItem implements INativeMenuItemBridge {

    private var _nativeMenuItem:NativeMenuItemMoonshine;
    private var _listener:(T:Event)->Void;

    public var getNativeMenuItem(get, never):Dynamic;
    public var keyEquivalent(get, set):String;
    public var keyEquivalentModifiers(get, set):Array<UInt>;
    public var listener(never, set):(T:Event)->Void;

	private function get_getNativeMenuItem():Dynamic return _nativeMenuItem;
    private function get_keyEquivalent():String return _nativeMenuItem.keyEquivalent;
    private function get_keyEquivalentModifiers():Array<UInt> return _nativeMenuItem.keyEquivalentModifiers;

    override private function set_data(value:Dynamic):Dynamic { _nativeMenuItem.data = value; return super.set_data( value ); }
    private function set_keyEquivalent(value:String):String { _nativeMenuItem.keyEquivalent = value; return value; }
    private function set_keyEquivalentModifiers(value:Array<UInt>):Array<UInt> { _nativeMenuItem.keyEquivalentModifiers = value; return value; }
    private function set_listener(value:(T:Event)->Void):(T:Event)->Void { if ( value != null ) _listener = value; _nativeMenuItem.addEventListener( Event.SELECT, _trigger, false, 0, true ); return value; }

	public function createMenu(label:String = "", isSeparator:Bool = false, listener:(Event) -> Void = null, enableTypes:Array<String> = null):Void {
		_nativeMenuItem = new NativeMenuItemMoonshine(label, isSeparator);
		_nativeMenuItem.enableTypes = enableTypes;
        _listener = listener;
	}

    private function _trigger( e:Event ) {

        if ( _listener != null ) {
            Reflect.callMethod( this, _listener, [ e ] );
        }

    }

}
