package flash.filesystem;

extern class FileStream {

    public function new();
    public function close():Void;
    public function open(file:File, fileMode:String):Void;
    public function readUTFBytes(length:Int):String;
    public function writeUTFBytes(value:String):Void;

}