package actionScripts.valueObjects;

class MobileDeviceVO {
	public static final AND:String = "AND";
	public static final IOS:String = "IOS";

	public var type:String = AND;
	public var isDefault:Bool;

	public function new(name:String = null, key:String = null, type:String = null, dpi:String = "", isDefault:Bool = false) {
		this.name = name;
		this.key = key;
		this.type = type;
		this.dpi = dpi;
		this.isDefault = isDefault;
	}

	private var _name:String;

	public var name(get, set):String;

	private function get_name():String {
		return _name;
	}

	private function set_name(value:String):String {
		_name = value;
		return _name;
	}

	private var _key:String;

	public var key(get, set):String;

	private function get_key():String {
		return _key;
	}

	private function set_key(value:String):String {
		_key = value;
		return _key;
	}

	private var _dpi:String = "";

	public var dpi(get, set):String;

	private function get_dpi():String {
		return _dpi;
	}

	private function set_dpi(value:String):String {
		_dpi = value;
		return _dpi;
	}
}