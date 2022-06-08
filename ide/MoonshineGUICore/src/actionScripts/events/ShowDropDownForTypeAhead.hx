package actionScripts.events;

import openfl.events.Event;

class ShowDropDownForTypeAhead extends Event {
	public static final EVENT_SHOWDROPDOWN:String = "newShowTypeAhead";

	public var result:Array<Dynamic>;

	public function new(type:String, result:Array<Dynamic>) {
		this.result = result;
		super(type, false, true);
	}
}