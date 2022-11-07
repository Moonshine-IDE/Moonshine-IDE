/**

Copyright (C) 2016-present Prominic.NET, Inc.
 
This program is free software: you can redistribute it and/or modify
it under the terms of the Server Side Public License, version 1,
as published by MongoDB, Inc.
 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
Server Side Public License for more details.

You should have received a copy of the Server Side Public License
along with this program. If not, see
http://www.mongodb.com/licensing/server-side-public-license.

As a special exception, the copyright holders give permission to link the
code of portions of this program with the OpenSSL library under certain
conditions as described in each individual source file and distribute
linked combinations including the program with the OpenSSL library. You
must comply with the Server Side Public License in all respects for
all of the code used other than as permitted herein. If you modify file(s)
with this exception, you may extend this exception to your version of the
file(s), but you are not obligated to do so. If you do not wish to do so,
delete this exception statement from your version. If you delete this
exception statement from all source files in the program, then also delete
it in the license file.

*/

package actionScripts.valueObjects;

class MobileDeviceVO {
	public static final AND:String = "AND";
	public static final IOS:String = "IOS";

	public var type:String = AND;
	public var isDefault:Bool;

	public function new(name:String = null, key:String = null, type:String = null, dpi:String = "", isDefault:Bool = false) {
		this.name = name;
		this.key = key;
		this.type = type;
		this.dpi = dpi;
		this.isDefault = isDefault;
	}

	private var _name:String;

	public var name(get, set):String;

	private function get_name():String {
		return _name;
	}

	private function set_name(value:String):String {
		_name = value;
		return _name;
	}

	private var _key:String;

	public var key(get, set):String;

	private function get_key():String {
		return _key;
	}

	private function set_key(value:String):String {
		_key = value;
		return _key;
	}

	private var _dpi:String = "";

	public var dpi(get, set):String;

	private function get_dpi():String {
		return _dpi;
	}

	private function set_dpi(value:String):String {
		_dpi = value;
		return _dpi;
	}
}