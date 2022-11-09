////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////

package actionScripts.valueObjects;

import actionScripts.locator.IDEModel;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import moonshine.flexbridge.CollectionUtil;

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
		for (project in CollectionUtil.fromMXCollection(IDEModel.getInstance().projects)) {
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