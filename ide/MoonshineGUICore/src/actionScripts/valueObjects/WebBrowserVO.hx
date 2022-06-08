package actionScripts.valueObjects;

class WebBrowserVO {
	public var isDefault:Bool;

	public function new(name:String = null, debugAdapterType:String = null, isDefault:Bool = false) {
		this.name = name;
		this.debugAdapterType = debugAdapterType;
		this.isDefault = isDefault;
	}

	private var _name:String;

	public var name(get, set):String;

	public function get_name():String {
		return _name;
	}

	public function set_name(value:String):String {
		_name = value;
		return _name;
	}

	private var _debugAdapterType:String;

	public var debugAdapterType(get, set):String;

	public function get_debugAdapterType():String {
		return _debugAdapterType;
	}

	public function set_debugAdapterType(value:String):String {
		_debugAdapterType = value;
		return _debugAdapterType;
	}
}