package actionScripts.plugin.groovy.groovyproject.importer
{
	import actionScripts.factory.FileLocation;
	import flash.filesystem.File;
	import actionScripts.plugin.groovy.groovyproject.vo.GrailsProjectVO;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import actionScripts.plugin.core.importer.FlashDevelopImporterBase;

	public class GrailsImporter extends FlashDevelopImporterBase
	{
		private static const FILE_EXTENSION_GRAILSPROJ:String = "grailsproj";

		public static function test(file:File):FileLocation
		{
			if (!file.exists)
			{
				return null;
			}

			var listing:Array = file.getDirectoryListing();
			for each (var i:Object in listing)
			{
				if (i.extension == FILE_EXTENSION_GRAILSPROJ)
				{
					return new FileLocation(i.nativePath);
				}
			}
			
			return null;
		}

		public static function parse(file:FileLocation, projectName:String=null):GrailsProjectVO
		{
			var folder:File = (file.fileBridge.getFile as File).parent;

			var project:GrailsProjectVO = new GrailsProjectVO(new FileLocation(folder.nativePath), projectName);

			project.projectFile = file;

			project.projectName = file.fileBridge.name.substring(0, file.fileBridge.name.lastIndexOf("."));

			var stream:FileStream = new FileStream();
			stream.open(file.fileBridge.getFile as File, FileMode.READ);
			var data:XML = XML(stream.readUTFBytes(file.fileBridge.getFile.size));
			stream.close();
			
            project.classpaths.length = 0;
			
			parsePaths(data.classpaths["class"], project.classpaths, project, "path");

			project.sourceFolder = new FileLocation(folder.resolvePath("src/main/groovy").nativePath);

			return project;
		}
	}
}