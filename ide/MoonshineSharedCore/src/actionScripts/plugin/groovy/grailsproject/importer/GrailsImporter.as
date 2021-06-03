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
package actionScripts.plugin.groovy.grailsproject.importer
{
	import actionScripts.factory.FileLocation;
	import actionScripts.utils.SerializeUtil;

	import flash.filesystem.File;
	import actionScripts.plugin.groovy.grailsproject.vo.GrailsProjectVO;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import actionScripts.plugin.core.importer.FlashDevelopImporterBase;
	import actionScripts.ui.menu.vo.ProjectMenuTypes;

	public class GrailsImporter extends FlashDevelopImporterBase
	{
		private static const FILE_EXTENSION_GRAILSPROJ:String = ".grailsproj";

		public static function test(file:Object):FileLocation
		{
			if (!file.exists)
			{
				return null;
			}

			var listing:Array = file.getDirectoryListing();
			for each (var i:Object in listing)
			{
				var fileName:String = i.name;
				var extensionIndex:int = fileName.lastIndexOf(FILE_EXTENSION_GRAILSPROJ);
				if(extensionIndex != -1 && extensionIndex == (fileName.length - FILE_EXTENSION_GRAILSPROJ.length))
				{
					return new FileLocation(i.nativePath);
				}
			}
			
			return null;
		}

		public static function parse(projectFolder:FileLocation, projectName:String=null, settingsFileLocation:FileLocation = null):GrailsProjectVO
		{
			if(!projectName)
			{
				var airFile:Object = projectFolder.fileBridge.getFile;
				projectName = airFile.name;
			}

            if (!settingsFileLocation)
            {
                settingsFileLocation = projectFolder.fileBridge.resolvePath(projectName + FILE_EXTENSION_GRAILSPROJ);
            }

			var project:GrailsProjectVO = new GrailsProjectVO(projectFolder, projectName);
			//project.menuType = ProjectMenuTypes.GRAILS;

			project.projectFile = settingsFileLocation;
			
			var data:XML;
			if (settingsFileLocation.fileBridge.exists)
			{
				var stream:FileStream = new FileStream();
				stream.open(settingsFileLocation.fileBridge.getFile as File, FileMode.READ);
				data = XML(stream.readUTFBytes(settingsFileLocation.fileBridge.getFile.size));
				stream.close();
			}
			
            project.classpaths.length = 0;
			
			if (data)
			{
				project.grailsBuildOptions.parse(data.grailsBuild);
				project.gradleBuildOptions.parse(data.gradleBuild);
				parsePaths(data.classpaths["class"], project.classpaths, project, "path");
			}

			var separator:String = projectFolder.fileBridge.separator;
			project.sourceFolder = projectFolder.resolvePath("src" + separator + "main" + separator + "groovy");

			var hasLocation:Boolean = project.classpaths.some(
					function(item:FileLocation, index:int, vector:Vector.<FileLocation>):Boolean{
						return item.fileBridge.nativePath == project.sourceFolder.fileBridge.nativePath;
					});

			if (project.classpaths.length == 0 || !hasLocation)
			{
				project.classpaths.push(project.sourceFolder);
			}

			if (data && data.options.option.hasOwnProperty('@jdkType'))
			{
				project.jdkType = SerializeUtil.deserializeString(data.options.option.@jdkType);
			}

			return project;
		}
	}
}