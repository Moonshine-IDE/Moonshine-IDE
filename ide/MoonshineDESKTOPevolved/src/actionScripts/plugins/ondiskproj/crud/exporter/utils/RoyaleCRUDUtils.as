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
package actionScripts.plugins.ondiskproj.crud.exporter.utils
{
	import mx.collections.ArrayCollection;
	
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.ResourceVO;

	public class RoyaleCRUDUtils
	{
		private static var fileName:String;
		
		public static function getImportReferenceFor(fileNameWithExtension:String, project:ProjectVO, extensions:Array=null):String
		{
			var files:ArrayCollection = new ArrayCollection();
			UtilsCore.parseFilesList(files, project, extensions, true);
			
			fileName = fileNameWithExtension;
			files.filterFunction = resourceFilterFunction;
			files.refresh();
			
			if (files.length > 0) 
			{
				var path:String =  project.sourceFolder.fileBridge.getRelativePath(
										(files[0] as ResourceVO).sourceWrapper.file, 
										true
									);
				if (path.indexOf("/") != -1) path = path.replace(/\//gi, ".");
				return path.substr(0, path.length - ((files[0] as ResourceVO).resourceExtension.length + 1));
			}
			return null;
		}
		
		private static function resourceFilterFunction(item:ResourceVO):Boolean
		{
			var itemName:String = item.name.toLowerCase();
			return (itemName == fileName.toLowerCase());
		}
	}
}