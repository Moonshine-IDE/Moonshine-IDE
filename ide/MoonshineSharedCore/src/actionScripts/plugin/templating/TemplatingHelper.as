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
package actionScripts.plugin.templating
{
	import actionScripts.factory.FileLocation;
	import actionScripts.utils.TextUtil;
	import actionScripts.valueObjects.ConstantsCoreVO;

	public class TemplatingHelper
	{
		// Replace values for templates {$ProjectName:"My New Project"}
		public var templatingData:Object = {};
		public var isProjectFromExistingSource:Boolean;
		
		public function fileTemplate(fromTemplate:FileLocation, toFile:FileLocation):void
		{
			if (ConstantsCoreVO.IS_AIR) 
			{
				toFile.fileBridge.createFile();
				fromTemplate.fileBridge.copyFileTemplate(toFile, templatingData);
			}
		}
		
		public function projectTemplate(fromDir:FileLocation, toDir:FileLocation):void
		{
			copyFiles(fromDir, toDir);
		}
		
		private function copyFiles(fromDir:FileLocation, toDir:FileLocation):void
		{
			var files:Array = fromDir.fileBridge.getDirectoryListing();
			var newFile:FileLocation;
			var template:Boolean;
			
			for each (var file:Object in files)
			{
				file = new FileLocation(file.nativePath);
				if (FileLocation(file).fileBridge.isDirectory)
				{
					// do not copy stocked 'src' folder if user choose to create a project with his/her existing source
					if (!isProjectFromExistingSource || (isProjectFromExistingSource && FileLocation(file).fileBridge.name != "src"))
					{
						if (ConstantsCoreVO.IS_AIR)
						{
							newFile = toDir.resolvePath(templatedFileName(file as FileLocation));
							newFile.fileBridge.createDirectory();
						}
						
						copyFiles(file as FileLocation, newFile);
					}
				}
				else
				{
					template = (FileLocation(file).fileBridge.name.indexOf(".template") > -1);
					
					if (ConstantsCoreVO.IS_AIR) newFile = toDir.resolvePath(templatedFileName(file as FileLocation));
					try
					{
						if (template) file.fileBridge.copyFileTemplate(newFile, templatingData);
						else copyFileContents(file as FileLocation, newFile);
					} catch(e:Error){}
				}
			}
		}
		
		private function templatedFileName(src:FileLocation):String
		{
			var name:String = src.fileBridge.name;
			if (name.indexOf("$") > -1)
			{
				var m:int;
				for (var key:String in templatingData)
				{
					m = name.indexOf(key);	
					if (m > -1)
					{
						name = name.substr(0, m) + templatingData[key] + name.substr(m+key.length); 
					}
				}
			}
			
			if (name.indexOf(".template") > -1)
			{
				name = name.substr(0, name.indexOf(".template"));
			}
			
			return name;
		}
		
		private function copyFileContents(src:FileLocation, dst:FileLocation):void
		{
			src.fileBridge.copyTo(dst);
		}
		
		public static function replace(content:String, data:Object):String
		{
			for (var key:String in data)
			{
				var re:RegExp = new RegExp(TextUtil.escapeRegex(key), "g");
				content = content.replace(re, data[key]);
			}
			
			return content;
		}
		
		public static function getTemplateLabel(template:FileLocation):String
		{
			var name:String = template.fileBridge.name;
			
			name = stripTemplate(name);
			
			if (name.indexOf(".") > -1)
			{
				name = name.substr(0, name.indexOf("."));
			}
			
			return name;
		}
		
		public static function stripTemplate(from:String):String
		{
			if (from.indexOf(".template") > -1)
			{
				from = from.substr(0, from.indexOf(".template"));
			}
			
			return from;
		}
		
		public static function getExtension(template:FileLocation):String
		{
			var name:String = stripTemplate(template.fileBridge.name);
			
			if (name.lastIndexOf(".") > -1)
			{
				return name.substr( name.lastIndexOf(".")+1 );	
			}
			
			return null;
		}
		
	}
}