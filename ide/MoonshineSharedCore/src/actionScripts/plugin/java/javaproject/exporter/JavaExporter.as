package actionScripts.plugin.java.javaproject.exporter
{
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
    import actionScripts.utils.MavenPomUtil;
    import actionScripts.utils.SerializeUtil;

    public class JavaExporter
    {
        public static function export(project:JavaProjectVO):void
        {
            XML.ignoreWhitespace = true;
            XML.ignoreComments = false;

            var projectXML:XML = new XML("<project></project>");

            projectXML.appendChild(project.mavenBuildOptions.toXML());

            var buildXML:XML = new XML(<build></build>);
            var build:Object = {
                mainclass: project.mainClassName
            };
            buildXML.appendChild(SerializeUtil.serializePairs(build, <option/>));

            projectXML.appendChild(buildXML);

            var projectSettings:FileLocation = project.folderLocation.resolvePath(project.projectName + ".javaproj");
            if (!projectSettings.fileBridge.exists)
            {
                projectSettings.fileBridge.createFile();
            }

            projectSettings.fileBridge.save(projectXML.toXMLString());

            if (!project.hasPom()) return;

            var separator:String = project.projectFolder.file.fileBridge.separator;
            var pomFile:FileLocation = new FileLocation(project.mavenBuildOptions.mavenBuildPath.concat(separator,"pom.xml"));
            var fileContent:Object = pomFile.fileBridge.read();
            var pomXML:XML = new XML(fileContent);

            var sourceFolder:String = project.projectFolder.file.fileBridge.getRelativePath(project.sourceFolder);
            pomXML = MavenPomUtil.getPomWithProjectSourceDirectory(pomXML, sourceFolder);
            pomXML = MavenPomUtil.getPomWithMainClass(pomXML, project.mainClassName);

            pomFile.fileBridge.save(pomXML.toXMLString());
        }
    }
}
