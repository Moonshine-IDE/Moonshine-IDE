package actionScripts.events
{
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.valueObjects.FileWrapper;

    import flash.events.Event;

    public class PreviewPluginEvent extends Event
    {
        public static const START_VISUALEDITOR_PREVIEW:String = "startVisualEditorPreview";
        public static const STOP_VISUALEDITOR_PREVIEW:String = "stopVisualEditorPreview";

        public static const PREVIEW_START_COMPLETE:String = "previewStartComplete";
        public static const PREVIEW_START_FAILED:String = "previewStartFailed";
        public static const PREVIEW_STOPPED:String = "previewStopped";

        public function PreviewPluginEvent(type:String, fileWrapper:Object = null, project:AS3ProjectVO = null)
        {
            super(type, false, false);

            _fileWrapper = fileWrapper;
            _project = project;
        }

        private var _fileWrapper:Object;

        public function get fileWrapper():Object
        {
            return _fileWrapper;
        }

        private var _project:AS3ProjectVO;

        public function get project():AS3ProjectVO
        {
            return _project;
        }
    }
}
