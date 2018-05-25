package actionScripts.ui.tabNavigator.event
{
    import flash.events.Event;

    public class TabNavigatorEvent extends Event
    {
        public static const TAB_CLOSE:String = "tabClose";

        public function TabNavigatorEvent(type:String, tabIndex:int = -1)
        {
            super(type, false, false);

            _tabIndex = tabIndex;
        }

        private var _tabIndex:int;
        public function get tabIndex():int
        {
            return _tabIndex;
        }
    }
}
