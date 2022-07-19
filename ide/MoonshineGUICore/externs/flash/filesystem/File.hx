package flash.filesystem;

extern class File {

    public var exists:Bool;
    public var size(get, default):Int;
    public function new(path:String=null);

}