package actionScripts.valueObjects;

import actionScripts.locator.IDEModel;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import moonshine.utils.flexbridge.ArrayCollectionUtil;

class ResourceVO {
	public var name:String;
	public var sourceWrapper:FileWrapper;

	private var _resourcePath:String;

	public var resourcePath(get, set):String;

	private var _resourceExtension:String;

	public var resourceExtension(get, never):String;

	private var _projectName:String;

	public var resourcePathWithoutRoot(get, never):String;

	private var sourcePath:String;

	public function new(_name:String, _sourceWrapper:FileWrapper = null) {
		name = _name;
		if (_sourceWrapper != null) {
			resourcePath = _sourceWrapper.file.fileBridge.nativePath;
			_resourceExtension = _sourceWrapper.file.fileBridge.extension;
			sourceWrapper = _sourceWrapper;
		}
	}

	private function set_resourcePath(value:String):String {
		for (project in ArrayCollectionUtil.fromMXCollection(IDEModel.getInstance().projects)) {
			var folderPath:String = project.folderPath;
			if (!ConstantsCoreVO.IS_AIR)
				folderPath = folderPath.substr(project.folderPath.indexOf("?path=") + 7, folderPath.length);
			if (value.indexOf(folderPath) != -1) {
				value = StringTools.replace(value, folderPath, project.name);
				_resourcePath = value;
				_projectName = project.name;
				var as3Project:AS3ProjectVO = cast(project, AS3ProjectVO);
				if (as3Project != null) {
					sourcePath = StringTools.replace(as3Project.sourceFolder.fileBridge.nativePath, folderPath, "");
				}

				break;
			}
		}
		return value;
	}

	private function get_resourcePath():String {
		return "";
	}

	private function get_resourceExtension():String {
		return _resourceExtension;
	}

	private function get_resourcePathWithoutRoot():String {
		if (sourcePath != null && _projectName != null) {
			var resourcePathWithoutRoot:String = StringTools.replace(_resourcePath, _projectName, "");
			return StringTools.replace(resourcePathWithoutRoot, sourcePath + sourceWrapper.file.fileBridge.separator, "");
		}

		return _resourcePath;
	}
}