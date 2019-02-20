package actionScripts.plugin.java.javaproject.importer
{
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
	import actionScripts.utils.MavenPomUtil;

	import flash.filesystem.File;

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

		public static function parse(projectFolder:FileLocation, projectName:String=null):JavaProjectVO
		{
			if(!projectName)
			{
				var airFile:Object = projectFolder.fileBridge.getFile;
				projectName = airFile.name;
			}

			var javaProject:JavaProjectVO = new JavaProjectVO(projectFolder, projectName);

			var pomFile:FileLocation = javaProject.projectFolder.file.fileBridge.resolvePath("pom.xml");
			if (pomFile.fileBridge.exists)
			{
				var sourceDirectory:String = MavenPomUtil.getProjectSourceDirectory(pomFile);
				javaProject.sourceFolder = javaProject.projectFolder.file.fileBridge.resolvePath(sourceDirectory);

				javaProject.classpaths.push(javaProject.sourceFolder);
			}

			return javaProject;
		}
	}
}