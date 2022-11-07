package actionScripts.utils;

class XMLUtils {
	public static function specialCharacterCheck(inputStr:String):Bool {
		var result:Bool = false;
		if (inputStr.indexOf(">") >= 0) {
			result = true;
		}
		if (inputStr.indexOf("&") >= 0) {
			result = true;
		}
		if (inputStr.indexOf("\'") >= 0) {
			result = true;
		}
		if (inputStr.indexOf("<") >= 0) {
			result = true;
		}
		if (inputStr.indexOf("\"") >= 0) {
			result = true;
		}
		return result;
	}
}