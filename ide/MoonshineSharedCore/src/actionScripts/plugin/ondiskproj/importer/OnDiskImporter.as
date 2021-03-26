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
				var airFile:Object = projectFolder.fileBridge.getFile;
				projectName = airFile.name;
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
			
			UtilsCore.setProjectMenuType(project);

			return project;
		}
	}
}