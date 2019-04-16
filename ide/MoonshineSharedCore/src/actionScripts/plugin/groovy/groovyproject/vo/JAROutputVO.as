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
package actionScripts.plugin.groovy.groovyproject.vo
{
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.utils.SDKUtils;
    import actionScripts.utils.SerializeUtil;
    import actionScripts.utils.TextUtil;
	import actionScripts.utils.UtilsCore;

	public class JAROutputVO 
	{
		public var path:FileLocation;
		
		public function toString():String {
			return "[JAROutput path='"+path.fileBridge.nativePath+"']";
		}
		
		public function parse(output:XMLList, project:GroovyProjectVO):void 
		{
			var params:XMLList = output.option;
			path = project.folderLocation.resolvePath(UtilsCore.fixSlashes(params.@path));
		}
		
		/*
			Returns XML representation of this class.
			If root is set you will get relative paths
		*/
		public function toXML(folder:FileLocation):XML
		{
			var output:XML = <output/>;
			
			var pathStr:String = path.fileBridge.nativePath;
			if (folder) {
				pathStr = folder.fileBridge.getRelativePath(path);
			}
			
			// in case parsing relative path returns null
			// particularly in scenario when "path" is outside folder
			// of "folder"
			if (!pathStr) pathStr = path.fileBridge.nativePath;
			
			var outputPairs:Object = {
				'path'		:	pathStr
			}
			
			output.appendChild(SerializeUtil.serializePairs(outputPairs, <option/>));
				
			return output;
		}
	}
}