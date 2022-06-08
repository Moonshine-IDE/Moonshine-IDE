package actionScripts.events;

import openfl.events.Event;

class RenameEvent extends Event {
	public static final EVENT_OPEN_RENAME_SYMBOL_VIEW:String = "openRenameSymbolView";
	public static final EVENT_OPEN_RENAME_FILE_VIEW:String = "openRenameFileView";

	public var changes:Dynamic;

	public function new(type:String, changes:Dynamic) {
		super(type, false, true);
		this.changes = changes;
	}
}