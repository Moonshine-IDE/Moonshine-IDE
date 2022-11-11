////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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

package actionScripts.controllers;

import actionScripts.events.ChangeLineEncodingEvent;
import actionScripts.locator.IDEModel;
import actionScripts.ui.editor.BasicTextEditor;
import openfl.events.Event;
import openfl.errors.Error;

class ChangeLineEndingCommand implements ICommand {
	private var model:IDEModel = IDEModel.getInstance();

	public function execute(event:Event):Void {
		var editor:BasicTextEditor = cast(this.model.activeEditor, BasicTextEditor);
		if (editor != null) {
			var delim:String;

			if (event.type == ChangeLineEncodingEvent.EVENT_CHANGE_TO_WIN)
				delim = "\r\n";
			else if (event.type == ChangeLineEncodingEvent.EVENT_CHANGE_TO_UNIX)
				delim = "\n";
			else if (event.type == ChangeLineEncodingEvent.EVENT_CHANGE_TO_OS9)
				delim = "\r";
			else {
				throw new Error("Unknown line delimiter event.");
			}

			editor.editor.lineDelimiter = delim;
		}
	}
}