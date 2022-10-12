package actionScripts.utils;

import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;

class FileCoreUtil {
	public static function copyPathToClipboard(file:FileLocation):Void {
		IDEModel.getInstance().clipboardCore.copyText(file.fileBridge.nativePath);
	}

	public static function showInExplorer(file:FileLocation):Void {
		if (file.fileBridge.isDirectory) {
			file.fileBridge.openWithDefaultApplication();
		} else {
			file = file.fileBridge.parent;
			file.fileBridge.openWithDefaultApplication();
		}
	}

	public static function contains(dir:FileLocation, file:FileLocation):Bool {
		if (file.fileBridge.nativePath.indexOf(dir.fileBridge.nativePath) == 0)
			return true;
		return false;
	}
}