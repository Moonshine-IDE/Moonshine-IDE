package actionScripts.plugin.java.javaproject.exporter
{
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;

    public class JavaExporter
    {
        public static function export(project:JavaProjectVO):void
        {
            var pomFile:FileLocation = project.projectFolder.file.fileBridge.resolvePath("pom.xml");
            var fileContent:Object = pomFile.fileBridge.read();
            var xsiNamespace:Namespace = new Namespace("", "http://maven.apache.org/POM/4.0.0");
            var pomXML:XML = new XML(fileContent);

            var build:XML = XML(pomXML.xsiNamespace::build);
            var sourceFolder:String = project.projectFolder.file.fileBridge.getRelativePath(project.sourceFolder);
            var currentSourceFolder:String = String(build.xsiNamespace::sourceDirectory);
            if (sourceFolder != currentSourceFolder)
            {
                build.xsiNamespace::sourceDirectory = sourceFolder;

                XML.ignoreWhitespace = true;
                pomFile.fileBridge.save(pomXML.toXMLString());
            }
        }
    }
}
