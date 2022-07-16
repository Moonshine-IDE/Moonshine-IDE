package actionScripts.plugin.basic.importer
{
    
	import actionScripts.plugin.core.importer.FlashDevelopImporterBase;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.basic.vo.BasicProjectVO;

	public class BasicImporter  extends FlashDevelopImporterBase
	{
		private static const FILE_EXTENSION_BASICPROJ:String = ".basicproj";
		public function BasicImporter ()
		{
		}
		

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
				var extensionIndex:int = fileName.lastIndexOf(FILE_EXTENSION_BASICPROJ);
				if(extensionIndex != -1 && extensionIndex == (fileName.length - FILE_EXTENSION_BASICPROJ.length))
				{
					return new FileLocation(i.nativePath);
				}
			}
			
			return null;
		}
		
		public static function parse(projectFolder:FileLocation, projectName:String=null, settingsFileLocation:FileLocation = null):BasicProjectVO{
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
                settingsFileLocation = projectFolder.fileBridge.resolvePath(projectName + FILE_EXTENSION_BASICPROJ);
            }
            
            var project:BasicProjectVO = new BasicProjectVO(projectFolder, projectName);
            project.projectFile = settingsFileLocation;
			
			var settingsData:XML = null;
			if (settingsFileLocation.fileBridge.exists)
			{
				settingsData = new XML(settingsFileLocation.fileBridge.read());
			}
			
		
			return project;
            
		}
	}
}