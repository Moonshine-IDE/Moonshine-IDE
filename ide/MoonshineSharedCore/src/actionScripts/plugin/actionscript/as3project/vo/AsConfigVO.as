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
package actionScripts.plugin.actionscript.as3project.vo
{
	import __AS3__.vec.Vector;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.valueObjects.FileWrapper;
	
	public class AsConfigVO extends FileWrapper
	{
		public function AsConfigVO(file:FileLocation=null)
		{
			super(file);
		}

		public function write(pvo:AS3ProjectVO):void 
		{
			if (pvo.targets.length == 0 && !pvo.isLibraryProject) 
			{
				// No targets found for config construction.
				return;
			}
			
			if (pvo.isLibraryProject)
			{

			}
			else
			{
				writeAsConfig(pvo);
			}
		}

		private function writeAsConfig(pvo:AS3ProjectVO):void
		{
			var asConfig:Object = {};
			var appDescFile:String = "";
			if (pvo.targets.length > 0)
			{
				// considering that application descriptor file should exists in the same
				// root where application source file is exist
				var appFileName:String = pvo.targets[0].fileBridge.name.split(".")[0];
				if (pvo.targets[0].fileBridge.parent.fileBridge.resolvePath("application.xml").fileBridge.exists)
				{
					appDescFile = "src/application.xml";
				}
				else if (pvo.targets[0].fileBridge.parent.fileBridge.resolvePath(appFileName +"-app.xml").fileBridge.exists)
				{
					appDescFile = "src/" + appFileName + "-app.xml";
				}

				asConfig.mainClass = pvo.targets[0].fileBridge.nameWithoutExtension;
			}

			if (pvo.air)
			{
				asConfig.config = "air";
				asConfig.application = appDescFile;
			}

			asConfig.compilerOptions = pvo.toComplerOptions();
			if (pvo.buildOptions.additional)
			{
				asConfig.additionalOptions = pvo.buildOptions.additional;
			}

			var asconfigStr:String = JSON.stringify(asConfig);
			saveAsConfig(asconfigStr, pvo);
		}

		private function saveAsConfig(data:String, pvo:AS3ProjectVO):void
		{
			if (!file)
			{
				file = pvo.projectFolder.file.fileBridge.resolvePath(pvo.projectName + "-asconfig.json");
			}

			// Write file
			file.fileBridge.save(data);
		}
	}
}