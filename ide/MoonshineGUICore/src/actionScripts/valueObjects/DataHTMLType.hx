package actionScripts.valueObjects;

class DataHTMLType {
	public static final SESSION_ERROR:String = "SESSION_ERROR";
	public static final LOGIN_ERROR:String = "LOGIN_ERROR";
	public static final DATA_ERROR:String = "DATA_ERROR";
	public static final LOGIN_SUCCESS:String = "LOGIN_SUCCESS";

	public var message:String;
	public var type:String;
	public var isError:Bool;

	public function new() {}
}