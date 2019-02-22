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
            var sourceFolder:String = project.projectFolder.file.fileBridge.getRelativePath(project.sourceFolder);
            var build:XML = null;

            XML.ignoreWhitespace = true;
            XML.ignoreComments = false;

            var buildName:QName = new QName(xsiNamespace, "build");
            if (!pomXML.hasOwnProperty(buildName))
            {
                pomXML.xsiNamespace::build.sourceDirectory = new XML("<sourceFolder>" + sourceFolder + "</sourceFolder>");

                pomFile.fileBridge.save(pomXML.toXMLString());
            }
            else
            {
                var sourceDirectory:QName = new QName(xsiNamespace, "sourceDirectory");
                build = XML(pomXML.xsiNamespace::build);

                if (!build.hasOwnProperty(sourceDirectory))
                {
                    pomXML.xsiNamespace::build.sourceDirectory = sourceFolder;
                    pomFile.fileBridge.save(pomXML.toXMLString());
                }
                else
                {
                    var currentSourceFolder:String = String(build.xsiNamespace::sourceDirectory);
                    if(sourceFolder != currentSourceFolder)
                    {
                        build.xsiNamespace::sourceDirectory = sourceFolder;
                        pomFile.fileBridge.save(pomXML.toXMLString());
                    }
                }
            }
        }
    }
}
