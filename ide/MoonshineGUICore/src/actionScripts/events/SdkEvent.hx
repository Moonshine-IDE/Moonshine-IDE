package actionScripts.events;

import openfl.events.Event;

class SdkEvent extends Event {
	public static final CHANGE_SDK:String = "changeSdk";
	public static final CHANGE_HAXE_SDK:String = "changeHaxeSdk";
	public static final CHANGE_NODE_SDK:String = "changeNodeSdk";

	public function new(type:String) {
		super(type, false, true);
	}
}