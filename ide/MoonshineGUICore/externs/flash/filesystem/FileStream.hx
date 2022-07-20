package flash.filesystem;

import openfl.utils.ByteArray;

extern class FileStream {

    public function new();
    public function close():Void;
    public function open(file:File, fileMode:String):Void;
    public function readUTFBytes(length:Int):String;
    public function writeBytes(bytes:ByteArray, offset:Int = 0, length:Int = 0):Void;
    public function writeUTFBytes(value:String):Void;

}