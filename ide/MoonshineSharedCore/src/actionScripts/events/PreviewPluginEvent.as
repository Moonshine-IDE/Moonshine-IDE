package actionScripts.events
{
    import actionScripts.valueObjects.FileWrapper;

    import flash.events.Event;

    public class PreviewPluginEvent extends Event
    {
        public static const PREVIEW_VISUALEDITOR_FILE:String = "previewVisualEditorFile";
        public static const STOP_VISUALEDITOR_PREVIEW:String = "stopVisualEditorPreview";

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
