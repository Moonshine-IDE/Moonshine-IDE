package actionScripts.ui.tabNavigator
{
    import actionScripts.ui.tabNavigator.event.ButtonBarButtonWithCloseEvent;
    import actionScripts.ui.tabNavigator.event.TabNavigatorEvent;
    import actionScripts.ui.tabNavigator.skin.TabNavigatorWithOrientationSkin;

    import flash.events.Event;
    import flash.events.MouseEvent;

    import spark.components.ButtonBarButton;
    import spark.components.NavigatorContent;
    import spark.containers.Navigator;

    [Event(name="tabClose", type="actionScripts.ui.tabNavigator.event.TabNavigatorEvent")]
    public class TabNavigatorWithOrientation extends Navigator
	{
		public function TabNavigatorWithOrientation()
		{
			super();

			this.setStyle("skinClass", TabNavigatorWithOrientationSkin);
		}

		[SkinPart(required=true)]
		public var tabBar:TabBarWithScroller;

		private var _orientation:String = "top";
		
		[Inspectable(enumeration="top,left,bottom,right", defaultValue="top")]
		[Bindable("orientationChanged")]
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
		[Bindable("scrollableChanged")]
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
				this.invalidateSkinState();
			}	
		}

        override protected function partAdded(partName:String, instance:Object):void
        {
            super.partAdded(partName, instance);

			if (instance == tabBar)
			{
                tabBar.setStyle("color", "0xEEEEEE");
                tabBar.setStyle("fontSize", 11);
                //tabBar.setStyle("fontFamily", "DejaVuSans");
				tabBar.addEventListener(ButtonBarButtonWithCloseEvent.CLOSE_BUTTON_CLICK, onTabBarWithScrollerCloseButtonClick);
			}
        }

        override protected function partRemoved(partName:String, instance:Object):void
        {
            super.partRemoved(partName, instance);

            if (instance == tabBar)
            {
                tabBar.removeEventListener(ButtonBarButtonWithCloseEvent.CLOSE_BUTTON_CLICK, onTabBarWithScrollerCloseButtonClick);
            }
        }

        override protected function getCurrentSkinState():String
		{
			var state:String = super.getCurrentSkinState();

			if (state != "disabled")
			{
				switch (this.orientation)
				{
					case "top":
						state += "WithTopTabBar";
						break;
					case "left":
						state += scrollable ? "WithTopTabBar" : "WithLeftTabBar";
						break;
					case "right":
						state += scrollable ? "WithTopTabBar" : "WithRightTabBar";
						break;		
					case "bottom":
						state += "WithBottomTabBar";
						break;
				}			
			}
			
			
			return state;
		}

		public function setSelectedTabLabel(label:String):void
		{
			var selectedTab:NavigatorContent = (this.selectedItem as NavigatorContent);
			
			if (selectedTab.label != label)
			{
				var item:ButtonBarButton = tabBar.dataGroup.getElementAt(this.selectedIndex) as ButtonBarButton;

				selectedTab.label = label;
				item.label = label;
				
				dispatchEvent(new Event("itemUpdated"));
			}
		}

        private function onTabBarWithScrollerCloseButtonClick(event:ButtonBarButtonWithCloseEvent):void
        {
            this.dispatchEvent(new TabNavigatorEvent(TabNavigatorEvent.TAB_CLOSE, event.itemIndex));
        }
    }
}