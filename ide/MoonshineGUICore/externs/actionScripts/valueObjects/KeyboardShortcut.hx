package actionScripts.valueObjects;

extern class KeyboardShortcut {

    public var event(default, default):String;
    public function new(event:String, key:String, modifiers:Array<Dynamic>=null);

}