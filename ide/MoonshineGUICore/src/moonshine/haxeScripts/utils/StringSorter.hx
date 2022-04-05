package moonshine.haxeScripts.utils;

class StringSorter
{
    public var sortField:String;

    public function new(fieldName:String = null)
    {
        this.sortField = fieldName;
    }

    public function sortCompareFunction(a:Dynamic, b:Dynamic):Int
    {
        var aString = (sortField != null) ? cast(Reflect.getProperty(a, sortField), String).toLowerCase() : cast(a, String).toLowerCase();
        var bString = (sortField != null) ? cast(Reflect.getProperty(b, sortField), String).toLowerCase() : cast(b, String).toLowerCase();

        if (aString < bString) {
            return -1;
        }
        if (aString > bString) {
            return 1;
        }
        
        return 0;
    }
}