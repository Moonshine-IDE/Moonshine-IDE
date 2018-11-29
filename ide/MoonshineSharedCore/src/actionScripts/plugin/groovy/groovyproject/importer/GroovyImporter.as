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
			return new GroovyProjectVO(file, projectName);
		}
	}
}