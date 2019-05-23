package actionScripts.ui.tabNavigator
{
    import spark.components.ButtonBarButton;

    [Style(name="closeButtonVisible", type="Boolean", inherit="no", theme="spark")]
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
