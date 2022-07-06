package actionScripts.events;

import openfl.events.Event;

class OnDiskBuildEvent extends Event {
	public static final GENERATE_CRUD_ROYALE:String = "generateCRUDRoyaleProject";
	public static final GENERATE_JAVA_AGENTS:String = "generateCRUDJavaAgents";

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

	private function get_buildId():String {
		return _buildId;
	}

	private function get_buildDirectory():String {
		return _buildDirectory;
	}

	private function get_preCommands():Array<Dynamic> {
		return _preCommands;
	}

	private function get_commands():Array<Dynamic> {
		return _commands;
	}

	private function get_status():Int {
		return _status;
	}
}