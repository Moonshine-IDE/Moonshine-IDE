package actionScripts.valueObjects;

class URLDescriptorVO {
	public static var BASE_URL:String = "";

	@:meta(Bindable("change"))
	public static var BASE_URL_MIRROR:String;
	public static var BASE_URL_PROTOCOL:String = "";
	public static var FILE_OPEN:String;
	public static var FILE_MODIFY:String;
	public static var FILE_REMOVE:String;
	public static var FILE_NEW:String;
	public static var FILE_RENAME:String;
	public static var PROJECT_DIR:String;
	public static var PROJECT_REMOVE:String;
	public static var PROJECT_COMPILE:String;
	public static var LOGIN_TEST:String;
	public static var LOGIN_USER:String;
	public static var CREATE_NEW_PROJECT:String;
	public static var CONFIG:String;
	public static var LOGIN_USER_FIELD_2SEND2_SERVER:String = "username";
	public static var LOGIN_PASSWORD_FIELD_2SEND2_SERVER:String = "password";

	public static function updateURLs():Void {
		FILE_OPEN = BASE_URL + "MoonShineServer/doFileGet";
		FILE_MODIFY = BASE_URL + "MoonShineServer/doFilePut";
		FILE_REMOVE = BASE_URL + "MoonShineServer/doFileDelete";
		FILE_NEW = BASE_URL + "MoonShineServer/doFilePost";
		FILE_RENAME = BASE_URL + "MoonShineServer/doFileReName";
		PROJECT_DIR = BASE_URL + "MoonShineServer/listAllFile?path=/";
		PROJECT_REMOVE = BASE_URL + "MoonShineServer/deleteProject";
		PROJECT_COMPILE = BASE_URL + "MoonShineServer/executeFlex";
		CONFIG = BASE_URL + "MoonShineServer/config";
		LOGIN_TEST = BASE_URL + "admin/status"; // "Grails4NotesBroker/login/status"
		LOGIN_USER = BASE_URL + "admin/auth";
		CREATE_NEW_PROJECT = BASE_URL + "MoonShineServer/doProjectCreate";
	}
}