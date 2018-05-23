package actionScripts.plugin.projectPanel
{
    import actionScripts.plugin.IPlugin;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.projectPanel.events.ProjectPanelPluginEvent;
    import actionScripts.ui.LayoutModifier;
    import actionScripts.ui.divider.IDEVDividedBox;
    import actionScripts.ui.tabNavigator.TabNavigatorWithOrientation;

    import flash.events.MouseEvent;

    import mx.containers.dividedBoxClasses.BoxDivider;
    import mx.core.IUIComponent;
    import mx.core.UIComponent;

    import mx.events.DividerEvent;
    import mx.events.FlexEvent;
    import mx.managers.CursorManager;
    import mx.managers.CursorManagerPriority;

    import spark.components.NavigatorContent;

    public class ProjectPanelPlugin extends PluginBase implements IPlugin
    {
        override public function get name():String { return "ProjectPanel"; }
        override public function get author():String { return "Moonshine Project Team"; }

        [Embed("/elements/images/Divider_collapse.png")]
        private const customDividerSkinCollapse:Class;
        [Embed("/elements/images/Divider_expand.png")]
        private const customDividerSkinExpand:Class;

        private var view:TabNavigatorWithOrientation;
        private var isOverTheExpandCollapseButton:Boolean;
        private var cursorID:int = CursorManager.NO_CURSOR;
        private var isProjectPanelHidden:Boolean;

        private var views:Array;

        public function ProjectPanelPlugin()
        {
            super();
        }

        override public function activate():void
        {
            super.activate();

            views = [];

            view = new TabNavigatorWithOrientation();
            view.addEventListener(FlexEvent.CREATION_COMPLETE, onViewCreationComplete);
            view.percentWidth = 100;

            var tempObj:Object = {};
            tempObj.callback = hideCommand;
            tempObj.commandDesc = "Minimize the console frame.  Click and drag to expand it againMinimize the console frame.  Click and drag to expand it again..";
            registerCommand("hide", tempObj);

            //model.mainView.bodyPanel.addChild(consoleView);

            var parentView:IDEVDividedBox = model.mainView.bodyPanel;
            parentView.addElement(view);

            parentView.addEventListener(DividerEvent.DIVIDER_RELEASE, onProjectPanelDividerRelease);
            model.mainView.mainPanel.addEventListener(DividerEvent.DIVIDER_RELEASE, onSidebarDividerReleased);

            var divider:BoxDivider = parentView.getDividerAt(0);
            divider.addEventListener(MouseEvent.MOUSE_MOVE, onDividerMouseOver);
            divider.addEventListener(MouseEvent.MOUSE_OUT, onDividerMouseOut);

            dispatcher.addEventListener(ProjectPanelPluginEvent.ADD_VIEW_TO_PROJECT_PANEL, addViewToProjectPanelHandler);
        }

        override public function deactivate():void
        {
            super.deactivate();

            views = null;

            unregisterCommand("hide");

            model.mainView.bodyPanel.removeEventListener(DividerEvent.DIVIDER_RELEASE, onProjectPanelDividerRelease);
            model.mainView.mainPanel.removeEventListener(DividerEvent.DIVIDER_RELEASE, onSidebarDividerReleased);

            var divider:BoxDivider = model.mainView.bodyPanel.getDividerAt(0);
            divider.removeEventListener(MouseEvent.MOUSE_MOVE, onDividerMouseOver);
            divider.removeEventListener(MouseEvent.MOUSE_OUT, onDividerMouseOut);

            dispatcher.removeEventListener(ProjectPanelPluginEvent.ADD_VIEW_TO_PROJECT_PANEL, addViewToProjectPanelHandler);
        }

        private function addViewToProjectPanelHandler(event:ProjectPanelPluginEvent):void
        {
            if (event.view && !views.some(function hasView(item:String, index:int, arr:Array):Boolean
                {
                        return item == event.view.title;
                }))
            {
                var navContent:NavigatorContent = new NavigatorContent();
                navContent.label = event.view.title;

                navContent.addElement(event.view as UIComponent);

                view.addElement(navContent);

                views.push(event.view.title);

                view.selectedIndex = view.numElements - 1;
            }
        }

        private function onViewCreationComplete(event:FlexEvent):void
        {
            view.removeEventListener(FlexEvent.CREATION_COMPLETE, onViewCreationComplete);

            setProjectPanelVisibility(LayoutModifier.isProjectPanelCollapsed);
            if (!LayoutModifier.isProjectPanelCollapsed)
            {
                setProjectPanelHeight(LayoutModifier.projectPanelHeight);
            }
            else
            {
                setProjectPanelHeight(0);
            }
        }

        private function onProjectPanelDividerRelease(event:DividerEvent):void
        {
            // consider an expand/collapse click
            if (isOverTheExpandCollapseButton)
            {
                setProjectPanelVisibility(!isProjectPanelHidden);
                if (!isProjectPanelHidden && LayoutModifier.projectPanelHeight != -1)
                {
                    this.setProjectPanelHeight(LayoutModifier.projectPanelHeight);
                }
                else
                {
                    this.setProjectPanelHeight(0);
                }

                return;
            }

            var tmpHeight:int = view.parent.height - view.parent.mouseY - view.minHeight;
            if (tmpHeight <= 2)
            {
                setProjectPanelVisibility(true);
                LayoutModifier.projectPanelHeight = -1;
            }
            else
            {
                setProjectPanelVisibility(false);
                LayoutModifier.projectPanelHeight = tmpHeight;
            }
        }

        private function onSidebarDividerReleased(event:DividerEvent):void
        {
            LayoutModifier.sidebarWidth = event.target.mouseX;
        }

        private function onDividerMouseOut(event:MouseEvent):void
        {
            model.mainView.bodyPanel.cursorManager.removeCursor(cursorID);
            model.mainView.bodyPanel.cursorManager.removeCursor(model.mainView.bodyPanel.cursorManager.currentCursorID);
        }

        private function onDividerMouseOver(event:MouseEvent):void
        {
            onDividerMouseOut(null);

            var dividerWidth:Number = event.target.width;
            // divider skin width is 67
            var parts:Number = (dividerWidth - 67)/2;
            if (event.localX < parts || event.localX > parts+67)
            {
                var cursorClass:Class = event.target.getStyle("verticalDividerCursor") as Class;
                cursorID = model.mainView.bodyPanel.cursorManager.setCursor(cursorClass, CursorManagerPriority.HIGH, 0, 0);
                isOverTheExpandCollapseButton = false;
            }
            else
            {
                isOverTheExpandCollapseButton = true;
            }
        }

        public function hideCommand(args:Array):void
        {
            setProjectPanelVisibility(true);
        }

        private function setProjectPanelVisibility(value:Boolean):void
        {
            LayoutModifier.isProjectPanelCollapsed = value;
            isProjectPanelHidden = value;
            model.mainView.bodyPanel.setStyle('dividerSkin', !isProjectPanelHidden ? customDividerSkinCollapse : customDividerSkinExpand);
        }

        public function setProjectPanelHeight(newTargetHeight:int):void
        {
            // no fullscreening console, it's confusing
            newTargetHeight = Math.min(newTargetHeight, view.parent.height - 100);
            newTargetHeight = Math.max(newTargetHeight, 0);

            newTargetHeight += view.minHeight;
            view.height = (newTargetHeight < view.minHeight) ? view.minHeight : newTargetHeight;
        }
    }
}
