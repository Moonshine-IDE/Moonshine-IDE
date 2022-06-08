package actionScripts.events;

import actionScripts.factory.FileLocation;
import moonshine.editor.text.TextEditor;
import openfl.events.Event;

class EditorPluginEvent extends Event {
	public static final EVENT_EDITOR_OPEN:String = "editorOpenEvent";
	public static final EVENT_EDITOR_CLOSE:String = "editorCloseEvent";

	public var newFile:Bool;
	public var file:FileLocation;
	public var fileExtension:String;
	public var editor:TextEditor;

	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false) {
		super(type, false, true);
	}
}