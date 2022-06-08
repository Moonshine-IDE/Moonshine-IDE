package actionScripts.events;

import actionScripts.factory.FileLocation;
import openfl.events.Event;

class RefreshTreeEvent extends Event {
	public static final EVENT_REFRESH:String = "refreshEvent";

	public var dir:FileLocation;
	public var shallMarkedForDelete:Bool;

	public function new(directoryOrFile:FileLocation, shallMarkedForDelete:Bool = false) {
		this.dir = directoryOrFile;
		this.shallMarkedForDelete = shallMarkedForDelete;
		super(EVENT_REFRESH, false, false);
	}
}