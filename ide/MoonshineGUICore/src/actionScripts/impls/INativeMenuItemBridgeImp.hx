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

package actionScripts.impls;

import actionScripts.interfaces.INativeMenuItemBridge;
import actionScripts.ui.menu.vo.CustomMenuItem;
import actionScripts.vo.NativeMenuItemMoonshine;
import openfl.events.Event;

class INativeMenuItemBridgeImp extends CustomMenuItem implements INativeMenuItemBridge {

    private var _nativeMenuItem:NativeMenuItemMoonshine;
    private var _listener:(T:Event)->Void;

    public var getNativeMenuItem(get, never):Dynamic;
    public var keyEquivalent(get, set):String;
    public var keyEquivalentModifiers(get, set):Array<UInt>;
    public var listener(never, set):(T:Event)->Void;

	private function get_getNativeMenuItem():Dynamic return _nativeMenuItem;
    private function get_keyEquivalent():String return _nativeMenuItem.keyEquivalent;
    private function get_keyEquivalentModifiers():Array<UInt> return _nativeMenuItem.keyEquivalentModifiers;

    override private function set_data(value:Dynamic):Dynamic { _nativeMenuItem.data = value; return super.set_data( value ); }
    private function set_keyEquivalent(value:String):String { _nativeMenuItem.keyEquivalent = value; return value; }
    private function set_keyEquivalentModifiers(value:Array<UInt>):Array<UInt> { _nativeMenuItem.keyEquivalentModifiers = value; return value; }
    private function set_listener(value:(T:Event)->Void):(T:Event)->Void { if ( value != null ) _listener = value; _nativeMenuItem.addEventListener( Event.SELECT, _trigger, false, 0, true ); return value; }

	public function createMenu(label:String = "", isSeparator:Bool = false, listener:(Event) -> Void = null, enableTypes:Array<String> = null):Void {
		_nativeMenuItem = new NativeMenuItemMoonshine(label, isSeparator);
		_nativeMenuItem.enableTypes = enableTypes;
        _listener = listener;
	}

    private function _trigger( e:Event ) {

        if ( _listener != null ) {
            Reflect.callMethod( this, _listener, [ e ] );
        }

    }

}
