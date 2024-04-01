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
package actionScripts.plugin.workflows
{
	import actionScripts.ui.actionbar.vo.ActionItemTypes;

	import flash.events.Event;
	import actionScripts.plugin.PluginBase;
	import actionScripts.ui.LayoutModifier;
	import actionScripts.valueObjects.ConstantsCoreVO;

	import feathers.data.ArrayHierarchicalCollection;

	import moonshine.editor.text.events.TextEditorChangeEvent;

	import moonshine.plugin.workflows.events.WorkflowEvent;
	import moonshine.plugin.workflows.views.WorkflowView;

	public class WorkflowsPlugin extends PluginBase
	{
		override public function get name():String { return "Workflows Plugin"; }
		override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String { return "Displays available workflows against project/types."; }

		private var workflowViewWrapper:WorkflowViewWrapper;
		private var workflowView:WorkflowView;

		public function WorkflowsPlugin()
		{
			super();
			
			workflowView = new WorkflowView();
			workflowView.addEventListener(Event.CLOSE, workflowView_closeHandler, false, 0, true);
			workflowViewWrapper = new WorkflowViewWrapper(workflowView);
			workflowViewWrapper.percentWidth = 100;
			workflowViewWrapper.percentHeight = 100;
		}

		override public function activate():void
		{
			super.activate();
			dispatcher.addEventListener(ActionItemTypes.WORKFLOW, handleWorkflowShow);
			dispatcher.addEventListener(WorkflowEvent.LOAD_WORKFLOW, handleWorkflowAddEvent);
		}

		override public function deactivate():void
		{
			super.deactivate();
			dispatcher.removeEventListener(ActionItemTypes.WORKFLOW, handleWorkflowShow);
			dispatcher.removeEventListener(WorkflowEvent.LOAD_WORKFLOW, handleWorkflowAddEvent);
		}

		private function handleWorkflowShow(event:Event):void
		{
			var collection:ArrayHierarchicalCollection = workflowView.outline;
			collection.removeAll();
			
			if (!workflowViewWrapper.parent)
            {
				LayoutModifier.addToSidebar(workflowViewWrapper, event);

				this.refreshSymbols();
            }
			else
			{
				//don't bother refreshing because the outline view is being
				//hidden
				changeTimer.reset();

				LayoutModifier.removeFromSidebar(workflowViewWrapper);
			}
			isStartupCall = false;
		}

		private function workflowView_closeHandler(event:Event):void
		{
			LayoutModifier.removeFromSidebar(this.workflowViewWrapper);
		}

		private function handleDidChange(event:TextEditorChangeEvent):void
		{
			//the file has been edited. to avoid updating the outline too often,
			//reset the timer and start over from the beginning.
			changeTimer.reset();
			
			if(!this.workflowViewWrapper.parent)
			{
				//we can ignore this event when the outline isn't visible
				return;
			}
			changeTimer.start();
		}

		private function handleWorkflowAddEvent(event:WorkflowEvent):void
		{

		}
	}
}

import actionScripts.interfaces.IViewWithTitle;
import actionScripts.ui.FeathersUIWrapper;
import actionScripts.ui.IPanelWindow;
import moonshine.plugin.workflows.views.WorkflowView;

//IPanelWindow used by LayoutModifier.addToSidebar() and removeFromSidebar()
class WorkflowViewWrapper extends FeathersUIWrapper implements IPanelWindow, IViewWithTitle
{
	public function WorkflowViewWrapper(workflowView:WorkflowView)
	{
		super(workflowView);
	}

	public function get title():String
	{
		return WorkflowView(feathersUIControl).title;
	}

	override public function get className():String
	{
		//className used by LayoutModifier.attachSidebarSections
		return "WorkflowView";
	}
}