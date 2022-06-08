package actionScripts.events;

import openfl.events.Event;

class LayoutEvent extends Event {
	public static final LAYOUT:String = "layout";
	public static final WINDOW_MAXIMIZED:String = "WINDOW_MAXIMIZED";
	public static final WINDOW_NORMAL:String = "WINDOW_NORMAL";

	public function new(type:String) {
		super(type, false, false);
	}

	public override function clone():Event {
		return new LayoutEvent(type);
	}
}