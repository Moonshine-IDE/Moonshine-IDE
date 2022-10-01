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
package actionScripts.valueObjects
{
	import actionScripts.locator.IDEModel;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;

    public class ResourceVO
	{
		public var name:String;
		public var sourceWrapper:FileWrapper;
		
		private var _resourcePath:String;
		private var _resourceExtension:String;
		private var _projectName:String;

		private var sourcePath:String;

		public function ResourceVO(_name:String, _sourceWrapper:FileWrapper=null)
		{
			name = _name;
			if (_sourceWrapper)
			{
				resourcePath = _sourceWrapper.file.fileBridge.nativePath;
				_resourceExtension = _sourceWrapper.file.fileBridge.extension;
				sourceWrapper = _sourceWrapper;
			}
		}
		
		public function set resourcePath(value:String):void
		{
			for each (var project:ProjectVO in IDEModel.getInstance().projects)
			{
				var folderPath:String = project.folderPath;
				if (!ConstantsCoreVO.IS_AIR) folderPath = folderPath.substr(project.folderPath.indexOf("?path=") + 7, folderPath.length);
				if (value.indexOf(folderPath) != -1)
				{
					value = value.replace(folderPath, project.name);
					_resourcePath = value;
					_projectName = project.name;
					var as3Project:AS3ProjectVO = project as AS3ProjectVO;
					if (as3Project)
					{
						sourcePath = as3Project.sourceFolder.fileBridge.nativePath.replace(folderPath, "");
					}

					break;
				}
			}
		}
		
		public function get resourcePath():String
		{
			return "";
		}

		public function get resourceExtension():String
		{
			return _resourceExtension;
		}
		
		public function get resourcePathWithoutRoot():String
		{
			if (sourcePath && _projectName)
			{
                var resourcePathWithoutRoot:String = _resourcePath.replace(_projectName, "");
				return resourcePathWithoutRoot.replace(sourcePath + sourceWrapper.file.fileBridge.separator, "");
            }
			
			return _resourcePath;
		}
	}
}