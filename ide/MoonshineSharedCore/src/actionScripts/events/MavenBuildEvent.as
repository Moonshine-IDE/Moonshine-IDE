package actionScripts.events
{
    import flash.events.Event;

    public class MavenBuildEvent extends Event
    {
        public static const START_MAVEN_BUILD:String = "startMavenBuild";
        public static const STOP_MAVEN_BUILD:String = "stopMavenBuild";

        public static const MAVEN_BUILD_FAILED:String = "mavenBuildFailed";
        public static const MAVEN_BUILD_COMPLETE:String = "mavenBuildComplete";
        public static const MAVEN_BUILD_TERMINATED:String = "mavenBuildTerminated";

        private var _buildId:String;
        private var _buildDirectory:String;
        private var _preCommands:Array;
        private var _commands:Array;

        private var _status:int;

        public function MavenBuildEvent(type:String, buildId:String, status:int, buildDirectory:String = null, preCommands:Array = null, commands:Array = null)
        {
            super(type, false, false);

            _buildId = buildId;
            _buildDirectory = buildDirectory;
            _preCommands = preCommands ? preCommands : [];
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

        public function get preCommands():Array
        {
            return _preCommands;
        }

        public function get commands():Array
        {
            return _commands;
        }

        public function get status():int
        {
            return _status;
        }
    }
}
