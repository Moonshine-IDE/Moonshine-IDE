package actionScripts.valueObjects;

import flash.sensors.Accelerometer;
import flash.system.Capabilities;
import flash.desktop.Clipboard;

class Settings {

    @:noCompletion
    private static var _initialized:Bool = false;
    @:noCompletion
    private static var _os:String;
    @:noCompletion
    private static var _keyboard:KeyboardSettings;
    @:noCompletion
    private static var _font:FontSettings;

    public static var os( get, never ):String;
    @:getter(os)
    public static function get_os():String { if (!_initialized) _init(); return _os; }

    public static var keyboard( get, never ):KeyboardSettings;
    @:getter(keyboard)
    public static function get_keyboard():KeyboardSettings { if (!_initialized) _init(); return _keyboard; }

    public static var font( get, never ):FontSettings;
    @:getter(font)
    public static function get_font():FontSettings { if (!_initialized) _init(); return _font; }

    private static function _init() {

        #if air
        _os = Capabilities.os.substr(0, 3).toLowerCase();
        #else
        _os = Capabilities.version.substr(0,3).toLowerCase();
        #end
        _keyboard = new KeyboardSettings();
        _font = new FontSettings();

        _initialized = true;
        
    }

    public function new() {}

    static public function doSomething() {

        trace( "1:", Clipboard.generalClipboard.formats );
        //trace( "2:", Clipboard.generalClipboard.supportsFilePromise );

        trace( "Hello Pjotr!" );

    }

}