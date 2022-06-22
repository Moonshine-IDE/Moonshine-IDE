package mx.controls;

import openfl.display.Sprite;

extern class Alert {

    static public inline final OK:Int = 4;

    static public function show( text:String, title:String, flags:Int, parent:Sprite, closeHandler:( a:Dynamic ) -> Void ):Void;

}