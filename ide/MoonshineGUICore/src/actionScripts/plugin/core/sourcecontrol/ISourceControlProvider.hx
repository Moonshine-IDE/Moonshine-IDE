package actionScripts.plugin.core.sourcecontrol;

import actionScripts.factory.FileLocation;

interface ISourceControlProvider {
	var systemNameShort(get, never):String;
	function getStatus(filePath:String):String;
	function getTreeRightClickMenu(file:FileLocation):Dynamic;
	function refresh(file:FileLocation):Void;
	function remove(file:FileLocation):Void;
}