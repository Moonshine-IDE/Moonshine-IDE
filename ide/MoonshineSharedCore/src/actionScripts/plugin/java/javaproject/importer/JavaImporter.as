////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugin.java.javaproject.importer
{
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.core.importer.FlashDevelopImporterBase;
	import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
	import actionScripts.utils.MavenPomUtil;
	import actionScripts.utils.SerializeUtil;
	import flash.filesystem.File;

	public class JavaImporter extends FlashDevelopImporterBase
	{
		private static const FILE_EXTENSION_JAVAPROJ:String = "javaproj";
		private static const FILE_NAME_POM_XML:String = "pom.xml";
		private static const FILE_NAME_BUILD_GRADLE:String = "build.gradle";

		public static function test(file:FileLocation):FileLocation
		{
			if (!file.fileBridge.exists)
			{
				return null;
			}

			var srcMainJava:FileLocation = file.fileBridge.resolvePath("src");
			if (!srcMainJava.fileBridge.exists || !srcMainJava.fileBridge.isDirectory)
			{
				return null;
			}

			var listing:Array = file.fileBridge.getDirectoryListing();
			var projectFile:FileLocation = null;
			var pomFile:FileLocation = null;
			var gradleFile:FileLocation = null;
			for each (var i:File in listing)
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
					if (i.extension == FILE_EXTENSION_JAVAPROJ)
					{
						projectFile = new FileLocation(i.nativePath);
					}
				}
			}

			if(projectFile)
			{
				//same as JavaLanguageServerManager, prefer pom.xml over build.gradle
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

		public static function getSettingsFile(projectFolder:FileLocation):FileLocation
		{
			if (!projectFolder.fileBridge.exists)
			{
				return null;
			}

			var listing:Array = projectFolder.fileBridge.getDirectoryListing();
			for each (var i:File in listing)
			{
				if (i.extension == FILE_EXTENSION_JAVAPROJ)
				{
					return (new FileLocation(i.nativePath));
				}
			}

			return null;
		}

		public static function parse(projectFolder:FileLocation, projectName:String=null, settingsFileLocation:FileLocation = null):JavaProjectVO
		{
			if(!projectName && !settingsFileLocation)
			{
				projectName = projectFolder.name
			}
			else if (!projectName && settingsFileLocation)
			{
				projectName = settingsFileLocation.fileBridge.name.substring(0, settingsFileLocation.fileBridge.name.lastIndexOf("."));
			}

            if (!settingsFileLocation)
            {
                settingsFileLocation = projectFolder.fileBridge.resolvePath(projectName +"."+ FILE_EXTENSION_JAVAPROJ);
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
			
			if (settingsData && settingsData.options.option.hasOwnProperty('@jdkType'))
				javaProject.jdkType = SerializeUtil.deserializeString(settingsData.options.option.@jdkType);
			if (settingsData && settingsData.options.option.hasOwnProperty('@projectType'))
			{
				javaProject.projectType = SerializeUtil.deserializeString(settingsData.options.option.@projectType);
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