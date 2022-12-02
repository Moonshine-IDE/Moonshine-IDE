////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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
package actionScripts.plugin.ondiskproj.importer
{
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.core.importer.FlashDevelopImporterBase;
	import actionScripts.plugin.ondiskproj.vo.OnDiskProjectVO;
	import actionScripts.utils.SerializeUtil;
	import actionScripts.utils.UtilsCore;

	public class OnDiskImporter extends FlashDevelopImporterBase
	{
		private static const FILE_EXTENSION_ONDISKPROJ:String = ".ondiskproj";

		public static function test(file:FileLocation):FileLocation
		{
			if (!file.fileBridge.exists)
			{
				return null;
			}

			var listing:Array = file.fileBridge.getDirectoryListing();
			for each (var i:Object in listing)
			{
				var fileName:String = i.name;
				var extensionIndex:int = fileName.lastIndexOf(FILE_EXTENSION_ONDISKPROJ);
				if(extensionIndex != -1 && extensionIndex == (fileName.length - FILE_EXTENSION_ONDISKPROJ.length))
				{
					return new FileLocation(i.nativePath);
				}
			}
			
			return null;
		}

		public static function parse(projectFolder:FileLocation, projectName:String=null, settingsFileLocation:FileLocation = null):OnDiskProjectVO
		{
			if (!projectName)
			{
				if (settingsFileLocation) projectName = settingsFileLocation.fileBridge.nameWithoutExtension;
				else projectName = projectFolder.name;
			}

            if (!settingsFileLocation)
            {
                settingsFileLocation = projectFolder.fileBridge.resolvePath(projectName + FILE_EXTENSION_ONDISKPROJ);
            }

			var project:OnDiskProjectVO = new OnDiskProjectVO(projectFolder, projectName);
			var separator:String = IDEModel.getInstance().fileCore.separator;

			project.projectFile = settingsFileLocation;
			
			var data:XML;
			if (settingsFileLocation.fileBridge.exists)
			{
				data = new XML(settingsFileLocation.fileBridge.read());
			}
			
			// Parse XML file
            project.classpaths.length = 0;
			project.targets.length = 0;
			
            parsePaths(data.hiddenPaths.hidden, project.hiddenPaths, project, "path");		
			parsePaths(data.classpaths["class"], project.classpaths, project, "path");
			parsePaths(data.compileTargets.compile, project.targets, project, "path");
	
			if (!project.buildOptions.additional) project.buildOptions.additional = "";
			
			if (project.hiddenPaths.length > 0 && project.projectFolder)
			{
				project.projectFolder.updateChildren();
			}

            project.prebuildCommands = SerializeUtil.deserializeString(data.preBuildCommand);
            project.postbuildCommands = SerializeUtil.deserializeString(data.postBuildCommand);
            project.postbuildAlways = SerializeUtil.deserializeBoolean(data.postBuildCommand.@alwaysRun);
			if (data.options.option.hasOwnProperty('@jdkType')) 
				project.jdkType = SerializeUtil.deserializeString(data.options.option.@jdkType);

            project.showHiddenPaths = SerializeUtil.deserializeBoolean(data.options.option.@showHiddenPaths);

			if (data.domino.option.hasOwnProperty('@dominoBaseAgentURL'))
				project.dominoBaseAgentURL = SerializeUtil.deserializeString(data.domino.option.@dominoBaseAgentURL);
			if (data.domino.option.hasOwnProperty('@localDatabase'))
				project.localDatabase = UtilsCore.getAbsolutePathAgainstProject(project.folderLocation, data.domino.option.@localDatabase);
			if (data.domino.option.hasOwnProperty('@targetServer'))
				project.targetServer = SerializeUtil.deserializeString(data.domino.option.@targetServer);
			if (data.domino.option.hasOwnProperty('@targetDatabase'))
				project.targetDatabase = SerializeUtil.deserializeString(data.domino.option.@targetDatabase);

			project.dominoBaseAgentURL = project.dominoBaseAgentURL.replace(/%CleanProjectName%/gi, projectName);
			project.targetDatabase = project.targetDatabase.replace(/%CleanProjectName%/gi, projectName);
			project.localDatabase = project.localDatabase.replace(/%ProjectPath%/gi, project.projectFolder.nativePath);

			if (project.targets.length > 0)
			{
				var target:FileLocation = project.targets[0];
				
				// determine source folder path
				var substrPath:String = target.fileBridge.nativePath.replace(project.folderLocation.fileBridge.nativePath + separator, "");
				var pathSplit:Array = substrPath.split(separator);
				// remove the last class file name
				pathSplit.pop();
				var finalPath:String = project.folderLocation.fileBridge.nativePath;
				// loop through array if source folder level is
				// deeper more than 1 level
				for (var j:int=0; j < pathSplit.length; j++)
				{
					finalPath += separator + pathSplit[j];
				}
				
				// even before deciding, go for some more checks -
				// which needs in case user used 'set as default application'
				// to a file exists in different path
				for each (var i:FileLocation in project.classpaths)
				{
					if ((finalPath + separator).indexOf(i.fileBridge.nativePath + separator) != -1) project.sourceFolder = i;
				}
				
				// if yet not decided from above approach
				if (!project.sourceFolder) project.sourceFolder = new FileLocation(finalPath);
			}
			else if (project.classpaths.length > 0)
			{
				// its possible that a project do not have any default application (project.targets[0])
				// i.e. library project where no default application maintains
				// we shall try to select the source folder based on its classpaths
				for each (var k:FileLocation in project.classpaths)
				{
					if (k.fileBridge.nativePath.indexOf(project.folderLocation.fileBridge.nativePath + separator) != -1) 
					{
						project.sourceFolder = k;
						break;
					}
				}
			}

            project.buildOptions.parse(data.build);
			project.mavenBuildOptions.parse(data.mavenBuild);

			project.visualEditorSourceFolder = new FileLocation(
                        project.folderLocation.fileBridge.nativePath + project.folderLocation.fileBridge.separator + "visualeditor-src/main/webapp"
                );

			return project;
		}
	}
}