package actionScripts.events;

import flash.events.Event;

class ApplicationEvent extends Event {

    public static final APPLICATION_EXIT:String = "applicationExit";
	public static final DISPOSE_FOOTPRINT:String = "disposeFootprints";

    public function new( type:String ) {

        super( type );
        
    }

}