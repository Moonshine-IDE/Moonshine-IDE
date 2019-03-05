package actionScripts.plugin.java.javaproject.importer
{
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
	import actionScripts.utils.GradleBuildUtil;
	import actionScripts.utils.MavenPomUtil;

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
			var separator:String = javaProject.projectFolder.file.fileBridge.separator;
			var sourceDirectory:String = null;

			const defaultSourceFolderPath:String = "src".concat(separator, "main", separator, "java");

			if (javaProject.hasPom())
			{
				var pomFile:FileLocation = new FileLocation(javaProject.mavenBuildOptions.mavenBuildPath.concat(separator,"pom.xml"));

				var fileContent:Object = pomFile.fileBridge.read();
				var xsiNamespace:Namespace = new Namespace("", "http://maven.apache.org/POM/4.0.0");
				javaProject.mavenBuildOptions.parse(new XML(fileContent).xsiNamespace::properties);

				sourceDirectory = MavenPomUtil.getProjectSourceDirectory(pomFile);

				if (!sourceDirectory)
				{
					sourceDirectory = defaultSourceFolderPath;
				}
			}
			else if (javaProject.hasGradleBuild())
			{
				var gradleFile:FileLocation = javaProject.projectFolder.file.fileBridge.resolvePath("build.gradle");
				sourceDirectory = GradleBuildUtil.getProjectSourceDirectory(gradleFile);
			}

			if (sourceDirectory)
			{
				javaProject.sourceFolder = javaProject.projectFolder.file.fileBridge.resolvePath(sourceDirectory);
			}

			if (!sourceDirectory || !javaProject.sourceFolder.fileBridge.exists)
			{
				javaProject.sourceFolder = javaProject.projectFolder.file.fileBridge.resolvePath("src");
			}

			javaProject.classpaths.push(javaProject.sourceFolder);

			return javaProject;
		}
	}
}