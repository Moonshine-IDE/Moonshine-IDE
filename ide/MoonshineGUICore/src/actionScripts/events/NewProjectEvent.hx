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

import actionScripts.factory.FileLocation;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import openfl.events.Event;

class NewProjectEvent extends Event {
	public static final CREATE_NEW_PROJECT:String = "createNewProjectEvent";
	public static final IMPORT_AS_NEW_PROJECT:String = "openFolderAsNewProjectEvent";

	private var _exportProject:AS3ProjectVO;

	public var exportProject(get, never):AS3ProjectVO;

	private function get_exportProject():AS3ProjectVO
		return _exportProject;

	public var isExport(get, never):Bool;

	private function get_isExport():Bool
		return _exportProject != null;

	public var settingsFile:FileLocation;
	public var templateDir:FileLocation;
	public var projectFileEnding:String;

	public function new(type:String, projectFileEnding:String, settingsFile:FileLocation, templateDir:FileLocation, project:AS3ProjectVO = null) {
		this.projectFileEnding = projectFileEnding;
		this.settingsFile = settingsFile;
		this.templateDir = templateDir;
		_exportProject = project;

		super(type, false, true);
	}
}