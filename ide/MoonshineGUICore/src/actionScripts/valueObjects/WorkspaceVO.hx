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


package actionScripts.valueObjects;

import openfl.events.Event;
import openfl.events.EventDispatcher;

@:meta(Bindable("change"))
@:bind
class WorkspaceVO extends EventDispatcher 
{
	public var paths:Array<String>;

	private var _label:String;
    @:flash.property public var label(get, set):String;
    private function get_label():String return _label;
    private function set_label(value:String):String {
        if ( _label == value ) return _label;
        _label = value;
        dispatchEvent( new Event( Event.CHANGE ) );
        return _label;
    }

    private var _isDefault:Bool;
    @:flash.property public var isDefault(get, set):Bool;
    private function get_isDefault():Bool return _isDefault;
    private function set_isDefault(value:Bool):Bool {
        if ( _isDefault == value ) return _isDefault;
        _isDefault = value;
        dispatchEvent( new Event( Event.CHANGE ) );
        return _isDefault;
    }

	public function new(label:String, paths:Array<String>) {
		super();

		this.label = label;
		this.paths = paths;
	}
}