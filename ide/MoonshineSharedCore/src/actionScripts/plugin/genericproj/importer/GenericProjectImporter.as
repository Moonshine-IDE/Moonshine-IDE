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

		public static function test(file:FileLocation):FileLocation
		{
			if (!file.fileBridge.exists)
			{
				return null;
			}

			var listing:Array = file.fileBridge.getDirectoryListing();
			for each (var i:File in listing)
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
				if (settingsFileLocation) projectName = settingsFileLocation.fileBridge.nameWithoutExtension;
				else projectName = projectFolder.name;
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