package actionScripts.plugin.projectPanel.events
{
    import actionScripts.interfaces.IViewWithTitle;

    import flash.events.Event;

    public class ProjectPanelPluginEvent extends Event
    {
        public static const ADD_VIEW_TO_PROJECT_PANEL:String = "addViewToProjectPanel";
        public static const REMOVE_VIEW_TO_PROJECT_PANEL:String = "removeViewToProjectPanel";
        public static const SELECT_VIEW_IN_PROJECT_PANEL:String = "selectViewInProjectPanel";

        private var _view:IViewWithTitle;

        public function ProjectPanelPluginEvent(type:String, view:IViewWithTitle)
        {
            super(type, false, false);

            this._view = view;
        }

        public function get view():IViewWithTitle
        {
            return _view;
        }
    }
}
