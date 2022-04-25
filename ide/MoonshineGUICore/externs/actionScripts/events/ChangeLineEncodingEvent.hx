package actionScripts.events;

import flash.events.Event;

class ChangeLineEncodingEvent extends Event {

    public static final EVENT_CHANGE_TO_WIN:String = "lineEncodingWin";
    public static final EVENT_CHANGE_TO_UNIX:String = "lineEncodingUnix";
    public static final EVENT_CHANGE_TO_OS9:String = "lineEncodingOS9";

    public function new(type:String) {
        
        super(type, false, true);

    }

}