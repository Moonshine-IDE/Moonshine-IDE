package actionScripts.plugin.java.javaproject.exporter
{
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;

    public class JavaExporter
    {
        public static function export(project:JavaProjectVO):void
        {
            if (!project.hasPom()) return;

            var separator:String = project.projectFolder.file.fileBridge.separator;
            var pomFile:FileLocation = new FileLocation(project.mavenBuildOptions.mavenBuildPath.concat(separator,"pom.xml"));
            var fileContent:Object = pomFile.fileBridge.read();
            var xsiNamespace:Namespace = new Namespace("", "http://maven.apache.org/POM/4.0.0");
            var pomXML:XML = new XML(fileContent);
            var build:XML = null;

            XML.ignoreWhitespace = true;
            XML.ignoreComments = false;

            var propertiesName:QName = new QName(xsiNamespace, "properties");
            var saveFile:Boolean;

            if (!pomXML.hasOwnProperty(propertiesName))
            {
                pomXML.xsiNamespace::properties.projectbuildaction = project.mavenBuildOptions.commandLine;
                saveFile = true;
            }
            else
            {
                var properties:XMLList = pomXML.xsiNamespace::properties;
                var currentProjectbuildaction:String = String(properties.xsiNamespace::projectbuildaction);
                if(project.mavenBuildOptions.commandLine != currentProjectbuildaction)
                {
                    properties.xsiNamespace::projectbuildaction = new XML("<projectbuildaction>" + project.mavenBuildOptions.commandLine + "</projectbuildaction>");
                    saveFile = true;
                }
            }

            var sourceFolder:String = project.projectFolder.file.fileBridge.getRelativePath(project.sourceFolder);
            var buildName:QName = new QName(xsiNamespace, "build");
            if (!pomXML.hasOwnProperty(buildName))
            {
                pomXML.xsiNamespace::build.sourceDirectory = new XML("<sourceFolder>" + sourceFolder + "</sourceFolder>");

                saveFile = true;
            }
            else
            {
                var sourceDirectory:QName = new QName(xsiNamespace, "sourceDirectory");
                build = XML(pomXML.xsiNamespace::build);

                if (!build.hasOwnProperty(sourceDirectory))
                {
                    pomXML.xsiNamespace::build.sourceDirectory = sourceFolder;
                    saveFile = true;
                }
                else
                {
                    var currentSourceFolder:String = String(build.xsiNamespace::sourceDirectory);
                    if(sourceFolder != currentSourceFolder)
                    {
                        build.xsiNamespace::sourceDirectory = sourceFolder;
                        saveFile = true;
                    }
                }
            }

            if (saveFile)
            {
                pomFile.fileBridge.save(pomXML.toXMLString());
            }
        }
    }
}
