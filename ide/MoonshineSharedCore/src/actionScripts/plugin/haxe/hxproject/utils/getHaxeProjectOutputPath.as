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
package actionScripts.plugin.haxe.hxproject.utils
{
	import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;
	import actionScripts.factory.FileLocation;

	public function getHaxeProjectOutputPath(project:HaxeProjectVO):String
	{
		var outputFolder:FileLocation = project.haxeOutput.path;
		if(outputFolder == null)
		{
			return null;
		}
		else if(outputFolder.name.indexOf(".") != -1)
		{
			outputFolder = outputFolder.fileBridge.parent;
		}
		var fileExtension:String = getHaxeProjectOutputFileExtension(project);
		if(fileExtension == null)
		{
			return outputFolder.fileBridge.nativePath;
		}
		return outputFolder.resolvePath(project.name + fileExtension).fileBridge.nativePath;
	}
}