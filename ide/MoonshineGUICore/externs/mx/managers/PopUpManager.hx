package mx.managers;

import flash.display.DisplayObject;
import mx.core.IFlexDisplayObject;

extern class PopUpManager {
    
    public static function centerPopUp(popUp:IFlexDisplayObject):Void;
    public static function createPopUp(parent:DisplayObject, className:Class<Dynamic>, modal:Bool=false):IFlexDisplayObject;
    public static function removePopUp(popUp:IFlexDisplayObject):Void;

}