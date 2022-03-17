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
				parsePaths(settingsData.compileTargets.compile, project.targets, project, "path");
				parsePaths(settingsData.hiddenPaths.hidden, project.hiddenPaths, project, "path");		
				parsePaths(settingsData.classpaths["class"], project.classpaths, project, "path");
				parsePathString(settingsData.haxelib["library"], project.haxelibs, project, "name");
			}

			if (settingsData)
			{
            	project.haxeOutput.parse(settingsData.output, project);
			}
			else
			{
				var limeProjectFile:FileLocation = projectFolder.resolvePath("project.xml");
				if (limeProjectFile.fileBridge.exists)
				{
					project.haxeOutput.platform = HaxeOutputVO.PLATFORM_LIME;
				}
			}

			project.isLime = UtilsCore.isLime(project);

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
				project.prebuildCommands = SerializeUtil.deserializeString(settingsData.preBuildCommand);
				project.postbuildCommands = SerializeUtil.deserializeString(settingsData.postBuildCommand);
				project.postbuildAlways = SerializeUtil.deserializeBoolean(settingsData.postBuildCommand.@alwaysRun);
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