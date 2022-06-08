package actionScripts.events;

import openfl.events.Event;

class LocationsEvent extends Event {
	public static final EVENT_SHOW_LOCATIONS:String = "newShowLocations";

	public var locations:Array<Dynamic> /* Array<Location> | Array<LocationLink> */;

	public function new(type:String, locations:Array<Dynamic> /* Array<Location> | Array<LocationLink> */) {
		super(type, false, false);
		this.locations = locations;
	}
}