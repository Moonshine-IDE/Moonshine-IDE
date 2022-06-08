package actionScripts.events;

import openfl.events.Event;

class FileCopyPasteEvent extends Event {
	public static final EVENT_COPY_FILE:String = "copyFile";
	public static final EVENT_PASTE_FILES:String = "pasteFiles";

	public var wrappers:Array<Dynamic>;

	public function new(type:String, wrappers:Array<Dynamic>) {
		super(type, false, true);
		this.wrappers = wrappers;
	}
}