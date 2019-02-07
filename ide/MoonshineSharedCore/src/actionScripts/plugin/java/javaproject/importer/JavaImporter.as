package actionScripts.plugin.java.javaproject.importer
{
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;

	public class JavaImporter
	{
		public static function test(file:Object):FileLocation
		{
			if (!file.exists) return null;
			
			var listing:Array = file.getDirectoryListing();
			for each (var i:Object in listing)
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
				var airFile:Object = file.fileBridge.getFile;
				projectName = airFile.name;
			}
			return new JavaProjectVO(file, projectName);
		}
	}
}