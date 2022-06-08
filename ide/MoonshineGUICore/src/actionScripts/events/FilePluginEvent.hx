package actionScripts.events;

import actionScripts.factory.FileLocation;
import openfl.events.Event;

class FilePluginEvent extends Event {
	public static final EVENT_FILE_OPEN:String = "fileOpenEvent";
	public static final EVENT_FILE_SAVE:String = "fileSaveEvent";
	public static final EVENT_FILE_OPEN_WITH:String = "fileOpenWithEvent";
	public static final EVENT_JAVA_TYPEAHEAD_PATH_SAVE:String = "EVENT_JAVA_TYPEAHEAD_PATH_SAVE";
	public static final EVENT_JAVA8_PATH_SAVE:String = "EVENT_JAVA8_PATH_SAVE";

	public var file:FileLocation;

	public function new(type:String, file:FileLocation) {
		super(type, false, true);
		this.file = file;
	}
}