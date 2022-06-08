package actionScripts.events;

import openfl.events.Event;

class ShortcutEvent extends Event {
	public static final SHORTCUT_PRE_FIRED:String = "preFired";

	private var _event:String;

	public var event(get, null):String;

	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false, event:String = null) {
		super(type, bubbles, cancelable);
		_event = event;
	}

	private function get_event():String {
		return _event;
	}

	override public function clone():Event {
		return new ShortcutEvent(type, bubbles, cancelable, event);
	}
}