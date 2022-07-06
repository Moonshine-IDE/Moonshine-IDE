package moonshine.data.preferences;

import haxe.DynamicAccess;

abstract State( DynamicAccess<Any> ) {

    inline public function new() {

        this = {};

    }

    public function getProperty( name:String ):Any {

        return this.get( name );

    }

    public function setProperty( name:String, value:Any ) {

        this.set( name, value );

    }

}