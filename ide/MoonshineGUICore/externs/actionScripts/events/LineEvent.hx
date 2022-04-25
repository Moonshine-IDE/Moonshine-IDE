package actionScripts.events;

import openfl.events.Event;

class LineEvent extends Event {

    public static final COLOR_CHANGE:String = "colorChange";
    public static final WIDTH_CHANGE:String = "widthChange";
    
    private var _line:Int;
    public var line( get, never ):Int;
    
    public function get_line():Int { return _line; }

    public function new( type:String, line:Int ) {
        
        super( type, false, false );
			
		_line = line;

    }

    override function clone():Event {

        return new LineEvent( type, line );

    }

}