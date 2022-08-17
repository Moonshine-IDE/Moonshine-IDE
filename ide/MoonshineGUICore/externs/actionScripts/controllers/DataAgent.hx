package actionScripts.controllers;

import haxe.Constraints.Function;

extern class DataAgent {
    public static inline var POSTEVENT:String = "POST";
	public function new(_postURL:String, _successFn:Function, _errorFn:Function, _anObject:Dynamic = null, _eventType:String, _timeout:Float, _showAlert:Bool);
}