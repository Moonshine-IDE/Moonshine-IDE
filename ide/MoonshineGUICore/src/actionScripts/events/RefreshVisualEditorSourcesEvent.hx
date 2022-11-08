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

package actionScripts.events;

import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.valueObjects.FileWrapper;
import openfl.events.Event;

class RefreshVisualEditorSourcesEvent extends Event {
	public static final REFRESH_VISUALEDITOR_SRC:String = "refreshVisualEditorSrc";

	private var _fileWrapper:FileWrapper;

	public var fileWrapper(get, never):FileWrapper;

	private function get_fileWrapper():FileWrapper
		return _fileWrapper;

	private var _project:AS3ProjectVO;

	public var project(get, never):AS3ProjectVO;

	private function get_project():AS3ProjectVO
		return _project;

	public function new(type:String, fileWrapper:FileWrapper, project:AS3ProjectVO) {
		super(type, false, false);

		_fileWrapper = fileWrapper;
		_project = project;
	}

	override public function clone():Event {
		return new RefreshVisualEditorSourcesEvent(this.type, this.fileWrapper, this.project);
	}
}