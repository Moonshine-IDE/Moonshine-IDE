package components.popup;

import mx.events.CloseEvent;

extern class InfoBackgroundPopup {

    public function new();
    public function addEventListener(type:String, callback:(CloseEvent) -> Void):Void;
    public function removeEventListener(type:String, callback:(CloseEvent) -> Void):Void;
    public function setFocus():Void;
    @:flash.property public var height(default, default):Float;

}