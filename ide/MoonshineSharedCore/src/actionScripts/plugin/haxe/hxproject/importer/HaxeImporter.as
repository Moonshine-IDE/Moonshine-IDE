package actionScripts.plugin.haxe.hxproject.importer
{
	import actionScripts.factory.FileLocation;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import actionScripts.plugin.core.importer.FlashDevelopImporterBase;
	import actionScripts.ui.menu.vo.ProjectMenuTypes;
	import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;

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
			//project.menuType = ProjectMenuTypes.HAXE;

			project.projectFile = settingsFileLocation;
			
			var data:XML;
			if (settingsFileLocation.fileBridge.exists)
			{
				var stream:FileStream = new FileStream();
				stream.open(settingsFileLocation.fileBridge.getFile as File, FileMode.READ);
				data = XML(stream.readUTFBytes(settingsFileLocation.fileBridge.getFile.size));
				stream.close();
			}

			var separator:String = projectFolder.fileBridge.separator;
			project.sourceFolder = projectFolder.resolvePath("src");

			return project;
		}
	}
}