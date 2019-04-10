package actionScripts.plugin.groovy.groovyproject.importer
{
	import actionScripts.factory.FileLocation;
	import flash.filesystem.File;
	import actionScripts.plugin.groovy.groovyproject.vo.GroovyProjectVO;

	public class GroovyImporter
	{
		public static function test(file:File):FileLocation
		{
			if (!file.exists)
			{
				return null;
			}
			var srcMainGroovy:File = file.resolvePath("src/main/groovy");
			if (!srcMainGroovy.exists || !srcMainGroovy.isDirectory)
			{
				return null;
			}
			
			var listing:Array = file.getDirectoryListing();
			for each (var i:File in listing)
			{
				if (i.name == "build.gradle") {
					return (new FileLocation(i.nativePath));
				}
			}
			
			return null;
		}

		public static function parse(file:FileLocation, projectName:String=null):GroovyProjectVO
		{
			if(!projectName)
			{
				var airFile:File = File(file.fileBridge.getFile);
				projectName = airFile.name;
			}

			var groovyProject:GroovyProjectVO = new GroovyProjectVO(file, projectName);

            var sourceDirectory:String = null;

			var separator:String = groovyProject.projectFolder.file.fileBridge.separator;

			const defaultSourceFolderPath:String = "src".concat(separator, "main", separator, "groovy");
			if (!sourceDirectory)
			{
				sourceDirectory = defaultSourceFolderPath;
			}

			var f:FileLocation = groovyProject.folderLocation.resolvePath(sourceDirectory);
			groovyProject.classpaths.push(f);

			if (groovyProject.classpaths.length > 0)
			{
				sourceDirectory = groovyProject.classpaths[0].fileBridge.nativePath;
			}

			addSourceDirectoryToProject(groovyProject, sourceDirectory);

			return groovyProject;
		}

		private static function addSourceDirectoryToProject(groovyProject:GroovyProjectVO, sourceDirectory:String):void
		{
			if (sourceDirectory)
			{
				groovyProject.sourceFolder = groovyProject.projectFolder.file.fileBridge.resolvePath(sourceDirectory);
			}

			if (!sourceDirectory || !groovyProject.sourceFolder.fileBridge.exists)
			{
				groovyProject.sourceFolder = groovyProject.projectFolder.file.fileBridge.resolvePath("src");
			}
		}
	}
}