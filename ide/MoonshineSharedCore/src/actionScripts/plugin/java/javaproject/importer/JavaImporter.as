package actionScripts.plugin.java.javaproject.importer
{
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.core.importer.FlashDevelopImporterBase;
	import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
	import actionScripts.utils.MavenPomUtil;

	public class JavaImporter extends FlashDevelopImporterBase
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

		public static function parse(projectFolder:FileLocation, projectName:String=null, settingsFileLocation:FileLocation = null):JavaProjectVO
		{
			if(!projectName)
			{
				var airFile:Object = projectFolder.fileBridge.getFile;
				projectName = airFile.name;
			}

            if (!settingsFileLocation)
            {
                settingsFileLocation = projectFolder.fileBridge.resolvePath(projectName + ".javaproj");
            }

            var javaProject:JavaProjectVO = new JavaProjectVO(projectFolder, projectName);

            var sourceDirectory:String = null;
			var settingsData:XML = null;
			if (settingsFileLocation.fileBridge.exists)
			{
				settingsData = new XML(settingsFileLocation.fileBridge.read());
                parsePaths(settingsData.classpaths["class"], javaProject.classpaths, javaProject, "path");
                javaProject.mainClassName = settingsData.build.option.@mainclass;

                if (javaProject.classpaths.length > 0)
                {
                    sourceDirectory = javaProject.classpaths[0].fileBridge.nativePath;
                }
            }

			var separator:String = javaProject.projectFolder.file.fileBridge.separator;

			const defaultSourceFolderPath:String = "src".concat(separator, "main", separator, "java");

			if (javaProject.hasPom())
			{
				if (settingsData)
				{
					javaProject.mavenBuildOptions.parse(settingsData.mavenBuild);
				}

				if (!sourceDirectory)
				{
					var pomFile:FileLocation = new FileLocation(
							javaProject.mavenBuildOptions.mavenBuildPath.concat(separator,"pom.xml")
					);
					sourceDirectory = MavenPomUtil.getProjectSourceDirectory(pomFile);

					if (!sourceDirectory)
					{
						sourceDirectory = defaultSourceFolderPath;
					}
				}
			}

			if (sourceDirectory)
			{
				javaProject.sourceFolder = javaProject.projectFolder.file.fileBridge.resolvePath(sourceDirectory);
			}

			if (!sourceDirectory || !javaProject.sourceFolder.fileBridge.exists)
			{
				javaProject.sourceFolder = javaProject.projectFolder.file.fileBridge.resolvePath("src");
			}

			return javaProject;
		}
	}
}