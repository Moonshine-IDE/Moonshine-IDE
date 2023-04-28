package mx.collections;

extern class ListCollectionView {
    
    @:flash.property
    public var length:Int;

    public function toArray():Array<Dynamic>;
    public function getItemAt(index:Int):Dynamic;

}