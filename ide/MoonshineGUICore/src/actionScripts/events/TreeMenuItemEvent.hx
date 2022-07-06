package actionScripts.events;

import actionScripts.ui.renderers.FTETreeItemRenderer;
import actionScripts.valueObjects.FileWrapper;
import openfl.events.Event;

class TreeMenuItemEvent extends Event {
	public static final RIGHT_CLICK_ITEM_SELECTED:String = "menuItemSelectedEvent";
	public static final EDIT_CANCEL:String = "editCancel";
	public static final EDIT_END:String = "editEnd";
	public static final NEW_FILE_CREATED:String = "NEW_FILE_CREATED";
	public static final FILE_DELETED:String = "FILE_DELETED";
	public static final FILE_RENAMED:String = "FILE_RENAMED";
	public static final NEW_FILES_FOLDERS_COPIED:String = "NEW_FILE_FOLDER_COPIED";

	public var menuLabel:String;
	public var data:FileWrapper;
	public var renderer:FTETreeItemRenderer;
	public var extra:Any;
	public var showAlert:Bool;

	public function new(type:String, menuLabel:String, data:FileWrapper, showAlert:Bool = true) {
		this.menuLabel = menuLabel;
		this.data = data;
		this.showAlert = showAlert;

		super(type, true, false);
	}
}