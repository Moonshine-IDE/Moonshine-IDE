package actionScripts.ui;

import mx.core.IUIComponent;

extern interface IContentWindow extends IUIComponent {

    @:flash.property
    public var label(default, null):String;

    @:flash.property
    public var longLabel(default, null):String;

    function save():Void;
    function isChanged():Bool;
    function isEmpty():Bool;
    function setFocus():Void;

}