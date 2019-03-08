package actionScripts.plugin.java.javaproject.exporter
{
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
    import actionScripts.utils.SerializeUtil;

    public class JavaExporter
    {
        public static function export(project:JavaProjectVO):void
        {
            var projectXML:XML = new XML("<project></project>");

            projectXML.appendChild(exportPaths(project.classpaths, <classpaths />, <class />, project));
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
            /*if (!project.hasPom()) return;

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
            }*/
        }

        private static function exportPaths(paths:Vector.<FileLocation>, container:XML, element:XML, project:JavaProjectVO):XML
        {
            for each (var location:FileLocation in paths)
            {
                var e:XML = element.copy();
                e.appendChild(location.fileBridge.nativePath);
                container.appendChild(e);
            }

            if (paths.length == 0)
            {
                container.appendChild(<!-- <empty/> -->);
            }

            return container;
        }
    }
}
