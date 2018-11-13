package actionScripts.events
{
    import flash.events.Event;

    public class MavenBuildEvent extends Event
    {
        public static const START_MAVEN_BUILD:String = "startMavenBuild";
        public static const STOP_MAVEN_BUILD:String = "stopMavenBuild";

        public static const MAVEN_BUILD_FAILED:String = "mavenBuildFailed";
        public static const MAVEN_BUILD_COMPLETE:String = "mavenBuildComplete";

        private var _buildId:String;
        private var _buildDirectory:String;
        private var _commands:Array;

        public function MavenBuildEvent(type:String, buildId:String, buildDirectory:String = null, commands:Array = null)
        {
            super(type, false, false);

            _buildId = buildId;
            _buildDirectory = buildDirectory;
            _commands = commands ? commands : [];
        }

        public function get buildId():String
        {
            return _buildId;
        }

        public function get buildDirectory():String
        {
            return _buildDirectory;
        }

        public function get commands():Array
        {
            return _commands;
        }
    }
}
