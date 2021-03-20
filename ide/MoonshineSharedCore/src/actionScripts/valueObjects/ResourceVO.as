////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
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