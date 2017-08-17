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
package actionScripts.plugin.core.importer
{
	import actionScripts.factory.FileLocation;
	import actionScripts.utils.OSXBookmarkerNotifiers;
	import actionScripts.valueObjects.ProjectVO;
	
	public class FlashBuilderImporterBase extends ProjectImporterBase
	{
		private static const SEARCH_BACK_COUNT:int = 5;
		
		protected static function parsePaths(paths:XMLList, v:Vector.<FileLocation>, p:ProjectVO, attrName:String="path", documentPath:String=null):void 
		{
			for each (var pathXML:XML in paths)
			{
				var path:String = pathXML.attribute(attrName);
				var f:FileLocation;
				if (documentPath && (path.indexOf("${DOCUMENTS}") != -1)) 
				{
					path = path.replace("${DOCUMENTS}", "");
					path = documentPath + path;
					f = p.folderLocation.resolvePath(path);
				}
				else if (path.indexOf("${DOCUMENTS}") != -1)
				{
					// since we didn't found {DOCUMENTS} path in
					// FlashBuilderImporter.readActionScriptSettings(), we take
					// {DOCUMENTS} as p.folderLocation.parent to make the
					// fileLocation valid, else it'll throw error
					var isParentPathAvailable:Boolean = true;
					CONFIG::OSX
					{
						isParentPathAvailable = checkOSXBookmarked(p.folderLocation.fileBridge.parent.fileBridge.nativePath);
					}
					
					if (isParentPathAvailable)
					{
						path = path.replace("${DOCUMENTS}", "");
						path = p.folderLocation.fileBridge.parent.fileBridge.nativePath + path;
						f = p.folderLocation.resolvePath(path);
					}
					else
					{
						f = p.folderLocation.resolvePath(path);
					}
				}
				else
				{
					f = p.folderLocation.resolvePath(path);
				}
				
				if (f && f.fileBridge.exists) f.fileBridge.canonicalize();
				if (f) v.push(f);
			}
		}
		
		public static function checkOSXBookmarked(pathValue:String):Boolean
		{
			var tmpBList: Array = (OSXBookmarkerNotifiers.availableBookmarkedPaths) ? OSXBookmarkerNotifiers.availableBookmarkedPaths.split(",") : [];
			if (tmpBList.length >= 1)
			{
				if (tmpBList[0] == "") tmpBList.shift(); // [0] will always blank
				if (tmpBList[0] == "INITIALIZED") tmpBList.shift(); // very first time initialization after Moonshine installation
			}
			
			if (tmpBList.indexOf(pathValue) != -1) return true;
			else
			{
				for each(var j:String in tmpBList)
				{
					if (pathValue.indexOf(j) != -1)	return true;
				}
			}
			
			return false;
		}
	}
}