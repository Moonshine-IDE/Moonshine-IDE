package actionScripts.plugin.groovy.grailsproject.importer
{
	import actionScripts.factory.FileLocation;
	import flash.filesystem.File;
	import actionScripts.plugin.groovy.grailsproject.vo.GrailsProjectVO;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import actionScripts.plugin.core.importer.FlashDevelopImporterBase;
	import actionScripts.ui.menu.vo.ProjectMenuTypes;

	public class GrailsImporter extends FlashDevelopImporterBase
	{
		private static const FILE_EXTENSION_GRAILSPROJ:String = ".grailsproj";

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
			if(!projectName)
			{
				var airFile:Object = projectFolder.fileBridge.getFile;
				projectName = airFile.name;
			}

            if (!settingsFileLocation)
            {
                settingsFileLocation = projectFolder.fileBridge.resolvePath(projectName + FILE_EXTENSION_GRAILSPROJ);
            }

			var project:GrailsProjectVO = new GrailsProjectVO(projectFolder, projectName);
			project.menuType = ProjectMenuTypes.GRAILS;

			project.projectFile = settingsFileLocation;

			var stream:FileStream = new FileStream();
			stream.open(settingsFileLocation.fileBridge.getFile as File, FileMode.READ);
			var data:XML = XML(stream.readUTFBytes(settingsFileLocation.fileBridge.getFile.size));
			stream.close();
			
            project.classpaths.length = 0;
			
			parsePaths(data.classpaths["class"], project.classpaths, project, "path");

			project.sourceFolder = projectFolder.resolvePath("src/main/groovy");

			return project;
		}
	}
}