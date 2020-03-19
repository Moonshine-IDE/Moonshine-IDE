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
		private static const FILE_EXTENSION_HXPROJ:String = ".hxproj";

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
			if(!projectName)
			{
				var airFile:Object = projectFolder.fileBridge.getFile;
				projectName = airFile.name;
			}

            if (!settingsFileLocation)
            {
                settingsFileLocation = projectFolder.fileBridge.resolvePath(projectName + FILE_EXTENSION_HXPROJ);
            }

			var project:HaxeProjectVO = new HaxeProjectVO(projectFolder, projectName);

			project.projectFile = settingsFileLocation;
			
			var data:XML;
			if (settingsFileLocation.fileBridge.exists)
			{
				var stream:FileStream = new FileStream();
				stream.open(settingsFileLocation.fileBridge.getFile as File, FileMode.READ);
				data = XML(stream.readUTFBytes(settingsFileLocation.fileBridge.getFile.size));
				stream.close();
			}
			
			// Parse XML file
            project.classpaths.length = 0;
            project.targets.length = 0;
			
            parsePaths(data.compileTargets.compile, project.targets, project, "path");
            parsePaths(data.hiddenPaths.hidden, project.hiddenPaths, project, "path");		
			parsePaths(data.classpaths["class"], project.classpaths, project, "path");
			parsePathString(data.haxelib["library"], project.haxelibs, project, "name");
	
			if (!project.buildOptions.additional) project.buildOptions.additional = "";
			
			if (project.hiddenPaths.length > 0 && project.projectFolder)
			{
				project.projectFolder.updateChildren();
			}

            project.prebuildCommands = SerializeUtil.deserializeString(data.preBuildCommand);
            project.postbuildCommands = SerializeUtil.deserializeString(data.postBuildCommand);
            project.postbuildAlways = SerializeUtil.deserializeBoolean(data.postBuildCommand.@alwaysRun);

            project.showHiddenPaths = SerializeUtil.deserializeBoolean(data.options.option.@showHiddenPaths);

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

            project.testMovie = data.options.option.@testMovie;

            project.buildOptions.parse(data.build);

            project.haxeOutput.parse(data.output, project);

			project.isLime = UtilsCore.isLime(project);

			if(project.isLime)
			{
				var limeTargetPlatform:String = data.moonshineRunCustomization.option.@targetPlatform.toString();
				if(limeTargetPlatform.length == 0)
				{
					//when Haxe projects were first introduced, they didn't have
					//the moonshineRunCustomization section, so we should
					//provide them with a default
					limeTargetPlatform = HaxeProjectVO.LIME_PLATFORM_HTML5;
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
			
			if (project.testMovie == HaxeProjectVO.TEST_MOVIE_CUSTOM || project.testMovie == HaxeProjectVO.TEST_MOVIE_OPEN_DOCUMENT)
			{
                project.testMovieCommand = data.options.option.@testMovieCommand;
			}
			
			project.runWebBrowser = SerializeUtil.deserializeString(data.moonshineRunCustomization.option.@webBrowser);
			
			UtilsCore.setProjectMenuType(project);

			return project;
		}
	}
}