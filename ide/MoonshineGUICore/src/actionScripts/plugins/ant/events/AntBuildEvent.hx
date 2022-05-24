package actionScripts.plugins.ant.events;

import actionScripts.factory.FileLocation;
import flash.events.Event;

class AntBuildEvent extends Event {
	public static final ANT_BUILD:String = "ANT_BUILD";

	public var selectSDK:FileLocation;
	public var antHome:FileLocation;

	public function new(type:String, selectSDK:FileLocation = null, antHpme:FileLocation = null) {
		this.selectSDK = selectSDK;
		this.antHome = antHpme;
		super(type, false, true);
	}
}