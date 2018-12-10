package actionScripts.events
{
    import actionScripts.factory.FileLocation;

    import flash.events.Event;

    public class ConsoleBuildEvent extends Event
    {
        private var _arguments:Array;
        private var _buildDirectory:FileLocation;

        public function ConsoleBuildEvent(type:String, arguments:Array = null, buildDirectory:FileLocation = null)
        {
            super(type, false, false);

            _arguments = arguments;
            _buildDirectory = buildDirectory;
        }

        public function get arguments():Array
        {
            return _arguments;
        }

        public function get buildDirectory():FileLocation
        {
            return _buildDirectory;
        }
    }
}
