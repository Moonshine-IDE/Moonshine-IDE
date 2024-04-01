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

package moonshine.plugin.workflows.views;

import openfl.events.Event;
import moonshine.ui.SideBarViewHeader;
import moonshine.plugin.workflows.vo.WorkflowVO;
import feathers.layout.AnchorLayoutData;
import feathers.layout.AnchorLayout;
import feathers.controls.TreeView;
import actionScripts.interfaces.IViewWithTitle;
import feathers.controls.Panel;

class WorkflowView extends Panel implements IViewWithTitle 
{
    @:flash.property
	public var title(get, never):String;
	public function get_title():String 
    {
		return "Workflow";
	}

    private var tree:TreeView;

    public function new()
    {
        super();
    }    

    override private function initialize():Void 
    {
        this.layout = new AnchorLayout();

        this.tree = new TreeView();
        this.tree.variant = TreeView.VARIANT_BORDERLESS;
        this.tree.layoutData = AnchorLayoutData.fill();
        this.tree.itemToText = (item:WorkflowVO) -> item.title;
        this.addChild(this.tree);

        var header = new SideBarViewHeader();
		header.title = this.title;
		header.closeEnabled = true;
		header.addEventListener(Event.CLOSE, this.onCloseRequest, false, 0, true);
		this.header = header;

        super.initialize();
    }

    private function onCloseRequest(event:Event):Void 
    {
		this.dispatchEvent(new Event(Event.CLOSE));
	}
}