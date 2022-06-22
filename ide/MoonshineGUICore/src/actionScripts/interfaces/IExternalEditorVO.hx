package actionScripts.interfaces;

interface IExternalEditorVO {

    @:flash.property public var isValid(get, set):Bool;
    @:flash.property public var isEnabled(get, set):Bool;
    @:flash.property public var title(get, set):String;
    @:flash.property public var localID(get, set):String;
    @:flash.property public var fileTypes(get, set):Array<String>;

}