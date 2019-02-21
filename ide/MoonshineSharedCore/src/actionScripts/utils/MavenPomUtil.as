package actionScripts.utils
{
    import actionScripts.factory.FileLocation;

    public class MavenPomUtil
    {
        public static function getProjectId(pomLocation:FileLocation):String
        {
            var fileContent:Object = pomLocation.fileBridge.read();
            var xsiNamespace:Namespace = new Namespace("", "http://maven.apache.org/POM/4.0.0");
            var pomXML:XML = new XML(fileContent);

            return String(pomXML.xsiNamespace::artifactId);
        }

        public static function getProjectVersion(pomLocation:FileLocation):String
        {
            var fileContent:Object = pomLocation.fileBridge.read();
            var xsiNamespace:Namespace = new Namespace("", "http://maven.apache.org/POM/4.0.0");
            var pomXML:XML = new XML(fileContent);

            return String(pomXML.xsiNamespace::version);
        }

        public static function getProjectSourceDirectory(pomLocation:FileLocation):String
        {
            var fileContent:Object = pomLocation.fileBridge.read();
            var xsiNamespace:Namespace = new Namespace("", "http://maven.apache.org/POM/4.0.0");
            var pomXML:XML = new XML(fileContent);
            var buildName:QName = new QName(xsiNamespace, "build");

            if (pomXML.hasOwnProperty(buildName))
            {
                var build:XML = new XML(pomXML.xsiNamespace::build);
                var sourceDirectory:QName = new QName(xsiNamespace, "sourceDirectory");
                if (build.hasOwnProperty(sourceDirectory))
                {
                    return String(build.xsiNamespace::sourceDirectory);
                }
            }

            return "";
        }
    }
}
