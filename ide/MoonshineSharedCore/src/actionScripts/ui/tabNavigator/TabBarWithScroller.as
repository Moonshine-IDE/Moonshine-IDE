package actionScripts.ui.tabNavigator
{
    import actionScripts.ui.tabNavigator.skin.TabBarWithScrollerSkin;
    import actionScripts.ui.tabview.TabEvent;

    import mx.events.CollectionEvent;
    import mx.events.CollectionEventKind;

    import spark.components.ButtonBarButton;

    import spark.components.TabBar;
	import flash.events.Event;

    [Style(name="closeButtonVisible", type="Boolean", inherit="no", theme="spark")]
    [Event(name="closeButtonClick", type="flash.events.MouseEvent")]
	public class TabBarWithScroller extends TabBar 
	{
        private var _maxElementCountWithoutScroller:int;

		public function TabBarWithScroller()
		{
			super();

            this.setStyle("cornerRadius", 1);
            this.setStyle("closeButtonVisible", true);
			this.setStyle("skinClass", TabBarWithScrollerSkin);
		}

        private var _orientation:String = "top";

        [Inspectable(enumeration="top,left,bottom,right", defaultValue="top")]
        [Bindable(event="orientationChanged")]
        public function get orientation():String
        {
            return _orientation;
        }

        public function set orientation(value:String):void
        {
            if (_orientation != value)
            {
                _orientation = value;
                dispatchEvent(new Event("orientationChanged"));
                this.invalidateSkinState();
            }
        }

        private var _scrollable:Boolean;

        [Bindable(event="scrollableChanged")]
        public function get scrollable():Boolean
        {
            return _scrollable;
        }

        public function set scrollable(value:Boolean):void
        {
            if (_scrollable != value)
            {
                _scrollable = value;
                dispatchEvent(new Event("scrollableChanged"));
                this.refreshMaxElementCountWithoutScroller();
                this.invalidateSkinState();
            }
        }

        override protected function getCurrentSkinState():String
        {
            var state:String = super.getCurrentSkinState();

            if (this.scrollable)
            {
                if (this.dataGroup && _maxElementCountWithoutScroller < this.dataGroup.numElements)
                {
                    if (this.orientation == "top" ||
                            this.orientation == "left" ||
                            this.orientation == "right")
                    {
                        state += "WithTopScroller";
                    }
                    else if (this.orientation == "bottom")
                    {
                        state += "WithBottomScroller";
                    }
                }
                else
                {
                    state = "normal";
                }
            }
            else if (this.orientation == "left" || this.orientation == "right")
            {
                state = "normalWithLeftRightNoScroller";
            }

            return state;
        }

        override protected function measure():void
        {
            super.measure();

            this.refreshMaxElementCountWithoutScroller();
        }

        override protected function dataProvider_collectionChangeHandler(event:Event):void
        {
            super.dataProvider_collectionChangeHandler(event);

            var collectionEvent:CollectionEvent = event as CollectionEvent;
            if (collectionEvent.kind == CollectionEventKind.ADD || collectionEvent.kind == CollectionEventKind.REMOVE)
            {
                this.invalidateSkinState();
            }
        }

        private function refreshMaxElementCountWithoutScroller():void
        {
            if (this.dataGroup && this.scrollable)
            {
                var typicalItem:ButtonBarButton = this.dataGroup.getElementAt(0) as ButtonBarButton;
                if (typicalItem && _maxElementCountWithoutScroller == 0)
                {
                    _maxElementCountWithoutScroller = this.measuredWidth / typicalItem.measuredWidth;
                    this.invalidateSkinState();
                }
            }
        }
    }
}