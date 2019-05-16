package actionScripts.utils
{
    import actionScripts.factory.FileLocation;

    public class GradleBuildUtil
    {
		public static var IS_GRADLE_STARTED:Boolean;
		
        public static function getProjectSourceDirectory(pomLocation:FileLocation):String
        {
            var fileContent:Object = pomLocation.fileBridge.read();
            if (fileContent)
            {
                var content:String = String(fileContent).replace(/(\r\n)+|\r+|\n+|\t+/g, "");

                var taskRegExp:RegExp = new RegExp(/\bsourceSets\b/);
                var taskIndex:int = content.search(taskRegExp);
                content = content.substr(taskIndex, content.length);

                taskRegExp = new RegExp(/\bsrcDirs\b/);
                taskIndex = content.search(taskRegExp);
                content = content.substr(taskIndex, content.length);

                var firstIndex:int = content.indexOf("[");
                var lastIndex:int = content.lastIndexOf("]");
                content = content.substring(firstIndex + 1, lastIndex);

                firstIndex = content.indexOf("'");
                lastIndex = content.lastIndexOf("'");
                content = content.substring(firstIndex + 1, lastIndex);

                return content;
            }

            return "";
        }
    }
}
