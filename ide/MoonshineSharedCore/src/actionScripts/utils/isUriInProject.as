////////////////////////////////////////////////////////////////////////////////
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
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
// 
////////////////////////////////////////////////////////////////////////////////
package actionScripts.utils
{
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;

	public function isUriInProject(uri:String, project:ProjectVO):Boolean
	{
		var fileForUri:FileLocation = new FileLocation(uri, true);
		var projectFile:FileLocation = new FileLocation(project.folderPath, false);
		//getRelativePath() will return null if fileForUri is not in the
		//projectFile directory
		if(projectFile.fileBridge.getRelativePath(fileForUri, false) !== null)
		{
			return true;
		}
		if(project is AS3ProjectVO)
		{
			var as3Project:AS3ProjectVO = AS3ProjectVO(project);
			var sourcePaths:Vector.<FileLocation> = as3Project.classpaths;
			var sourcePathCount:int = sourcePaths.length;
			for(var i:int = 0; i < sourcePathCount; i++)
			{
				var sourcePath:FileLocation = sourcePaths[i];
				if(sourcePath.fileBridge.getRelativePath(fileForUri, false) !== null)
				{
					return true;
				}
			}
			var sdkPath:String = getProjectSDKPath(project, IDEModel.getInstance());
			if(sdkPath != null)
			{
				var sdkFile:FileLocation = new FileLocation(sdkPath, false);
				if(sdkFile.fileBridge.getRelativePath(fileForUri, false) !== null)
				{
					return true;
				}
			}
		}
		return false;
	}
}
