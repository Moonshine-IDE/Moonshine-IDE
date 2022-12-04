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

package actionScripts.events;

import actionScripts.factory.FileLocation;
import actionScripts.valueObjects.FileWrapper;
import openfl.events.Event;

class OpenFileEvent extends Event {
	public static final OPEN_FILE:String = "openFileEvent";
	public static final TRACE_LINE:String = "traceLineEvent";
	public static final JUMP_TO_SEARCH_LINE:String = "jumpToLineEvent";

	public var files:Array<FileLocation>;
	public var atLine:Int;
	public var atChar:Int = -1;
	public var wrappers:Array<FileWrapper>;
	public var openAsTourDe:Bool;
	public var tourDeSWFSource:String;

	public var independentOpenFile:Bool; // when arbitrary file opened off-Moonshine, or drag Int off-Moonshine

	public function new(type:String, files:Array<FileLocation> = null, atLine:Int = -1, wrappers:Array<FileWrapper> = null, ...param:Any) {
		try {
			if (files != null)
				this.files = files;
			if (wrappers != null)
				this.wrappers = wrappers;
		} catch (e) {
			trace("Error:: Unrecognized 'Open' object type.");
		}

		this.atLine = atLine;
		if (param != null && param.length > 0) {
			this.openAsTourDe = param[0];
			if (this.openAsTourDe)
				this.tourDeSWFSource = param[1];
		}

		super(type, false, true);
	}
}