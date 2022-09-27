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

import openfl.events.Event;

class GradleBuildEvent extends Event {
	public static final START_GRADLE_BUILD:String = "startGradleBuild";
	public static final STOP_GRADLE_BUILD:String = "stopGradleBuild";
	public static final REFRESH_GRADLE_CLASSPATH:String = "refreshGradleClasspath";
	public static final STOP_GRADLE_DAEMON:String = "stopGradleDaemon";
	public static final GRADLE_DAEMON_CLOSED:String = "gradleDaemonClosed";
	public static final RUN_COMMAND:String = "runGradleCommand";

	public static final GRADLE_BUILD_FAILED:String = "gradleBuildFailed";
	public static final GRADLE_BUILD_COMPLETE:String = "gradleBuildComplete";
	public static final GRADLE_BUILD_TERMINATED:String = "gradleBuildTerminated";

	private var _buildId:String;
	private var _buildDirectory:String;
	private var _preCommands:Array<Dynamic>;
	private var _commands:Array<Dynamic>;
	private var _status:Int;

	public var buildId(get, null):String;
	public var buildDirectory(get, null):String;
	public var preCommands(get, null):Array<Dynamic>;
	public var commands(get, null):Array<Dynamic>;
	public var status(get, null):Int;

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