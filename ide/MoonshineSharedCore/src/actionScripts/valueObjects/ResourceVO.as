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

	public class ResourceVO
	{
		public var name: String;
		public var sourceWrapper: FileWrapper;
		
		private var _resourcePath: String;

		public function ResourceVO(_name:String, _sourceWrapper:FileWrapper)
		{
			name = _name;
			resourcePath = _sourceWrapper.file.fileBridge.nativePath;
			sourceWrapper = _sourceWrapper;
		}
		
		public function set resourcePath(value:String):void
		{
			for each (var i:ProjectVO in IDEModel.getInstance().projects)
			{
				var folderPath:String = i.folderPath;
				if (!ConstantsCoreVO.IS_AIR) folderPath = folderPath.substr(i.folderPath.indexOf("?path=") + 7, folderPath.length);
				if (value.indexOf(folderPath) != -1)
				{
					value = value.replace(folderPath, i.name);
					_resourcePath = value;
					break;
				}
			}
		}
		
		public function get resourcePath():String
		{
			return _resourcePath;
		}
	}
}