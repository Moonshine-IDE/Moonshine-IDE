package actionScripts.events;

import actionScripts.valueObjects.FileWrapper;
import openfl.events.Event;

class AddFolderEvent extends Event {
	public static final ADD_NEW_FOLDER:String = "ADD_NEW_FOLDER";
	public static final RENAME_FILE_FOLDER:String = "RENAME_FILE_FOLDER";

	public var newFileWrapper:FileWrapper;
	public var inFileWrapper:FileWrapper;

	public function new(type:String, newFw:FileWrapper, inFw:FileWrapper) {
		super(type, true, false);
		newFileWrapper = newFw;
		inFileWrapper = inFw;
	}
}