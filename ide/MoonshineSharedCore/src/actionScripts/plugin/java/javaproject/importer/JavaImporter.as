package actionScripts.plugin.java.javaproject.importer
{
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
	import actionScripts.utils.GradleBuildUtil;
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
			var gradleFile:FileLocation = javaProject.projectFolder.file.fileBridge.resolvePath("build.gradle");

			var sourceDirectory:String = null;
			if (pomFile.fileBridge.exists)
			{
				sourceDirectory = MavenPomUtil.getProjectSourceDirectory(pomFile);
			}
			else if (gradleFile.fileBridge.exists)
			{
				sourceDirectory = GradleBuildUtil.getProjectSourceDirectory(gradleFile);
			}
			
			var separator:String = javaProject.projectFolder.file.fileBridge.separator;
			const defaultSourceFolderPath:String = "src".concat(separator, "main", separator, "java");

			if (!sourceDirectory)
			{
				sourceDirectory = defaultSourceFolderPath;
			}

			javaProject.sourceFolder = javaProject.projectFolder.file.fileBridge.resolvePath(sourceDirectory);
			if (!javaProject.sourceFolder.fileBridge.exists)
			{
				javaProject.sourceFolder = javaProject.projectFolder.file.fileBridge.resolvePath("src");
			}

			javaProject.classpaths.push(javaProject.sourceFolder);

			return javaProject;
		}

		private static function parsePom(pomFile:FileLocation, javaProject:JavaProjectVO):void
		{

		}

		private static function parseGradle(gradleFile:FileLocation, javaProject:JavaProjectVO):void
		{

		}
	}
}