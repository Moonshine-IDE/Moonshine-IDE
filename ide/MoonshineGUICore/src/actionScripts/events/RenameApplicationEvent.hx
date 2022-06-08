package actionScripts.events;

import actionScripts.factory.FileLocation;
import openfl.events.Event;

class RenameApplicationEvent extends Event {
	public static final RENAME_APPLICATION_FOLDER:String = "RENAME_APPLICATION_FOLDER";

	public var from:FileLocation;
	public var to:FileLocation;

	public function new(type:String, from:FileLocation, to:FileLocation) {
		super(type, true, false);
		this.from = from;
		this.to = to;
	}
}