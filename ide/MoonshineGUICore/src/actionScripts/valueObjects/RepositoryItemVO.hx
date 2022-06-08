package actionScripts.valueObjects;

class RepositoryItemVO {
	public var type:String; // VersionControlTypes
	public var isRoot:Bool;
	public var isDownloadable:Bool;
	public var isDefault:Bool;

	// this will help access to top level object from anywhere deep
	// in-tree objects to gain top level properties
	// ideally to get/update user authentication
	public var udid:String;

	public function new() {}

	private var _url:String;

	public var url(get, set):String;

	private function get_url():String {
		return _url;
	}

	private function set_url(value:String):String {
		_url = value;
		return _url;
	}

	private var _label:String;

	public var label(get, set):String;

	private function get_label():String {
		return _label;
	}

	private function set_label(value:String):String {
		_label = value;
		return _label;
	}

	private var _notes:String;

	public var notes(get, set):String;

	private function get_notes():String {
		return _notes;
	}

	private function set_notes(value:String):String {
		_notes = value;
		return _notes;
	}

	private var _userName:String;

	public var userName(get, set):String;

	private function get_userName():String {
		return _userName;
	}

	private function set_userName(value:String):String {
		_userName = value;
		return _userName;
	}

	private var _userPassword:String;

	public var userPassword(get, set):String;

	private function get_userPassword():String {
		return _userPassword;
	}

	private function set_userPassword(value:String):String {
		_userPassword = value;
		return _userPassword;
	}

	private var _isRequireAuthentication:Bool;

	public var isRequireAuthentication(get, set):Bool;

	private function get_isRequireAuthentication():Bool {
		return _isRequireAuthentication;
	}

	private function set_isRequireAuthentication(value:Bool):Bool {
		_isRequireAuthentication = value;
		return _isRequireAuthentication;
	}

	private var _isTrustCertificate:Bool;

	public var isTrustCertificate(get, set):Bool;

	private function get_isTrustCertificate():Bool {
		return _isTrustCertificate;
	}

	private function set_isTrustCertificate(value:Bool):Bool {
		_isTrustCertificate = value;
		return _isTrustCertificate;
	}

	private var _children:Array<Dynamic>;

	public var children(get, set):Array<Dynamic>;

	private function get_children():Array<Dynamic> {
		return _children;
	}

	private function set_children(value:Array<Dynamic>):Array<Dynamic> {
		_children = value;
		return _children;
	}

	private var _isUpdating:Bool;

	public var isUpdating(get, set):Bool;

	private function get_isUpdating():Bool {
		return _isUpdating;
	}

	private function set_isUpdating(value:Bool):Bool {
		_isUpdating = value;
		return _isUpdating;
	}

	private var _pathToDownloaded:String;

	public var pathToDownloaded(get, set):String;

	private function get_pathToDownloaded():String {
		return _pathToDownloaded;
	}

	private function set_pathToDownloaded(value:String):String {
		_pathToDownloaded = value;
		return _pathToDownloaded;
	}
}