package actionScripts.events
{
    import actionScripts.valueObjects.FileWrapper;
    import flash.events.Event;

    public class HiddenFilesEvent extends Event
    {
        public static const MARK_FILES_AS_VISIBLE:String = "markFilesAsVisible";
        public static const MARK_FILES_AS_HIDDEN:String = "markFilesAsHidden";

        private var _fileWrapper:FileWrapper;

        public function HiddenFilesEvent(type:String, fileWrapper:FileWrapper)
        {
            super(type);

            _fileWrapper = fileWrapper;
        }

        public function get fileWrapper():FileWrapper
        {
            return _fileWrapper;
        }
    }
}
