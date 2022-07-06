package actionScripts.controllers;

import actionScripts.events.ChangeLineEncodingEvent;
import actionScripts.locator.IDEModel;
import actionScripts.ui.editor.BasicTextEditor;
import openfl.events.Event;
import openfl.errors.Error;

class ChangeLineEndingCommand implements ICommand {
	private var model:IDEModel = IDEModel.getInstance();

	public function execute(event:Event):Void {
		var editor:BasicTextEditor = cast(this.model.activeEditor, BasicTextEditor);
		if (editor != null) {
			var delim:String;

			if (event.type == ChangeLineEncodingEvent.EVENT_CHANGE_TO_WIN)
				delim = "\r\n";
			else if (event.type == ChangeLineEncodingEvent.EVENT_CHANGE_TO_UNIX)
				delim = "\n";
			else if (event.type == ChangeLineEncodingEvent.EVENT_CHANGE_TO_OS9)
				delim = "\r";
			else {
				throw new Error("Unknown line delimiter event.");
			}

			editor.editor.lineDelimiter = delim;
		}
	}
}