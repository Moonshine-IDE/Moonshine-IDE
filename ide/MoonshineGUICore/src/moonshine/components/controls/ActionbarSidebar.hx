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

package moonshine.components.controls;

import openfl.events.Event;
import feathers.events.TriggerEvent;
import flash.Vector;
import actionScripts.locator.IDEModel;
import actionScripts.valueObjects.ProjectVO;
import actionScripts.events.ProjectEvent;
import actionScripts.events.GlobalEventDispatcher;
import moonshine.theme.MoonshineTheme;
import feathers.controls.Button;
import feathers.layout.HorizontalLayoutData;
import moonshine.theme.MoonshineTypography;
import actionScripts.ui.actionbar.vo.ActionItemVO;
import actionScripts.ui.actionbar.vo.ActionItemTypes;
import feathers.text.TextFormat;
import feathers.controls.Label;
import feathers.layout.VerticalLayoutData;
import feathers.layout.HorizontalLayout;
import feathers.skins.RectangleSkin;
import feathers.layout.VerticalLayout;
import feathers.controls.LayoutGroup;
import feathers.controls.AssetLoader;

class ActionbarSidebar extends LayoutGroup 
{
    private var lblTitle:Label;
    private var buttonsContainer:LayoutGroup;
    private var activeProject:ProjectVO;
    private var btnWorkflows:Button;
    private var projectActionItems:Vector<ActionItemVO>;
    private var buttonsMap:Map<Button, String> = new Map();
    private var dispatcher = GlobalEventDispatcher.getInstance();
    private var model = IDEModel.getInstance();

    public function new()
    {
        super();
    }    

    override private function initialize():Void 
    {
        this.layout = new VerticalLayout();
        this.backgroundSkin = new RectangleSkin(SolidColor(0x363636));
        cast(this.layout, VerticalLayout).gap = 0;

        var mainHolderLayout = new HorizontalLayout();
        mainHolderLayout.verticalAlign = MIDDLE;
        mainHolderLayout.setPadding(2);
        mainHolderLayout.paddingLeft = 10;
        mainHolderLayout.gap = 6;

        var mainHolder = new LayoutGroup();
        mainHolder.layout = mainHolderLayout;
        mainHolder.layoutData = new VerticalLayoutData(100);
        mainHolder.height = 32;
        this.addChild(mainHolder);

        this.lblTitle = new Label("Hello World!");
        this.lblTitle.textFormat = new TextFormat(MoonshineTypography.DEFAULT_FONT_NAME, 10, 0xffffcc, true);
        this.lblTitle.layoutData = new HorizontalLayoutData(100);
        mainHolder.addChild(this.lblTitle);

        this.buttonsContainer = new LayoutGroup();
        this.buttonsContainer.layout = new HorizontalLayout();
        cast(this.buttonsContainer.layout, HorizontalLayout).gap = 6;
        mainHolder.addChild(this.buttonsContainer);

        var icoWorkflow = new AssetLoader("/elements/images/icoWorkflow.png");
        icoWorkflow.maxWidth = icoWorkflow.maxHeight = 10;

        btnWorkflows = new Button();
        btnWorkflows.variant = MoonshineTheme.THEME_VARIANT_ACTIONBAR_BUTTON;
        btnWorkflows.icon = icoWorkflow;
        btnWorkflows.width = btnWorkflows.height = 22;
        btnWorkflows.toolTip = "Workflows";
        btnWorkflows.visible = false;
        btnWorkflows.addEventListener(TriggerEvent.TRIGGER, this.onActionItemClick, false, 0, true);
        this.buttonsMap.set(btnWorkflows, ActionItemTypes.WORKFLOW);
        mainHolder.addChild(btnWorkflows);

        var divider = new LayoutGroup();
        divider.height = 1;
        divider.backgroundSkin = new RectangleSkin(SolidColor(0x000));
        divider.layoutData = new VerticalLayoutData(100);
        this.addChild(divider);

        this.dispatcher.addEventListener(ProjectEvent.ACTIVE_PROJECT_CHANGED, onProjectSelectionChangedInSidebar, false, 0, true);
        this.dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, onProjectRemoved, false, 0, true);

        super.initialize();
    }

    private function onProjectSelectionChangedInSidebar(event:ProjectEvent):Void
    {
        if (event.project == null) return;
        if (this.activeProject == event.project) return;

        projectActionItems = model.projectCore.getActionItems(event.project);
        if (projectActionItems == null) return;

        this.removeActionButtons();
        
        this.activeProject = event.project;
        this.btnWorkflows.visible = true;
        this.lblTitle.text = this.activeProject.name;

        for (action in projectActionItems)
        {
            var tmpButton:Button = null;
            switch (action.type)
            {
                case ActionItemTypes.BUILD:
                    tmpButton = getNewActionButton(action, "/elements/images/icoBuild.png");
                case ActionItemTypes.RUN:
                    tmpButton = getNewActionButton(action, "/elements/images/debug-play-icon.png");
                case ActionItemTypes.DEBUG:
                    tmpButton = getNewActionButton(action, "/elements/images/icoDebug.png");
                case ActionItemTypes.EXPORT:
                    tmpButton = getNewActionButton(action, "/elements/images/icoExport.png");
            }

            if (tmpButton != null) 
                this.buttonsContainer.addChild(tmpButton);
        }

        // make workflow option visible irrespective
        // of project types
        //this.btnWorkdflow.includeInLayout = this.btnWorkdflow.visible = true;
    }

    private function onProjectRemoved(event:ProjectEvent):Void
    {
        if (event.project == this.activeProject) 
            this.removeActionButtons();   
    }

    private function removeActionButtons():Void
    {
        this.lblTitle.text = "";
        this.btnWorkflows.visible = false;
        // remove listeners
        while (this.buttonsContainer.numChildren != 0) 
        {
            var tmpButton:Button = cast this.buttonsContainer.getChildAt(0);
            tmpButton.removeEventListener(TriggerEvent.TRIGGER, this.onActionItemClick);
            this.buttonsContainer.removeChild(tmpButton);
            this.buttonsMap.remove(tmpButton);
        };
    }

    private function getNewActionButton(action:ActionItemVO, iconPath:String):Button
    {
        var icon = new AssetLoader(iconPath);
        icon.maxHeight = icon.maxWidth = 10;

        var tmpButton:Button = new Button();
        tmpButton.width = tmpButton.height = 22;
        tmpButton.variant = MoonshineTheme.THEME_VARIANT_ACTIONBAR_BUTTON;
        tmpButton.icon = icon;
        tmpButton.toolTip = action.title;
        tmpButton.addEventListener(TriggerEvent.TRIGGER, this.onActionItemClick, false, 0, true);
        this.buttonsMap.set(tmpButton, action.type);

        return tmpButton;
    }

    private function onActionItemClick(event:TriggerEvent):Void
    {
        if (projectActionItems == null) return;

        var tmpButton:Button = cast event.target;
        var type = this.buttonsMap.get(tmpButton);
        // for workflows button
        if (type == ActionItemTypes.WORKFLOW)
        {
            dispatcher.dispatchEvent(new Event(ActionItemTypes.WORKFLOW));
            return;
        }

        for (action in projectActionItems)
        {
            if (action.type == type)
            {
                dispatcher.dispatchEvent(new Event(action.event));
                break;
            }
        }
    }
}