////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////

package actionScripts.plugins.externalEditors.vo;

import actionScripts.interfaces.IExternalEditorVO;
import flash.filesystem.File;
import haxe.DynamicAccess;
import moonshine.utils.UIDUtil;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.EventDispatcher;

@:meta(Bindable("change"))
@:bind
class ExternalEditorVO extends EventDispatcher implements IExternalEditorVO {

    private var _defaultInstallPath:String;
    public var defaultInstallPath(get, set):String;
    private function get_defaultInstallPath():String return _defaultInstallPath;
    private function set_defaultInstallPath(value:String):String {
        if ( _defaultInstallPath == value ) return _defaultInstallPath;
        _defaultInstallPath = value;
        dispatchChangeEvent();
        return _defaultInstallPath;
    }

    private var _extraArguments:String;
    public var extraArguments(get, set):String;
    private function get_extraArguments():String return _extraArguments;
    private function set_extraArguments(value:String):String {
        if ( _extraArguments == value ) return _extraArguments;
        _extraArguments = value;
        dispatchChangeEvent();
        return _extraArguments;
    }

    private var _version:String;
    public var version(get, set):String;
    private function get_version():String return _version;
    private function set_version(value:String):String {
        if ( _version == value ) return _version;
        _version = value;
        dispatchChangeEvent();
        return _version;
    }

    private var _website:String;
    public var website(get, set):String;
    private function get_website():String return _website;
    private function set_website(value:String):String {
        if ( _website == value ) return _website;
        _website = value;
        dispatchChangeEvent();
        return _website;
    }

    private var _isMoonshineDefault:Bool;
    public var isMoonshineDefault(get, set):Bool;
    private function get_isMoonshineDefault():Bool return _isMoonshineDefault;
    private function set_isMoonshineDefault(value:Bool):Bool {
        if ( _isMoonshineDefault == value ) return _isMoonshineDefault;
        _isMoonshineDefault = value;
        dispatchChangeEvent();
        return _isMoonshineDefault;
    }

	private var _installPath:File;
	public var installPath(get, set):File;
	private function get_installPath():File return _installPath;
    function set_installPath(value:File):File {
		_installPath = value;
		if (_installPath == null || !_installPath.exists) {
			isEnabled = false;
			isValid = false;
		} else {
			isValid = true;
		}
        dispatchChangeEvent();
		return _installPath;
	}

    private var _isValid:Bool;
    @:flash.property public var isValid(get, set):Bool;
    private function get_isValid():Bool return _isValid;
    private function set_isValid(value:Bool):Bool {
        if ( _isValid == value ) return _isValid;
        _isValid = value;
        dispatchChangeEvent();
        return _isValid;
    }

    private var _isEnabled:Bool;
    @:flash.property public var isEnabled(get, set):Bool;
    private function get_isEnabled():Bool return _isEnabled;
    private function set_isEnabled(value:Bool):Bool {
        if ( _isEnabled == value ) return _isEnabled;
        _isEnabled = value;
        dispatchChangeEvent();
        return _isEnabled;
    }

    private var _localID:String;
    @:flash.property public var localID(get, set):String;
    private function get_localID():String return _localID;
    private function set_localID(value:String):String {
        if ( _localID == value ) return _localID;
        _localID = value;
        dispatchChangeEvent();
        return _localID;
    }

    private var _title:String;
    @:flash.property public var title(get, set):String;
    private function get_title():String return _title;
    private function set_title(value:String):String {
        if ( _title == value ) return _title;
        _title = value;
        dispatchChangeEvent();
        return _title;
    }

    private var _fileTypes:Array<String>;
    @:flash.property public var fileTypes(get, set):Array<String>;
    private function get_fileTypes():Array<String> return _fileTypes;
    private function set_fileTypes(value:Array<String>):Array<String> {
        if ( _fileTypes == value ) return _fileTypes;
        _fileTypes = value;
        dispatchChangeEvent();
        return _fileTypes;
    }

	public function new(uid:String = null) {
		localID = (uid != null) ? uid : UIDUtil.createUID();
		super();
	}

    function dispatchChangeEvent() {
        dispatchEvent( new Event( Event.CHANGE ) );
    }

	public static function cloneToEditorVO(value:DynamicAccess<Dynamic>):ExternalEditorVO {
		var tmpVO:ExternalEditorVO = new ExternalEditorVO();

		if (value.exists("isMoonshineDefault"))
			tmpVO.isMoonshineDefault = value.get("isMoonshineDefault");
		if (value.exists("title"))
			tmpVO.title = value.get("title");
		if (value.exists("website"))
			tmpVO.website = value.get("website");
		if (value.exists("isEnabled"))
			tmpVO.isEnabled = value.get("isEnabled");
		if (value.exists("localID"))
			tmpVO.localID = value.get("localID");
		if (value.exists("defaultInstallPath"))
			tmpVO.defaultInstallPath = value.get("defaultInstallPath");
		if (value.exists("extraArguments"))
			tmpVO.extraArguments = value.get("extraArguments");
		if (value.exists("installPath"))
			tmpVO.installPath = value.get("installPath");
		if (value.exists("fileTypes"))
			tmpVO.fileTypes = value.get("fileTypes");
		if (value.exists("installPath") && value.get("installPath") != null && value.get("installPath").nativePath != null) {
			try {
				tmpVO.installPath = new File(value.get("installPath").nativePath);
			} catch (e:Error) {
            }
		}
        
		return tmpVO;
	}
}