package actionScripts.events;

import openfl.events.Event;

class MenuEvent extends Event {
	public static final ITEM_SELECTED:String = "itemSelected";

	private var _data:Dynamic;

	public var data(get, null):Dynamic;

	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false, data:Dynamic = null) {
		super(type, bubbles, cancelable);
		_data = data;
	}

	public function get_data():Dynamic {
		return _data;
	}

	override public function clone():Event {
		return new MenuEvent(type, bubbles, cancelable, data);
	}
}