package actionScripts.plugin.java.javaproject.importer
{
	import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
	import actionScripts.factory.FileLocation;
	import flash.filesystem.File;

	public class JavaImporter
	{
		public static function test(file:File):FileLocation
		{
			if (!file.exists)
			{
				return null;
			}
			var srcMainJava:File = file.resolvePath("src/main/java");
			if (!srcMainJava.exists || !srcMainJava.isDirectory)
			{
				return null;
			}
			
			var listing:Array = file.getDirectoryListing();
			for each (var i:File in listing)
			{
				if (i.name == "pom.xml") {
					return (new FileLocation(i.nativePath));
				}
				if (i.name == "build.gradle") {
					return (new FileLocation(i.nativePath));
				}
			}
			
			return null;
		}

		public static function parse(file:FileLocation, projectName:String=null):JavaProjectVO
		{
			if(!projectName)
			{
				var airFile:File = File(file.fileBridge.getFile);
				projectName = airFile.name;
			}
			return new JavaProjectVO(file, projectName);
		}
	}
}