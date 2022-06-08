package actionScripts.events;

import openfl.events.Event;

class DominoEvent extends Event {
	public static final NDS_KILL:String = "eventNDSKill";

	public function new(type:String) {
		super(type, false, false);
	}
}