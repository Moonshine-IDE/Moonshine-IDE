package flash.net;

extern class ServerSocket {

    public var localPort:Int;
    public function new();
    public function bind(localPort:Int = 0, localAddress:String = "0.0.0.0"):Void;
    public function close():Void;

}