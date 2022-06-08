package actionScripts.events;

import actionScripts.ui.IContentWindow;
import openfl.events.Event;

class AddTabEvent extends Event {
	public static final EVENT_ADD_TAB:String = "addTabEvent";

	public var tab:IContentWindow;
	public var canClose:Bool;

	public function new(tab:IContentWindow, canClose:Bool = true) {
		super(EVENT_ADD_TAB, false, true);
		this.tab = tab;
		this.canClose = canClose;
	}
}