package actionScripts.plugin.java.javaproject.exporter
{
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;

    public class JavaExporter
    {
        public static function export(project:JavaProjectVO):void
        {
            if (!project.hasPom()) return;

            var pomFile:FileLocation = new FileLocation(project.mavenBuildOptions.mavenBuildPath);
            var fileContent:Object = pomFile.fileBridge.read();
            var xsiNamespace:Namespace = new Namespace("", "http://maven.apache.org/POM/4.0.0");
            var pomXML:XML = new XML(fileContent);
            var buildName:QName = new QName(xsiNamespace, "build");
            var sourceFolder:String = project.projectFolder.file.fileBridge.getRelativePath(project.sourceFolder);
            var build:XML = null;

            XML.ignoreWhitespace = true;
            XML.ignoreComments = false;
            if (!pomXML.hasOwnProperty(buildName))
            {
                pomXML.xsiNamespace::build.sourceDirectory = new XML("<sourceFolder>" + sourceFolder + "</sourceFolder>");

                pomFile.fileBridge.save(pomXML.toXMLString());
            }
            else
            {
                build = XML(pomXML.xsiNamespace::build);
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
