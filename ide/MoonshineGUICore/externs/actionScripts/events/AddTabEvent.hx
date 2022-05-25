package actionScripts.events;

import flash.events.Event;
import actionScripts.ui.IContentWindow;

extern class AddTabEvent extends Event {

    public static inline final EVENT_ADD_TAB:String = "addTabEvent";
    public var tab:IContentWindow;
	public var canClose:Bool;

    public function new(tab:IContentWindow, ?canClose:Bool=true);

}