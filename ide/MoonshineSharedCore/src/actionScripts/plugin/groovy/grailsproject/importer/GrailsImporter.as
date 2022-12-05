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
package actionScripts.plugin.groovy.grailsproject.importer
{
	import actionScripts.factory.FileLocation;
	import actionScripts.utils.SerializeUtil;

	import flash.filesystem.File;
	import actionScripts.plugin.groovy.grailsproject.vo.GrailsProjectVO;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import actionScripts.plugin.core.importer.FlashDevelopImporterBase;

	public class GrailsImporter extends FlashDevelopImporterBase
	{
		private static const FILE_EXTENSION_GRAILSPROJ:String = ".grailsproj";

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