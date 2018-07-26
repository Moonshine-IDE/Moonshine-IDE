package actionScripts.plugin.java.javaproject.importer
{
	import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
	import actionScripts.factory.FileLocation;
	import flash.filesystem.File;

	public class MavenImporter
	{
		public static function test(file:File):FileLocation
		{
			if (!file.exists) return null;
			
			var listing:Array = file.getDirectoryListing();
			for each (var i:File in listing)
			{
				if (i.name == "pom.xml") {
					return (new FileLocation(i.nativePath));
				}
			}
			
			return null;
		}

		public static function parse(file:FileLocation, projectName:String=null):JavaProjectVO
		{
			var project:JavaProjectVO = new JavaProjectVO(file, projectName);
			return project;
		}
	}
}