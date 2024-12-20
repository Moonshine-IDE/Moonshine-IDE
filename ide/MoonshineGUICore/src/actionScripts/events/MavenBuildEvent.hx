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

import openfl.events.Event;

class MavenBuildEvent extends Event {
	public static final START_MAVEN_BUILD:String = "startMavenBuild";
	public static final INSTALL_MAVEN_BUILD:String = "installMavenBuild";
	public static final STOP_MAVEN_BUILD:String = "stopMavenBuild";

	public static final MAVEN_BUILD_FAILED:String = "mavenBuildFailed";
	public static final MAVEN_BUILD_COMPLETE:String = "mavenBuildComplete";
	public static final MAVEN_BUILD_TERMINATED:String = "mavenBuildTerminated";

	private var _buildId:String;
	private var _buildDirectory:String;
	private var _preCommands:Array<Dynamic>;
	private var _commands:Array<Dynamic>;
	private var _status:Int;

	public var buildId(get, never):String;
	public var buildDirectory(get, never):String;
	public var preCommands(get, never):Array<Dynamic>;
	public var commands(get, never):Array<Dynamic>;
	public var status(get, never):Int;

	public function new(type:String, buildId:String, status:Int, buildDirectory:String = null, preCommands:Array<Dynamic> = null,
			commands:Array<Dynamic> = null) {
		super(type, false, false);

		_buildId = buildId;
		_buildDirectory = buildDirectory;
		_preCommands = preCommands != null ? preCommands : [];
		_commands = commands != null ? commands : [];
	}

	public function get_buildId():String {
		return _buildId;
	}

	public function get_buildDirectory():String {
		return _buildDirectory;
	}

	public function get_preCommands():Array<Dynamic> {
		return _preCommands;
	}

	public function get_commands():Array<Dynamic> {
		return _commands;
	}

	public function get_status():Int {
		return _status;
	}
}