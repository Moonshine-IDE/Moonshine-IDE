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
package actionScripts.plugin.genericproj.importer
{
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.core.importer.FlashDevelopImporterBase;
	import actionScripts.plugin.genericproj.vo.GenericProjectVO;
	import actionScripts.plugin.ondiskproj.vo.OnDiskProjectVO;
	import actionScripts.ui.menu.vo.ProjectMenuTypes;
	import actionScripts.utils.MavenPomUtil;
	import actionScripts.utils.SerializeUtil;
	import actionScripts.utils.UtilsCore;
	import flash.filesystem.File;

	public class GenericProjectImporter extends FlashDevelopImporterBase
	{
		private static const FILE_EXTENSION_GENERICPROJ:String = ".genericproj";
		private static const FILE_NAME_POM_XML:String = "pom.xml";

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
				var extensionIndex:int = fileName.lastIndexOf(FILE_EXTENSION_GENERICPROJ);
				if(extensionIndex != -1 && extensionIndex == (fileName.length - FILE_EXTENSION_GENERICPROJ.length))
				{
					return new FileLocation(i.nativePath);
				}
			}
			
			return null;
		}

		public static function parse(projectFolder:FileLocation, projectName:String=null, settingsFileLocation:FileLocation = null):GenericProjectVO
		{
			if (!projectName)
			{
				var airFile:Object = projectFolder.fileBridge.getFile;
				projectName = airFile.name;
			}

            if (!settingsFileLocation)
            {
                settingsFileLocation = projectFolder.fileBridge.resolvePath(projectName + FILE_EXTENSION_GENERICPROJ);
            }

			var project:GenericProjectVO = new GenericProjectVO(projectFolder, projectName);
			var separator:String = IDEModel.getInstance().fileCore.separator;

			project.projectFile = settingsFileLocation;
			
			var settingsData:XML;
			if (settingsFileLocation.fileBridge.exists)
			{
				settingsData = new XML(settingsFileLocation.fileBridge.read());
			}
			
			// Parse XML file
			if (project.hasPom() && settingsData)
			{
				project.mavenBuildOptions.parse(settingsData.mavenBuild);
			}

			if (project.hasGradleBuild() && settingsData)
			{
				project.gradleBuildOptions.parse(settingsData.gradleBuild);
			}

			if (settingsData)
			{
				project.buildOptions.parse(settingsData.build);
				if (!project.buildOptions.antBuildPath)
				{
					project.isAntFileAvailable = project.hasAnt();
				}
				else
				{
					project.isAntFileAvailable = true;
				}
			}

			project.menuType = ProjectMenuTypes.GENERIC;
			return project;
		}
	}
}