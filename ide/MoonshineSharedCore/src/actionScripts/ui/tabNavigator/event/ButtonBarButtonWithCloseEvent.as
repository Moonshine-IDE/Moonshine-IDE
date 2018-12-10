package actionScripts.ui.tabNavigator.event
{
    import flash.events.Event;

    public class ButtonBarButtonWithCloseEvent extends Event
    {
        public static const CLOSE_BUTTON_CLICK:String = "closeButtonClick";
        
        public function ButtonBarButtonWithCloseEvent(type:String, itemIndex:int = -1)
        {
            super(type);

            _itemIndex = itemIndex;
        }

        private var _itemIndex:int;
        public function get itemIndex():int
        {
            return _itemIndex;
        }
    }
}
