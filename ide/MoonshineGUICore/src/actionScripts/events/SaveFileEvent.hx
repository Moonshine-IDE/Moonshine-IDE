package actionScripts.events;

import actionScripts.factory.FileLocation;
import actionScripts.ui.editor.BasicTextEditor;
import openfl.events.Event;

class SaveFileEvent extends Event {
	public static final FILE_SAVED:String = "fileSavedEvent";

	public var file:FileLocation;
	public var editor:BasicTextEditor;

	public function new(type:String, file:FileLocation, editor:BasicTextEditor = null) {
		this.file = file;
		this.editor = editor;

		super(type, false, false);
	}
}