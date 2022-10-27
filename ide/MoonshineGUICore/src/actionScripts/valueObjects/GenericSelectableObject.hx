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

import openfl.events.Event;
import openfl.events.EventDispatcher;

class GenericSelectableObject extends EventDispatcher {

	private var _data:Dynamic;
	public var data(get, set):Dynamic;
	private function get_data():Dynamic return _data;
	private function set_data( value:Dynamic ):Dynamic {
		_data = value;
		this.dispatchEvent( new Event( Event.CHANGE ) );
		return _data;
	}

	private var _isSelected:Bool;
	public var isSelected(get, set):Bool;
	private function get_isSelected():Bool return _isSelected;
	private function set_isSelected( value:Bool ):Bool {
		_isSelected = value;
		this.dispatchEvent( new Event( Event.CHANGE ) );
		return _isSelected;
	}

	public function new(isSelcted:Bool = false, data:Dynamic = null) {
		super();
		this.isSelected = isSelcted;
		this.data = data;
	}
}