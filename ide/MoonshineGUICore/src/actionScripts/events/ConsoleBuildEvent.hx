package actionScripts.events;

import actionScripts.factory.FileLocation;
import openfl.events.Event;

class ConsoleBuildEvent extends Event {
	private var _arguments:Array<String>;
	private var _buildDirectory:FileLocation;

	public var arguments(get, null):Array<Dynamic>;
	public var buildDirectory(get, null):FileLocation;

	public function new(type:String, arguments:Array<String> = null, buildDirectory:FileLocation = null) {
		super(type, false, false);

		_arguments = arguments;
		_buildDirectory = buildDirectory;
	}

	public function get_arguments():Array<String> {
		return _arguments;
	}

	public function get_buildDirectory():FileLocation {
		return _buildDirectory;
	}
}