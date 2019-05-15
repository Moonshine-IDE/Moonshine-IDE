package actionScripts.events
{
    import flash.events.Event;

    public class GradleBuildEvent extends Event
    {
        public static const START_GRADLE_BUILD:String = "startGradleBuild";
        public static const STOP_GRADLE_BUILD:String = "stopGradleBuild";
		public static const REFRESH_GRADLE_CLASSPATH:String = "refreshGradleClasspath";

        public static const GRADLE_BUILD_FAILED:String = "gradleBuildFailed";
        public static const GRADLE_BUILD_COMPLETE:String = "gradleBuildComplete";
        public static const GRADLE_BUILD_TERMINATED:String = "gradleBuildTerminated";

        private var _buildId:String;
        private var _buildDirectory:String;
        private var _preCommands:Array;
        private var _commands:Array;

        private var _status:int;

        public function GradleBuildEvent(type:String, buildId:String, status:int, buildDirectory:String = null, preCommands:Array = null, commands:Array = null)
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
