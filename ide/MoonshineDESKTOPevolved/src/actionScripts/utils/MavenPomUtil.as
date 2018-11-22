package actionScripts.utils
{
    import actionScripts.factory.FileLocation;

    public class MavenPomUtil
    {
        public static function getProjectId(pomLocation:FileLocation):String
        {
            var fileContent:Object = pomLocation.fileBridge.read();
            var pomXML:XML = new XML(fileContent);

            return "";
        }

        public static function getProjectVersion(pomLocation:FileLocation):String
        {
            var fileContent:Object = pomLocation.fileBridge.read();
            var pomXML:XML = new XML(fileContent);

            return "";
        }
    }
}
