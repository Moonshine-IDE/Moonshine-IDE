////////////////////////////////////////////////////////////////////////////////
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
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.as3project.importer
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.collections.ArrayCollection;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.actionscript.as3project.AS3ProjectPlugin;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.actionscript.as3project.vo.MXMLCConfigVO;
	import actionScripts.plugin.actionscript.as3project.vo.SWFOutputVO;
	import actionScripts.plugin.core.importer.FlashDevelopImporterBase;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.MobileDeviceVO;
	import actionScripts.valueObjects.ProjectVO;
	
	public class FlashDevelopImporter extends FlashDevelopImporterBase
	{
		public static function test(file:File):FileLocation
		{
			if (!file.exists) return null;
			
			var listing:Array = file.getDirectoryListing();
			for each (var i:File in listing)
			{
				if (i.extension == "as3proj" || i.extension == "veditorproj") {
					return (new FileLocation(i.nativePath));
				}
			}
			
			return null;
		}
		
		public static function parse(file:FileLocation, projectName:String=null, descriptorFile:File=null, shallUpdateChildren:Boolean=true):AS3ProjectVO
		{
			var folder:File = (file.fileBridge.getFile as File).parent;
			
			var project:AS3ProjectVO = new AS3ProjectVO(new FileLocation(folder.nativePath), projectName, shallUpdateChildren);
			project.isVisualEditorProject = file.fileBridge.name.indexOf("veditorproj") > -1;

			project.projectFile = file;
			
			project.projectName = file.fileBridge.name.substring(0, file.fileBridge.name.lastIndexOf("."));
			project.config = new MXMLCConfigVO(new FileLocation(folder.resolvePath("obj/"+project.projectName+"Config.xml").nativePath));
			project.projectFolder.name = project.projectName;
			
			var stream:FileStream;
			stream = new FileStream();
			stream.open(file.fileBridge.getFile as File, FileMode.READ);
			var data:XML = XML(stream.readUTFBytes(file.fileBridge.getFile.size));
			stream.close();
			
			// Parse XML file
            project.classpaths.length = 0;
            project.resourcePaths.length = 0;
            project.targets.length = 0;

            parsePaths(data.includeLibraries.element, project.includeLibraries, project, "path", project.buildOptions.customSDKPath);
            parsePaths(data.libraryPaths.element, project.libraries, project, "path", project.buildOptions.customSDKPath);
            parsePaths(data.externalLibraryPaths.element, project.externalLibraries, project, "path", project.buildOptions.customSDKPath);
            parsePaths(data.rslPaths.element, project.runtimeSharedLibraries, project, "path", project.buildOptions.customSDKPath);

            project.assetLibrary = data.library;
            parsePathString(data.intrinsics.element, project.intrinsicLibraries, project, "path");
            parsePaths(data.compileTargets.compile, project.targets, project, "path", project.buildOptions.customSDKPath);
            parsePaths(data.hiddenPaths.hidden, project.hiddenPaths, project, "path", project.buildOptions.customSDKPath);
			
			parsePaths(data.classpaths["class"], project.classpaths, project, "path", project.buildOptions.customSDKPath);
			parsePaths(data.moonshineResourcePaths["class"], project.resourcePaths, project, "path", project.buildOptions.customSDKPath);
			parsePaths(data.moonshineNativeExtensionPaths["class"], project.nativeExtensions, project, "path");
			if (!project.buildOptions.additional) project.buildOptions.additional = "";
			
			if (project.hiddenPaths.length > 0 && project.projectFolder)
			{
				project.projectFolder.updateChildren();
			}

            project.prebuildCommands = UtilsCore.deserializeString(data.preBuildCommand);
            project.postbuildCommands = UtilsCore.deserializeString(data.postBuildCommand);
            project.postbuildAlways = UtilsCore.deserializeBoolean(data.postBuildCommand.@alwaysRun);

            project.showHiddenPaths = UtilsCore.deserializeBoolean(data.options.option.@showHiddenPaths);
            project.isPrimeFacesVisualEditorProject = UtilsCore.deserializeBoolean(data.options.option.@isPrimeFacesVisualEditor);

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

			if (project.isVisualEditorProject)
			{
				project.visualEditorSourceFolder = new FileLocation(
                        project.folderLocation.fileBridge.nativePath + File.separator + "visualeditor-src"
				);
			}

            project.defaultBuildTargets = data.options.option.@defaultBuildTargets;
            project.testMovie = data.options.option.@testMovie;

            project.buildOptions.parse(data.build);
            project.swfOutput.parse(data.output, project);
			if (project.swfOutput.path.fileBridge.extension && project.swfOutput.path.fileBridge.extension.toLowerCase() == "swc") project.isLibraryProject = true;
			
			if (project.targets.length > 0 && project.targets[0].fileBridge.extension == "as" && project.intrinsicLibraries.length == 0) project.isActionScriptOnly = true;
			if (project.targets.length > 0 && project.targets[0].fileBridge.extension == "mxml") project.isActionScriptOnly = false;
			else if (project.intrinsicLibraries.length == 0) project.isActionScriptOnly = true;
			
            project.air = UtilsCore.isAIR(project);
            project.isMobile = UtilsCore.isMobile(project);
			
			if (project.swfOutput.platform == "")
			{
				if (project.isMobile) project.swfOutput.platform = SWFOutputVO.PLATFORM_MOBILE;
				else if (project.air) project.swfOutput.platform = SWFOutputVO.PLATFORM_AIR;
				else project.swfOutput.platform = SWFOutputVO.PLATFORM_DEFAULT;
			}
			
			if (project.air) project.testMovie = AS3ProjectVO.TEST_MOVIE_AIR;
			if (project.testMovie == AS3ProjectVO.TEST_MOVIE_CUSTOM || project.testMovie == AS3ProjectVO.TEST_MOVIE_OPEN_DOCUMENT)
			{
                project.testMovieCommand = data.options.option.@testMovieCommand;
			}
			
			var platform:int = int(data.moonshineRunCustomization.option.@targetPlatform);
			if (platform == AS3ProjectPlugin.AS3PROJ_AS_ANDROID) project.buildOptions.targetPlatform = "Android";
			else if (platform == AS3ProjectPlugin.AS3PROJ_AS_IOS) project.buildOptions.targetPlatform = "iOS";
			
			var html:String = UtilsCore.deserializeString(data.moonshineRunCustomization.option.@urlToLaunch);
			if (html) project.htmlPath = new FileLocation(html);

            project.isMobileHasSimulatedDevice = new MobileDeviceVO(UtilsCore.deserializeString(data.moonshineRunCustomization.option.@deviceSimulator));
			
			var simulator:String = UtilsCore.deserializeString(data.moonshineRunCustomization.option.@launchMethod);
            project.buildOptions.isMobileRunOnSimulator = (simulator != "Device") ? true : false;
			
			if (!project.air) UtilsCore.checkIfRoyaleApplication(project);

            project.buildOptions.isMobileHasSimulatedDevice = new MobileDeviceVO(UtilsCore.deserializeString(data.moonshineRunCustomization.deviceSimulator));
            project.buildOptions.certAndroid = UtilsCore.deserializeString(data.moonshineRunCustomization.certAndroid);
            project.buildOptions.certIos = UtilsCore.deserializeString(data.moonshineRunCustomization.certIos);
            project.buildOptions.certIosProvisioning = UtilsCore.deserializeString(data.moonshineRunCustomization.certIosProvisioning);
			
			UtilsCore.setProjectMenuType(project);
			
			return project;
		}
	}
}