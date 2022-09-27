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

package actionScripts.events;

import actionScripts.factory.FileLocation;
import openfl.events.Event;

class TemplatingEvent extends Event {
	public static final ADDED_NEW_TEMPLATE:String = "ADDED_NEW_TEMPLATE";
	public static final REMOVE_TEMPLATE:String = "REMOVE_TEMPLATE";
	public static final RENAME_TEMPLATE:String = "RENAME_TEMPLATE";

	public var label:String;
	public var newLabel:String;
	public var newFileTemplate:FileLocation;
	public var listener:String;
	public var isProject:Bool;

	public function new(type:String, isProject:Bool, label:String, listener:String = null, newLabel:String = null, newFileTemplate:FileLocation = null) {
		this.isProject = isProject;
		this.label = label;
		this.newLabel = newLabel;
		this.newFileTemplate = newFileTemplate;
		this.listener = listener;

		super(type, false, false);
	}

	public override function clone():Event {
		return new TemplatingEvent(type, isProject, label, listener, newLabel);
	}
}