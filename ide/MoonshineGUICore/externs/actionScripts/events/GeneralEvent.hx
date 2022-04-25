package actionScripts.events;

import openfl.events.Event;

class GeneralEvent extends Event {

    public static final DONE:String = "DONE";
    public static final DEVICE_UPDATED:String = "DEVICE_UPDATED";
    public static final RESET_ALL_SETTINGS:String = "RESET_ALL_SETTINGS";
    public static final SCROLL_TO_TOP:String = "SCROLL_TO_TOP";
    public static final EVENT_FILE_BROWSED:String = "eventFileBrowsed";

    public var value:Dynamic;

    public function new(type:String, value:Dynamic=null, _bubble:Bool=false, _cancelable:Bool=true) {
        this.value = value;
		super(type, _bubble, _cancelable);
    }


}