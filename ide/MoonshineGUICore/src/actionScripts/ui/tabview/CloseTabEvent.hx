package actionScripts.ui.tabview;

import openfl.display.DisplayObject;
import openfl.events.Event;

class CloseTabEvent extends Event {
	public static final EVENT_CLOSE_TAB:String = "closeTabEvent";
	public static final EVENT_CLOSE_ALL_TABS:String = "closeAllTabsEvent";
	public static final EVENT_CLOSE_ALL_OTHER_TABS:String = "closeAllOtherTabsEvent";
	public static final EVENT_TAB_CLOSED:String = "tabClosedEvent";
	public static final EVENT_ALL_TABS_CLOSED:String = "allTabsClosed";
	public static final EVENT_DISMISS_INDIVIDUAL_TAB_CLOSE_ALERT:String = "EVENT_DISMISS_INDIVIDUAL_TAB_CLOSE_ALERT";

	public var tab:DisplayObject;
	public var forceClose:Bool;
	public var isUserTriggered:Bool;

	public function new(type:String, targetEditor:DisplayObject, forceClose:Bool = false) {
		this.tab = targetEditor;
		this.forceClose = forceClose;

		super(type, false, false);
	}
}