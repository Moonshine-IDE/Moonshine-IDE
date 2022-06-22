package flash.desktop;

extern class NativeApplication {

    @:flash.property
    static public var nativeApplication( default, default ):NativeApplication;

    @:flash.property
    public var applicationDescriptor( default, default ):XML;

    @:flash.property
    public var systemIdleMode( default, default ):String;

    public function addEventListener( type:String, listener:(event:Dynamic)->Void ):Void;
    public function exit( errorCode:Int = 0 ):Void;

}