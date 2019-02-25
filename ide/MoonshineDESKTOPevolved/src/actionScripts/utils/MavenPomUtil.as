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
    }
}
