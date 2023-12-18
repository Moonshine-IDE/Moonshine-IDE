////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugin.projectPanel
{
    import flash.events.MouseEvent;
    
    import mx.containers.dividedBoxClasses.BoxDivider;
    import mx.core.UIComponent;
    import mx.events.DividerEvent;
    import mx.events.FlexEvent;
    import mx.managers.CursorManager;
    import mx.managers.CursorManagerPriority;
    
    import spark.components.NavigatorContent;
    
    import actionScripts.interfaces.IViewWithTitle;
    import actionScripts.plugin.IPlugin;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.projectPanel.events.ProjectPanelPluginEvent;
    import actionScripts.ui.LayoutModifier;
    import actionScripts.ui.divider.IDEVDividedBox;
    import actionScripts.ui.tabNavigator.TabNavigatorWithOrientation;
    import actionScripts.ui.tabNavigator.event.TabNavigatorEvent;
    import actionScripts.valueObjects.ConstantsCoreVO;

    public class ProjectPanelPlugin extends PluginBase implements IPlugin
    {
        override public function get name():String { return "ProjectPanel"; }
        override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }

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
            view.addEventListener(TabNavigatorEvent.TAB_CLOSE, onViewTabClose);

            view.percentWidth = 100;

            var tempObj:Object = {};
            tempObj.callback = hideCommand;
            tempObj.commandDesc = "Minimize the console frame.  Click and drag to expand it againMinimize the console frame.  Click and drag to expand it again..";
            registerCommand("hide", tempObj);

            var parentView:IDEVDividedBox = model.mainView.bodyPanel;
            parentView.addElement(view);

            parentView.addEventListener(DividerEvent.DIVIDER_RELEASE, onProjectPanelDividerRelease);
            model.mainView.mainPanel.addEventListener(DividerEvent.DIVIDER_RELEASE, onSidebarDividerReleased);

            var divider:BoxDivider = parentView.getDividerAt(0);
            divider.addEventListener(MouseEvent.MOUSE_MOVE, onDividerMouseOver);
            divider.addEventListener(MouseEvent.MOUSE_OUT, onDividerMouseOut);

            dispatcher.addEventListener(ProjectPanelPluginEvent.ADD_VIEW_TO_PROJECT_PANEL, addViewToProjectPanelHandler);
            dispatcher.addEventListener(ProjectPanelPluginEvent.REMOVE_VIEW_TO_PROJECT_PANEL, removeViewToProjectPanelHandler);
            dispatcher.addEventListener(ProjectPanelPluginEvent.SELECT_VIEW_IN_PROJECT_PANEL, selectViewInProjectPanelHandler);
			dispatcher.addEventListener(ProjectPanelPluginEvent.SHOW_PROJECT_PANEL, onShowProjectPanel);
			dispatcher.addEventListener(ProjectPanelPluginEvent.HIDE_PROJECT_PANEL, onHideProjectPanel);
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
            dispatcher.removeEventListener(ProjectPanelPluginEvent.REMOVE_VIEW_TO_PROJECT_PANEL, removeViewToProjectPanelHandler);
            dispatcher.removeEventListener(ProjectPanelPluginEvent.SELECT_VIEW_IN_PROJECT_PANEL, selectViewInProjectPanelHandler);
			dispatcher.removeEventListener(ProjectPanelPluginEvent.SHOW_PROJECT_PANEL, onShowProjectPanel);
			dispatcher.removeEventListener(ProjectPanelPluginEvent.HIDE_PROJECT_PANEL, onHideProjectPanel);
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
                
                LayoutModifier.addToProjectPanel(event.view);
            }
        }

        private function removeViewToProjectPanelHandler(event:ProjectPanelPluginEvent):void
        {
            if (event.view && views.some(function hasView(item:String, index:int, arr:Array):Boolean
                {
                    return item == event.view.title;
                }))
            {
                var tabsCount:int = view.numElements;
                for (var i:int = 0; i < tabsCount; i++)
                {
                    var tab:NavigatorContent = view.getItemAt(i) as NavigatorContent;
                    if (tab.label == event.view.title)
                    {
                        view.removeElement(tab);
                        views.removeAt(i);
                        break;
                    }
                }
                
                LayoutModifier.removeFromProjectPanel(event.view);
            }
        }

        private function selectViewInProjectPanelHandler(event:ProjectPanelPluginEvent):void
        {
            if (event.view && views.some(function hasView(item:String, index:int, arr:Array):Boolean
                {
                    return item == event.view.title;
                }))
            {
                var tabsCount:int = view.numElements;
                for (var i:int = 0; i < tabsCount; i++)
                {
                    var tab:NavigatorContent = view.getItemAt(i) as NavigatorContent;
                    if (tab.label == event.view.title)
                    {
                        view.selectedIndex = i;
                    }
                }
            }
        }

        private function onViewTabClose(event:TabNavigatorEvent):void
        {
            var navContent:NavigatorContent = NavigatorContent(view.getElementAt(event.tabIndex));
            var tab:IViewWithTitle = IViewWithTitle(navContent.getElementAt(0));
            dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.REMOVE_VIEW_TO_PROJECT_PANEL, tab));
        }

        private function onViewCreationComplete(event:FlexEvent):void
        {
            view.removeEventListener(FlexEvent.CREATION_COMPLETE, onViewCreationComplete);
            setProjectPanelVisibility(LayoutModifier.isProjectPanelCollapsed);
        }

        private function onProjectPanelDividerRelease(event:DividerEvent):void
        {
            // consider an expand/collapse click
            if (isOverTheExpandCollapseButton)
            {
                setProjectPanelVisibility(!isProjectPanelHidden);
                return;
            }

            var tmpHeight:int = view.parent.height - view.parent.mouseY - view.minHeight;
            if (tmpHeight <= 4)
            {
                setProjectPanelVisibility(true);
            }
            else
            {
                setProjectPanelVisibility(false);
                LayoutModifier.projectPanelHeight = tmpHeight;
            }
        }
		
		private function onShowProjectPanel(event:ProjectPanelPluginEvent):void
		{
			isOverTheExpandCollapseButton = true;
			isProjectPanelHidden = true;
			onProjectPanelDividerRelease(null);
		}
		
		private function onHideProjectPanel(event:ProjectPanelPluginEvent):void
		{
			isOverTheExpandCollapseButton = true;
			isProjectPanelHidden = false;
			onProjectPanelDividerRelease(null);
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
            model.mainView.bodyPanel.setStyle('dividerSkin', isProjectPanelHidden ? customDividerSkinExpand : customDividerSkinCollapse);
			
			if (!isProjectPanelHidden && LayoutModifier.projectPanelHeight != -1)
			{
				this.setProjectPanelHeight(LayoutModifier.projectPanelHeight);
			}
			else
			{
				this.setProjectPanelHeight(-1);
			}
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
