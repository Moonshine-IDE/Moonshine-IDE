package actionScripts.events
{
    import actionScripts.valueObjects.FileWrapper;

    import flash.events.Event;

    public class PreviewPluginEvent extends Event
    {
        public static const PREVIEW_PRIMEFACES_FILE:String = "previewPrimeFacesFile";

        private var _fileWrapper:FileWrapper;

        public function PreviewPluginEvent(type:String, fileWrapper:FileWrapper)
        {
            super(type, false, false);

            _fileWrapper = fileWrapper;
        }

        public function get fileWrapper():FileWrapper
        {
            return _fileWrapper;
        }
    }
}
