package actionScripts.events
{
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.valueObjects.FileWrapper;

    import flash.events.Event;

    public class RefreshVisualEditorSourcesEvent extends Event
    {
        public static const REFRESH_VISUALEDITOR_SRC:String = "refreshVisualEditorSrc";

        private var _fileWrapper:FileWrapper;
        private var _project:AS3ProjectVO;

        public function RefreshVisualEditorSourcesEvent(type:String, fileWrapper:FileWrapper, project:AS3ProjectVO)
        {
            super(type, false, false);

            _fileWrapper = fileWrapper;
            _project = project;
        }

        public function get fileWrapper():FileWrapper
        {
            return _fileWrapper;
        }

        public function get project():AS3ProjectVO
        {
            return _project;
        }

        override public function clone():Event
        {
            return new RefreshVisualEditorSourcesEvent(this.type, this.fileWrapper, this.project);
        }
    }
}
