package actionScripts.valueObjects;

class RoyaleOutputTarget {
	private var _name:String;
	private var _version:String;
	private var _airVersion:String;
	private var _flashVersion:String;

	public var name(get, null):String;
	public var version(get, null):String;
	public var airVersion(get, null):String;
	public var flashVersion(get, null):String;

	public function new(name:String, version:String, airVersion:String = null, flashVersion:String = null) {
		_name = name;
		_version = version;
		_airVersion = airVersion;
		_flashVersion = flashVersion;
	}

	public function get_name():String {
		return _name;
	}

	public function get_version():String {
		return _version;
	}

	public function get_airVersion():String {
		return _airVersion;
	}

	public function get_flashVersion():String {
		return _flashVersion;
	}
}