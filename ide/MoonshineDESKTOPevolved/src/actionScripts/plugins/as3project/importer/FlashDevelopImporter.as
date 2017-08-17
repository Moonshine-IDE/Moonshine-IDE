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
	
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.actionscript.as3project.vo.MXMLCConfigVO;
	import actionScripts.plugin.core.importer.FlashDevelopImporterBase;
	import actionScripts.utils.UtilsCore;
	
	public class FlashDevelopImporter extends FlashDevelopImporterBase
	{
		public static function test(file:File):FileLocation
		{
			var listing:Array = file.getDirectoryListing();
			for each (var i:File in listing)
			{
				if (i.extension == "as3proj") {
					return (new FileLocation(i.nativePath));
				}
			}
			
			return null;
		}
		
		public static function parse(file:FileLocation, projectName:String=null, descriptorFile:File=null, shallUpdateChildren:Boolean=true):AS3ProjectVO
		{
			var folder:File = (file.fileBridge.getFile as File).parent;
			
			var p:AS3ProjectVO = new AS3ProjectVO(new FileLocation(folder.nativePath), projectName, shallUpdateChildren);
			p.projectFile = file;
			
			p.projectName = file.fileBridge.name.substring(0, file.fileBridge.name.lastIndexOf("."));
			p.config = new MXMLCConfigVO(new FileLocation(folder.resolvePath("obj/"+p.projectName+"Config.xml").nativePath));
			p.projectFolder.name = p.projectName;
			
			if (!descriptorFile) descriptorFile = folder.resolvePath("application.xml");
			if (!descriptorFile.exists)
			{
				descriptorFile = folder.resolvePath("src/"+p.projectName+"-app.xml");
				if (!descriptorFile.exists)
				{
					var projectConfig:File = folder.resolvePath("obj/"+p.projectName+"Config.xml");
					if (projectConfig.exists)
					{
						stream = new FileStream();
						stream.open(projectConfig, FileMode.READ);
						var configData:XML = XML(stream.readUTFBytes(projectConfig.size).toString());
						stream.close();
						
						projectConfig = new File(configData["file-specs"]["path-element"]);
						projectConfig = projectConfig.parent;
						descriptorFile = projectConfig.resolvePath(p.projectName+"-app.xml");
					}
					
					//descriptorFile = folder.resolvePath(p.projectName+".template");
				}
			}
			var stream:FileStream;
			var isAIR:Boolean;
			if (descriptorFile.exists)
			{
				isAIR = true;
				stream = new FileStream();
				stream.open(descriptorFile, FileMode.READ);
				var descriptorData:XML = XML(stream.readUTFBytes(descriptorFile.size).toString());
				stream.close();

				var tmpNameSearchString:String = "";
				for each (var i:XML in descriptorData.children())
				{
					tmpNameSearchString += i.localName()+" ";
				}
				
				p.isMobile = (tmpNameSearchString.indexOf("android") != -1) || (tmpNameSearchString.indexOf("iPhone") != -1) ? true : false;
			}
			
			p.air = isAIR;
			
			stream = new FileStream();
			stream.open(file.fileBridge.getFile as File, FileMode.READ);
			var data:XML = XML(stream.readUTFBytes(file.fileBridge.getFile.size));
			stream.close();

			// Parse XML file
			p.classpaths.length = 0;
			p.resourcePaths.length = 0;
			p.targets.length = 0;

			p.buildOptions.parse(data.build);
			p.swfOutput.parse(data.output, p);
			
			parsePaths(data.classpaths["class"], p.classpaths, p, "path", p.buildOptions.customSDKPath);
			parsePaths(data.moonshineResourcePaths["class"], p.resourcePaths, p, "path", p.buildOptions.customSDKPath);
			if (!p.buildOptions.additional) p.buildOptions.additional = "";
			if (isAIR && (p.buildOptions.additional.indexOf("configname") == -1))
			{
				if (p.isMobile) p.buildOptions.additional += " +configname=airmobile";
				else p.buildOptions.additional += " +configname=air";
			}
			
			parsePaths(data.includeLibraries.element, p.includeLibraries, p, "path", p.buildOptions.customSDKPath);
			parsePaths(data.libraryPaths.element, p.libraries, p, "path", p.buildOptions.customSDKPath);
			parsePaths(data.externalLibraryPaths.element, p.externalLibraries, p, "path", p.buildOptions.customSDKPath);
			parsePaths(data.rslPaths.element, p.runtimeSharedLibraries, p, "path", p.buildOptions.customSDKPath);

			p.assetLibrary = data.library;
			parsePaths(data.intrinsics.element, p.intrinsicLibraries, p, "path", p.buildOptions.customSDKPath);
			parsePaths(data.compileTargets.compile, p.targets, p, "path", p.buildOptions.customSDKPath);
			parsePaths(data.hiddenPaths.hidden, p.hiddenPaths, p, "path", p.buildOptions.customSDKPath);

			p.prebuildCommands = UtilsCore.deserializeString(data.preBuildCommand);
			p.postbuildCommands = UtilsCore.deserializeString(data.postBuildCommand);
			p.postbuildAlways = UtilsCore.deserializeBoolean(data.postBuildCommand.@alwaysRun);
			
			p.showHiddenPaths = UtilsCore.deserializeBoolean(data.options.option.@showHiddenPaths);
			
			p.defaultBuildTargets = data.options.option.@defaultBuildTargets;
			p.testMovie = data.options.option.@testMovie;
			if (p.air) p.testMovie = AS3ProjectVO.TEST_MOVIE_AIR;
			if (p.testMovie == AS3ProjectVO.TEST_MOVIE_CUSTOM || p.testMovie == AS3ProjectVO.TEST_MOVIE_OPEN_DOCUMENT)
			{
				p.testMovieCommand = data.options.option.@testMovieCommand;
			}
			if (p.targets.length > 0)
			{
				var target:FileLocation = p.targets[0];
				checkProjectType(target, p);
				
				// determine source folder path
				var substrPath:String = target.fileBridge.nativePath.replace(p.folderLocation.fileBridge.nativePath + File.separator, "");
				var pathSplit:Array = substrPath.split(File.separator);
				// remove the last class file name
				pathSplit.pop();
				var finalPath:String = p.folderLocation.fileBridge.nativePath;
				// loop through array if source folder level is
				// deeper more than 1 level
				for (var j:int=0; j < pathSplit.length; j++)
				{
					finalPath += File.separator + pathSplit[j];
				}
				
				p.sourceFolder = new FileLocation(finalPath);
			}

			// add output folder path to flash trust content list
			if (!isAIR && !p.isMobile)
			{
				//IDEModel.getInstance().flexCore.updateFlashPlayerTrustContent(p.folderLocation.resolvePath("bin-debug"));
			}

			return p;
		}
	}
}