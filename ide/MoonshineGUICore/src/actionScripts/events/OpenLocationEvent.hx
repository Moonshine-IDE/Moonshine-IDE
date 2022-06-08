package actionScripts.events;

import openfl.events.Event;

class OpenLocationEvent extends Event {
	public static final OPEN_LOCATION:String = "openLocationEvent";

	public var location:Dynamic /* Location | LocationLink */;

	public function new(type:String, location:Dynamic /* Location | LocationLink */) {
		super(type, false, true);
		this.location = location;
	}
}