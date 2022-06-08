package actionScripts.events;

import actionScripts.factory.FileLocation;
import actionScripts.valueObjects.FileWrapper;
import openfl.events.Event;

class DuplicateEvent extends Event {
	public static final EVENT_APPLY_DUPLICATE:String = "applyDuplicate";
	public static final EVENT_OPEN_DUPLICATE_FILE_VIEW:String = "openDuplicateFileView";

	public var fileWrapper:FileWrapper;
	public var fileLocation:FileLocation;
	public var fileName:String;

	public function new(type:String, wrapper:FileWrapper = null, location:FileLocation = null) {
		super(type, false, true);
		this.fileWrapper = wrapper;
		this.fileLocation = location;
	}
}