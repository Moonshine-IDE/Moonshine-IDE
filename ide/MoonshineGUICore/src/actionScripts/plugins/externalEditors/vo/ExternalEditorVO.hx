package actionScripts.plugins.externalEditors.vo;

import actionScripts.interfaces.IExternalEditorVO;
import flash.filesystem.File;
import haxe.DynamicAccess;
import mx.utils.UIDUtil;
import openfl.errors.Error;

@:meta(Bindable("change"))
@:bind
class ExternalEditorVO implements IExternalEditorVO {

    @:meta(Bindable("change")) @:bind public var defaultInstallPath:String;
    @:meta(Bindable("change")) @:bind public var extraArguments:String;
    @:meta(Bindable("change")) @:bind public var isMoonshineDefault:Bool;
    @:meta(Bindable("change")) @:bind public var version:String;
    @:meta(Bindable("change")) @:bind public var website:String;

    @:meta(Bindable("change")) private var _installPath:File;
    @:meta(Bindable("change")) @:bind @:flash.property public var installPath(get, set):File;
    @:meta(Bindable("change")) private function get_installPath():File return _installPath;
    @:meta(Bindable("change")) private function set_installPath(value:File):File {

        _installPath = value;
        if (_installPath == null || !_installPath.exists) {

            isEnabled = false;
            isValid = false;

        } else {

            isValid = true;

        }

        return _installPath;

    }

    private var _isValid:Bool;
    @:meta(Bindable("change")) @:bind @:flash.property public var isValid(get, set):Bool;
    private function get_isValid():Bool return _isValid;
    private function set_isValid(value:Bool):Bool { _isValid = value; return _isValid; }

    private var _isEnabled:Bool;
    @:meta(Bindable("change")) @:bind @:flash.property public var isEnabled(get, set):Bool;
    private function get_isEnabled():Bool return _isEnabled;
    private function set_isEnabled(value:Bool):Bool { _isEnabled = value; return _isEnabled; }

    private var _localID:String;
    @:meta(Bindable("change")) @:bind @:flash.property public var localID(get, set):String;
    private function get_localID():String return _localID;
    private function set_localID(value:String):String { _localID = value; return _localID; }

    private var _title:String;
    @:meta(Bindable("change")) @:bind @:flash.property public var title(get, set):String;
    private function get_title():String return _title;
    private function set_title(value:String):String { _title = value; return _title; }

    private var _fileTypes:Array<String>;
    @:meta(Bindable("change")) @:bind @:flash.property public var fileTypes(get, set):Array<String>;
    private function get_fileTypes():Array<String> return _fileTypes;
    private function set_fileTypes(value:Array<String>):Array<String> { _fileTypes = value; return _fileTypes; }

    public function new(uid:String=null) {

        localID = ( uid != null ) ? uid : UIDUtil.createUID();

    }

    public static function cloneToEditorVO(value:DynamicAccess<Dynamic>):ExternalEditorVO {
        var tmpVO:ExternalEditorVO = new ExternalEditorVO();

        var d:Dynamic = {};
        
        if ( value.exists( "isMoonshineDefault" )) tmpVO.isMoonshineDefault = value.get( "isMoonshineDefault" );
        if ( value.exists( "title" )) tmpVO.title = value.get( "title" );
        if ( value.exists( "website" )) tmpVO.website = value.get( "website" );
        if ( value.exists( "isEnabled" )) tmpVO.isEnabled = value.get( "isEnabled" );
        if ( value.exists( "localID" )) tmpVO.localID = value.get( "localID" );
        if ( value.exists( "defaultInstallPath" )) tmpVO.defaultInstallPath = value.get( "defaultInstallPath" );
        if ( value.exists( "extraArguments" )) tmpVO.extraArguments = value.get( "extraArguments" );
        if ( value.exists( "installPath" )) tmpVO.installPath = value.get( "installPath" );
        if ( value.exists( "fileTypes" )) tmpVO.fileTypes = value.get( "fileTypes" );
        if ( value.exists( "installPath" ) && value.get( "installPath" ) != null && value.get( "installPath" ).nativePath != null ) {
            try
                {
                    tmpVO.installPath = new File(value.get( "installPath" ).nativePath);
                }
                catch (e:Error){}
        }

        if (tmpVO.installPath != null || !tmpVO.installPath.exists)
        {
            tmpVO.isEnabled = false;
            tmpVO.isValid = false;
        }
        
        return tmpVO;
    }

}