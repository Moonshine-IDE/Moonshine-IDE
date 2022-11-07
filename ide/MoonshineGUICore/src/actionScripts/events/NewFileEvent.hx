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
import actionScripts.valueObjects.FileWrapper;
import actionScripts.valueObjects.ProjectVO;
import openfl.events.Event;

class NewFileEvent extends Event {
	public static final EVENT_NEW_FILE:String = "newFileEvent";
	public static final EVENT_NEW_VISUAL_EDITOR_FILE:String = "newVisualEditorFileEvent";
	public static final EVENT_NEW_FOLDER:String = "EVENT_NEW_FOLDER";
	public static final EVENT_ANT_BIN_URL_SET:String = "EVENT_ANT_BIN_URL_SET";
	public static final EVENT_FILE_RENAMED:String = "EVENT_FILE_RENAMED";
	public static final EVENT_PROJECT_SELECTED:String = "EVENT_PROJECT_SELECTED";
	public static final EVENT_FILE_SELECTED:String = "EVENT_FILE_SELECTED";
	public static final EVENT_FILE_CREATED:String = "EVENT_FILE_CREATED";
	public static final EVENT_PROJECT_RENAME:String = "EVENT_PROJECT_RENAME";

	public var filePath:String;
	public var fileName:String;
	public var fileExtension:String;
	public var fromTemplate:FileLocation;
	public var insideLocation:FileWrapper;
	public var newFileCreated:FileLocation;
	public var extraParameters:Array<String>;
	public var isFolder:Bool;
	public var isOpenAfterCreate:Bool = true;

	public var ofProject:ProjectVO;

	public function new(type:String, filePath:String = null, fromTemplate:FileLocation = null, insideLocation:FileWrapper = null, ...param:String) {
		this.filePath = filePath;
		this.fromTemplate = fromTemplate;
		this.insideLocation = insideLocation;
		this.extraParameters = param;

		super(type, false, true);
	}
}