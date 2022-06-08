package actionScripts.events;

import actionScripts.valueObjects.FileWrapper;
import openfl.events.Event;

class RenameFileFolderEvent extends Event {
	public static final RENAME_FILE_FOLDER:String = "RENAME_FILE_FOLDER";

	public var fw:FileWrapper;
	public var oldName:String;

	public function new(type:String, fw:FileWrapper, oldName:String) {
		this.fw = fw;
		this.oldName = oldName;

		super(type, true, false);
	}
}