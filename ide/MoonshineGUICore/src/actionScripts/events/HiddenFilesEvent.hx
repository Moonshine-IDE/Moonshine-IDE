package actionScripts.events;

import actionScripts.valueObjects.FileWrapper;
import openfl.events.Event;

class HiddenFilesEvent extends Event {
	public static final MARK_FILES_AS_VISIBLE:String = "markFilesAsVisible";
	public static final MARK_FILES_AS_HIDDEN:String = "markFilesAsHidden";

	private var _fileWrapper:FileWrapper;

	public var fileWrapper(get, null):FileWrapper;

	public function new(type:String, fileWrapper:FileWrapper) {
		super(type);

		_fileWrapper = fileWrapper;
	}

	public function get_fileWrapper():FileWrapper {
		return _fileWrapper;
	}
}