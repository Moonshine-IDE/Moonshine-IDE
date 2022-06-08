package actionScripts.events;

import flash.display.DisplayObject;
import flash.events.Event;

class UpdateTabEvent extends Event {
	public static final EVENT_TAB_UPDATED_OUTSIDE:String = "tabUpdatedOutside";
	public static final EVENT_TAB_FILE_EXIST_NOMORE:String = "tabFileExistNomore";

	public var tab:DisplayObject;

	public function new(type:String, targetEditor:DisplayObject) {
		this.tab = targetEditor;

		super(type, false, false);
	}
}