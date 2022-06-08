package actionScripts.valueObjects;

class UserAuthVO {
	public function new() {}

	private var username:String = "";
	private var pwd:String = "";

	public var UserName(get, set):String;

	public function get_UserName():String {
		return username;
	}

	public function set_UserName(uname:String):String {
		username = uname;
		return username;
	}

	public var Password(get, set):String;

	public function get_Password():String {
		return pwd;
	}

	public function set_Password(password:String):String {
		pwd = password;
		return pwd;
	}
}