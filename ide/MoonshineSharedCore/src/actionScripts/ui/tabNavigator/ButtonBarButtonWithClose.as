package actionScripts.ui.tabNavigator
{
    import spark.components.ButtonBarButton;

    public class ButtonBarButtonWithClose extends ButtonBarButton
    {
        public function ButtonBarButtonWithClose()
        {
            super();

            mouseChildren = true;
        }

        [SkinPart(required=true)]
        public var closeTabButton:CloseTabButton;

        override public function set itemIndex(value:int):void
        {
            super.itemIndex = value;
            if (closeTabButton)
            {
                closeTabButton.itemIndex = value;
            }
        }
    }
}
