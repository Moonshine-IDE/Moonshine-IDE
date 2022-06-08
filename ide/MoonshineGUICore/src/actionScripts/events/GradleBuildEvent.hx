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