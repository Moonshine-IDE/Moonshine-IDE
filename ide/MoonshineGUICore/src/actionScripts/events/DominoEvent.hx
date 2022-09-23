package actionScripts.events;

import openfl.events.Event;

class DominoEvent extends Event {
	public static final NDS_KILL:String = "eventNDSKill";
	public static final EVENT_CONVERT_DOMINO_DATABASE:String = "eventConvertDominoDatabase";
	public static final EVENT_RUN_DOMINO_ON_VAGRANT:String = "eventRunDominoOnVagrant";
	public static final EVENT_BUILD_ON_VAGRANT:String = "eventBuildOnVagrant";

	public function new(type:String) {
		super(type, false, false);
	}
}