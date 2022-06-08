package actionScripts.events;

import openfl.events.Event;

class RunANTScriptEvent extends Event {
	public static final ANT_BUILD:String = "ANT_BUILD";
	public static final EVENT_ANTBUILD:String = "antbuildEvent";

	public function new(type:String) {
		super(type);
	}
}