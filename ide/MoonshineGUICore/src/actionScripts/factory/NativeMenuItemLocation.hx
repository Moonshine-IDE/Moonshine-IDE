package actionScripts.factory;

import actionScripts.interfaces.INativeMenuItemBridge;
import openfl.events.Event;

class NativeMenuItemLocation {
    
    public var item:INativeMenuItemBridge;

    public function new(label:String="", isSeparator:Bool=false, listener:(Event)->Void=null, enableTypes:Array<String>=null) {

        // ** IMPORTANT **
		item = BridgeFactory.getNativeMenuItemInstance();
		item.createMenu(label, isSeparator, listener, enableTypes);

    }

}