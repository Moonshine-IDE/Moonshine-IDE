package actionScripts.controllers;

import actionScripts.locator.IDEModel;
import actionScripts.ui.IContentWindow;
import actionScripts.ui.notifier.ActionNotifier;
import openfl.events.Event;

class SaveFileCommand implements ICommand {
	public function execute(event:Event):Void {
		ActionNotifier.getInstance().notify("Saving");

		var editor:IContentWindow = cast(IDEModel.getInstance().activeEditor, IContentWindow);
		editor.save();
	}
}