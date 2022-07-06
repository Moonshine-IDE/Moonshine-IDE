package actionScripts.locator;

import actionScripts.controllers.AddTabCommand;
import actionScripts.controllers.CloseTabCommand;
import actionScripts.controllers.DeleteFileCommand;
import actionScripts.controllers.ICommand;
import actionScripts.controllers.OpenFileCommand;
import actionScripts.controllers.OpenLocationCommand;
import actionScripts.controllers.QuitCommand;
import actionScripts.controllers.RenameFileFolderCommand;
import actionScripts.controllers.SaveAsCommand;
import actionScripts.controllers.SaveFileCommand;
import actionScripts.controllers.UpdateTabCommand;
import actionScripts.events.AddTabEvent;
import actionScripts.events.DeleteFileEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.OpenFileEvent;
import actionScripts.events.OpenLocationEvent;
import actionScripts.events.RenameFileFolderEvent;
import actionScripts.events.UpdateTabEvent;
import actionScripts.ui.menu.MenuPlugin;
import actionScripts.ui.tabview.CloseTabEvent;
import haxe.DynamicAccess;
import openfl.events.Event;

class IDEController {
	private var commands:DynamicAccess<Class<ICommand>> = {};

	public function new() {
		init();
	}

	public function init():Void {
		setupBindings();
		setupListener();
	}

	public function setupBindings():Void {
		commands.set(CloseTabEvent.EVENT_CLOSE_TAB, CloseTabCommand);
		commands.set(CloseTabEvent.EVENT_CLOSE_ALL_TABS, CloseTabCommand);
		commands.set(CloseTabEvent.EVENT_CLOSE_ALL_OTHER_TABS, CloseTabCommand);
		commands.set(OpenFileEvent.OPEN_FILE, OpenFileCommand);
		commands.set(OpenFileEvent.TRACE_LINE, OpenFileCommand);
		commands.set(OpenFileEvent.JUMP_TO_SEARCH_LINE, OpenFileCommand);
		commands.set(AddTabEvent.EVENT_ADD_TAB, AddTabCommand);
		commands.set(OpenLocationEvent.OPEN_LOCATION, OpenLocationCommand);
		commands.set(UpdateTabEvent.EVENT_TAB_UPDATED_OUTSIDE, UpdateTabCommand);
		commands.set(UpdateTabEvent.EVENT_TAB_FILE_EXIST_NOMORE, UpdateTabCommand);

		commands.set(MenuPlugin.MENU_SAVE_AS_EVENT, SaveAsCommand);
		commands.set(MenuPlugin.MENU_SAVE_EVENT, SaveFileCommand);
		commands.set(MenuPlugin.MENU_QUIT_EVENT, QuitCommand);
		commands.set(DeleteFileEvent.EVENT_DELETE_FILE, DeleteFileCommand);
		commands.set(RenameFileFolderEvent.RENAME_FILE_FOLDER, RenameFileFolderCommand);

		/*commands[ChangeLineEncodingEvent.EVENT_CHANGE_TO_WIN] = 	ChangeLineEndingCommand;
			commands[ChangeLineEncodingEvent.EVENT_CHANGE_TO_UNIX] =	ChangeLineEndingCommand;
			commands[ChangeLineEncodingEvent.EVENT_CHANGE_TO_OS9] =		ChangeLineEndingCommand; */
	}

	public function setupListener():Void {
		var ged:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		for (eventName in commands.keys()) {
			ged.addEventListener(eventName, execCommand);
		}
	}

	public function execCommand(event:Event):Void {
		var cmd:ICommand = Type.createInstance(commands.get(event.type), []);
		cmd.execute(event);
	}
}