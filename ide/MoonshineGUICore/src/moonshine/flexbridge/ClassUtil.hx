package moonshine.flexbridge;

class ClassUtil {

    public static function createInstance( name:String ) {

        var c = Type.resolveClass( name );

        if ( c == null ) return null;

        var i = Type.createInstance( c, [] );
        return i;

    }

    public static function getClass( name:String ) {

        var c = Type.resolveClass( name );
        return c;

    }

}