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
package actionScripts.plugin.haxe.hxproject.importer
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.core.importer.FlashDevelopImporterBase;
	import actionScripts.plugin.haxe.hxproject.vo.HaxeOutputVO;
	import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;
	import actionScripts.utils.SerializeUtil;
	import actionScripts.utils.UtilsCore;

	public class HaxeImporter extends FlashDevelopImporterBase
	{
		public static const FILE_EXTENSION_HXPROJ:String = ".hxproj";

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
				var extensionIndex:int = fileName.lastIndexOf(FILE_EXTENSION_HXPROJ);
				if(extensionIndex != -1 && extensionIndex == (fileName.length - FILE_EXTENSION_HXPROJ.length))
				{
					return new FileLocation(i.nativePath);
				}
			}
			
			return null;
		}

		public static function parse(projectFolder:FileLocation, projectName:String=null, settingsFileLocation:FileLocation = null):HaxeProjectVO
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
                settingsFileLocation = projectFolder.fileBridge.resolvePath(projectName + FILE_EXTENSION_HXPROJ);
            }

			var project:HaxeProjectVO = new HaxeProjectVO(projectFolder, projectName);

			project.projectFile = settingsFileLocation;
			
			var settingsData:XML = null;
			if (settingsFileLocation.fileBridge.exists)
			{
				settingsData = new XML(settingsFileLocation.fileBridge.read());
			}
			
			// Parse XML file
            project.classpaths.length = 0;
            project.targets.length = 0;

			if (settingsData)
			{
            	project.haxeOutput.parse(settingsData.elements("output"), project);
			}
			else
			{
				var limeProjectFile:FileLocation = projectFolder.resolvePath("project.xml");
				if (limeProjectFile.fileBridge.exists)
				{
					project.haxeOutput.platform = HaxeOutputVO.PLATFORM_LIME;
					project.haxeOutput.path = limeProjectFile;
				}
			}

			project.isLime = UtilsCore.isLime(project);
			
			if (settingsData)
			{
				parsePaths(settingsData.elements("compileTargets").elements("compile"), project.targets, project, "path");
				parsePaths(settingsData.elements("hiddenPaths").elements("hidden"), project.hiddenPaths, project, "path");		
				parsePaths(settingsData.elements("classpaths").elements("class"), project.classpaths, project, "path");
				parsePathString(settingsData.elements("haxelib").elements("library"), project.haxelibs, project, "name");
			}

			if (settingsData)
			{
            	project.buildOptions.parse(settingsData.build);
			}
			else
			{
				if (project.isLime)
				{
					project.buildOptions.additional = "--macro openfl._internal.macros.ExtraParams.include()&#xA;--macro lime._internal.macros.DefineMacro.run()&#xA;--remap flash:openfl&#xA;--no-output ";
				}
				else
				{
					project.buildOptions.additional = "";
				}
			}
			
			if (project.hiddenPaths.length > 0 && project.projectFolder)
			{
				project.projectFolder.updateChildren();
			}

			if (settingsData)
			{
				var prebuildCommandValue:String = SerializeUtil.deserializeString(settingsData.elements("preBuildCommand").text());
				if (prebuildCommandValue != "null")
				{
					project.prebuildCommands = prebuildCommandValue;
				}
				var postbuildCommandValue:String = SerializeUtil.deserializeString(settingsData.elements("postBuildCommand").text());;
				if (postbuildCommandValue != "null")
				{
					project.postbuildCommands = postbuildCommandValue;
				}
				project.postbuildAlways = SerializeUtil.deserializeBoolean(settingsData.elements("postBuildCommand").attribute("alwaysRun").toString());
			}
			else if (project.isLime)
			{
				project.prebuildCommands = '"$(CompilerPath)/haxelib" run lime build "$(OutputFile)" $(TargetBuild) -$(BuildConfig) -Dfdb';
			}

			if (settingsData)
			{
				var showHiddenPathsValue:String = settingsData.elements("options").elements("option").attribute("showHiddenPaths").toString();
            	project.showHiddenPaths = SerializeUtil.deserializeBoolean(showHiddenPathsValue);
			}

			if (project.targets.length > 0)
			{
				var target:FileLocation = project.targets[0];
				
				// determine source folder path
				var substrPath:String = target.fileBridge.nativePath.replace(project.folderLocation.fileBridge.nativePath + File.separator, "");
				var pathSplit:Array = substrPath.split(File.separator);
				// remove the last class file name
				pathSplit.pop();
				var finalPath:String = project.folderLocation.fileBridge.nativePath;
				// loop through array if source folder level is
				// deeper more than 1 level
				for (var j:int=0; j < pathSplit.length; j++)
				{
					finalPath += File.separator + pathSplit[j];
				}
				
				// even before deciding, go for some more checks -
				// which needs in case user used 'set as default application'
				// to a file exists in different path
				for each (var i:FileLocation in project.classpaths)
				{
					if ((finalPath + File.separator).indexOf(i.fileBridge.nativePath + File.separator) != -1) project.sourceFolder = i;
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
					if (k.fileBridge.nativePath.indexOf(project.folderLocation.fileBridge.nativePath + File.separator) != -1) 
					{
						project.sourceFolder = k;
						break;
					}
				}
			}

			if (settingsData)
			{
            	project.testMovie = settingsData.elements("options").elements("option").attribute("testMovie").toString();
			}

			if(project.isLime)
			{
				var limeTargetPlatform:String = settingsData ? settingsData.elements("moonshineRunCustomization").elements("option").attribute("targetPlatform").toString() : "";
				if (limeTargetPlatform.length == 0)
				{
					//when Haxe projects were first introduced, they didn't have
					//the moonshineRunCustomization section, so we should
					//provide them with a default
					limeTargetPlatform = HaxeProjectVO.LIME_PLATFORM_HTML5;
				}
				if (limeTargetPlatform == "mac")
				{
					// use the full name instead of the alias
					limeTargetPlatform = HaxeProjectVO.LIME_PLATFORM_MACOS;
				}
				project.limeTargetPlatform = limeTargetPlatform;
			}
			else
			{
				if (project.haxeOutput.platform == "")
				{
					project.haxePlatform = HaxeOutputVO.PLATFORM_JAVASCRIPT;
				}
				project.limeTargetPlatform = null;
			}
			
			if (settingsData && (project.testMovie == HaxeProjectVO.TEST_MOVIE_CUSTOM || project.testMovie == HaxeProjectVO.TEST_MOVIE_OPEN_DOCUMENT))
			{
                project.testMovieCommand = settingsData.elements("options").elements("option").attribute("testMovieCommand").toString();
			}
			
			if (settingsData)
			{
				var webBrowserValue:String = settingsData.elements("moonshineRunCustomization").elements("option").attribute("webBrowser").toString();
				project.runWebBrowser = SerializeUtil.deserializeString(webBrowserValue);
			}
			
			UtilsCore.setProjectMenuType(project);

			return project;
		}
	}
}