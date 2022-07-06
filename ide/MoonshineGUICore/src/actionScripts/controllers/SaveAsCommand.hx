package actionScripts.controllers;

import actionScripts.locator.IDEModel;
import actionScripts.ui.editor.BasicTextEditor;
import openfl.events.Event;

class SaveAsCommand implements ICommand {
	public function execute(event:Event):Void {
		var editor:BasicTextEditor = cast(IDEModel.getInstance().activeEditor, BasicTextEditor);
		if (editor != null)
			editor.saveAs();
	}
}