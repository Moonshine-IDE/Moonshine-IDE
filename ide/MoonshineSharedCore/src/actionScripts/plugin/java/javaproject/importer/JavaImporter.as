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
package actionScripts.plugin.java.javaproject.importer
{
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.core.importer.FlashDevelopImporterBase;
	import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
	import flash.filesystem.File;
	import actionScripts.ui.menu.vo.ProjectMenuTypes;
	import actionScripts.utils.MavenPomUtil;

	public class JavaImporter extends FlashDevelopImporterBase
	{
		private static const FILE_EXTENSION_JAVAPROJ:String = ".javaproj";
		private static const FILE_NAME_POM_XML:String = "pom.xml";
		private static const FILE_NAME_BUILD_GRADLE:String = "build.gradle";

		public static function test(file:Object):FileLocation
		{
			if (!file.exists)
			{
				return null;
			}

			var srcMainJava:File = file.resolvePath("src");
			if (!srcMainJava.exists || !srcMainJava.isDirectory)
			{
				return null;
			}

			var listing:Array = file.getDirectoryListing();
			var projectFile:FileLocation = null;
			var pomFile:FileLocation = null;
			var gradleFile:FileLocation = null;
			for each (var i:Object in listing)
			{
				var fileName:String = i.name;
				if (fileName == FILE_NAME_POM_XML)
				{
					pomFile = new FileLocation(i.nativePath);
				}
				else if (fileName == FILE_NAME_BUILD_GRADLE)
				{
					gradleFile = new FileLocation(i.nativePath);
				}
				else
				{
					var extensionIndex:int = fileName.lastIndexOf(FILE_EXTENSION_JAVAPROJ);
					if(extensionIndex != -1 && extensionIndex == (fileName.length - FILE_EXTENSION_JAVAPROJ.length))
					{
						projectFile = new FileLocation(i.nativePath);
					}
				}
			}

			if(projectFile)
			{
				if(pomFile)
				{
					return pomFile;
				}
				else if(gradleFile)
				{
					return gradleFile;
				}
			}
			
			return null;
		}

		public static function parse(projectFolder:FileLocation, projectName:String=null, settingsFileLocation:FileLocation = null):JavaProjectVO
		{
			if(!projectName)
			{
				var airFile:Object = projectFolder.fileBridge.getFile;
				projectName = airFile.name;
			}

            if (!settingsFileLocation)
            {
                settingsFileLocation = projectFolder.fileBridge.resolvePath(projectName + FILE_EXTENSION_JAVAPROJ);
            }

            var javaProject:JavaProjectVO = new JavaProjectVO(projectFolder, projectName);
			//javaProject.menuType = ProjectMenuTypes.JAVA;

            var sourceDirectory:String = null;
			var settingsData:XML = null;
			if (settingsFileLocation.fileBridge.exists)
			{
				settingsData = new XML(settingsFileLocation.fileBridge.read());
            }

			var separator:String = javaProject.projectFolder.file.fileBridge.separator;

			const defaultSourceFolderPath:String = "src".concat(separator, "main", separator, "java");

			if (javaProject.hasPom())
			{
				if (settingsData)
				{
					javaProject.mavenBuildOptions.parse(settingsData.mavenBuild);
				}

				var pomFile:FileLocation = new FileLocation(
						javaProject.mavenBuildOptions.buildPath.concat(separator, FILE_NAME_POM_XML)
				);

				sourceDirectory = MavenPomUtil.getProjectSourceDirectory(pomFile);
				if (!sourceDirectory)
				{
					sourceDirectory = defaultSourceFolderPath;
				}

				javaProject.mainClassName = MavenPomUtil.getMainClassName(pomFile);
			}
			else
			{
				if (javaProject.hasGradleBuild() && settingsData)
				{
					javaProject.gradleBuildOptions.parse(settingsData.gradleBuild);
				}

				if (settingsData)
				{
					parsePaths(settingsData.classpaths["class"], javaProject.classpaths, javaProject, "path");
					javaProject.mainClassName = settingsData.build.option.@mainclass;
					javaProject.mainClassPath = settingsData.build.option.@mainClassPath;
				}

				if (javaProject.classpaths.length > 0)
				{
					sourceDirectory = javaProject.classpaths[0].fileBridge.nativePath;
				}
			}

			addSourceDirectoryToProject(javaProject, sourceDirectory);
			if (javaProject.classpaths.length == 0)
			{
				javaProject.classpaths.push(javaProject.sourceFolder);
			}

			if (!javaProject.mainClassName)
			{
				javaProject.mainClassName = projectName;
			}

			return javaProject;
		}

		private static function addSourceDirectoryToProject(javaProject:JavaProjectVO, sourceDirectory:String):void
		{
			if (sourceDirectory)
			{
				javaProject.sourceFolder = javaProject.projectFolder.file.fileBridge.resolvePath(sourceDirectory);
			}

			if (!sourceDirectory || !javaProject.sourceFolder.fileBridge.exists)
			{
				javaProject.sourceFolder = javaProject.projectFolder.file.fileBridge.resolvePath("src");
			}
		}
	}
}