package actionScripts.events;

import openfl.events.EventDispatcher;

class GlobalEventDispatcher extends EventDispatcher {

    private static var instance:GlobalEventDispatcher;

    public static function getInstance():GlobalEventDispatcher {
			
        if ( instance == null ) instance = new GlobalEventDispatcher();
        return instance;

    }

}