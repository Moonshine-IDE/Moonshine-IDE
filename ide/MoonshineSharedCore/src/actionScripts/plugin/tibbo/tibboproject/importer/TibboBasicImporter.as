package actionScripts.plugin.tibbo.tibboproject.importer
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.core.importer.FlashDevelopImporterBase;
	import actionScripts.plugin.tibbo.tibboproject.vo.TibboBasicProjectVO;
	import actionScripts.utils.SerializeUtil;
	import actionScripts.utils.UtilsCore;

	public class TibboBasicImporter extends FlashDevelopImporterBase
	{
		private static const PROJECT_FILE_EXTENSION:String = ".tibboproj";

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
				var extensionIndex:int = fileName.lastIndexOf(PROJECT_FILE_EXTENSION);
				if(extensionIndex != -1 && extensionIndex == (fileName.length - PROJECT_FILE_EXTENSION.length))
				{
					return new FileLocation(i.nativePath);
				}
			}
			
			return null;
		}

		public static function parse(projectFolder:FileLocation, projectName:String=null, settingsFileLocation:FileLocation = null):TibboBasicProjectVO
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
                settingsFileLocation = projectFolder.fileBridge.resolvePath(projectName + PROJECT_FILE_EXTENSION);
            }

			var project:TibboBasicProjectVO = new TibboBasicProjectVO(projectFolder, projectName);

			project.projectFile = settingsFileLocation;
			
			var settingsData:XML = null;
			if (settingsFileLocation.fileBridge.exists)
			{
				settingsData = new XML(settingsFileLocation.fileBridge.read());
			}
			
			// Parse XML file
            project.classpaths.length = 0;
			
			if (settingsData)
			{
				parsePaths(settingsData.elements("hiddenPaths").elements("hidden"), project.hiddenPaths, project, "path");		
				parsePaths(settingsData.elements("classpaths").elements("class"), project.classpaths, project, "path");
			}
			
			if (project.hiddenPaths.length > 0 && project.projectFolder)
			{
				project.projectFolder.updateChildren();
			}

			if (settingsData)
			{
				var showHiddenPathsValue:String = settingsData.elements("options").elements("option").attribute("showHiddenPaths").toString();
            	project.showHiddenPaths = SerializeUtil.deserializeBoolean(showHiddenPathsValue);
			}

			if (project.classpaths.length > 0)
			{
				// try to select the source folder based on its classpaths
				for each (var k:FileLocation in project.classpaths)
				{
					if (k.fileBridge.nativePath.indexOf(project.folderLocation.fileBridge.nativePath + File.separator) != -1) 
					{
						project.sourceFolder = k;
						break;
					}
				}
			}

			parseWorkflowFile(project);
			UtilsCore.setProjectMenuType(project);

			return project;
		}
	}
}