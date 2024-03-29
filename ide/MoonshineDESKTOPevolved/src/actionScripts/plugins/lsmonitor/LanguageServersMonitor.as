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
package actionScripts.plugins.lsmonitor
{
	import actionScripts.plugin.projectPanel.events.ProjectPanelPluginEvent;
	import actionScripts.plugins.build.ConsoleBuildPluginBase;
	import actionScripts.valueObjects.ConstantsCoreVO;

	import feathers.data.ArrayCollection;

	import flash.events.Event;
	import flash.events.ProgressEvent;

	import flash.filesystem.File;

	import moonshine.plugin.lsmonitor.view.LanguageServersMonitorView;
	import moonshine.plugin.lsmonitor.vo.LanguageServerInstanceVO;

	import actionScripts.languageServer.LanguageServerGlobals;
	import actionScripts.languageServer.ILanguageServerManager;

	public class LanguageServersMonitor extends ConsoleBuildPluginBase
	{
		public static const EVENT_SHOW_LS_MONITOR_VIEW:String = "showLanguageServersMonitorView";

		override public function get name():String			{ return "Language Servers Monitor"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team"; }
		override public function get description():String	{ return "Monitoring Language Server Instances Ran by Moonshine-IDE"; }

		private var lsMonitorViewWrapper:LanguageServersMonitorViewWrapper;
		private var lsMonitorView:LanguageServersMonitorView;
		private var isMonitorViewVisible:Boolean;

		public function LanguageServersMonitor()
		{
			super();

			lsMonitorView = new LanguageServersMonitorView();
			lsMonitorViewWrapper = new LanguageServersMonitorViewWrapper(lsMonitorView);
			lsMonitorViewWrapper.percentWidth = 100;
			lsMonitorViewWrapper.percentHeight = 100;
			lsMonitorViewWrapper.minWidth = 0;
			lsMonitorViewWrapper.minHeight = 0;
		}

		override public function deactivate():void
		{
			super.deactivate();
			dispatcher.removeEventListener(EVENT_SHOW_LS_MONITOR_VIEW, onShowLSMonitorView);
		}

		override public function activate():void
		{
			super.activate();
			//nativeProcessStartupInfo.executable = File.documentsDirectory.resolvePath( "/bin/bash" );

			dispatcher.addEventListener(EVENT_SHOW_LS_MONITOR_VIEW, onShowLSMonitorView, false, 0, true);
		}

		/*
		override protected function onNativeProcessStandardOutputData(event:ProgressEvent):void
		{
			var outputLines:Array = getDataFromBytes(nativeProcess.standardOutput).split("\n");
			var lineValue:String;
			var instances:ArrayCollection = new ArrayCollection();
			for (var line:int=0; line < outputLines.length; line++)
			{
				lineValue = outputLines[line];
				if ((lineValue == "") || (lineValue.indexOf("%MEM") != -1))
				{
					continue;
				}

				var items:Array = lineValue.split(/\s+/g);
				var lsInstance:LanguageServerInstanceVO = new LanguageServerInstanceVO();
				lsInstance.projectName = (items[0] as String).replace(":", "");
				lsInstance.processID = items[1];
				lsInstance.memory = items[2];
				lsInstance.cpu = items[3];
				instances.add(lsInstance);
			}

			lsMonitorView.languageServerInstances = instances;
		}
		*/

		private function onShowLSMonitorView(event:Event):void
		{
			if (!isMonitorViewVisible)
			{
				dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.ADD_VIEW_TO_PROJECT_PANEL, lsMonitorViewWrapper));
				initializeMonitorViewEventHandlers();
				isMonitorViewVisible = true;
				LanguageServerGlobals.getInstance().addEventListener( Event.ADDED, langaugeServerAdded );
				LanguageServerGlobals.getInstance().addEventListener( Event.REMOVED, langaugeServerRemoved );
				getServerInstances();
			}
			else
			{
				LanguageServerGlobals.getInstance().removeEventListener( Event.ADDED, langaugeServerAdded );
				LanguageServerGlobals.getInstance().removeEventListener( Event.REMOVED, langaugeServerRemoved );
				dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.REMOVE_VIEW_TO_PROJECT_PANEL, lsMonitorViewWrapper));
				cleanupMonitorViewEventHandlers();
				monitorPanel_removedFromStageHandler(event);
			}
		}

		private function langaugeServerAdded(e:Event):void {
			getServerInstances();
		}

		private function langaugeServerRemoved(e:Event):void {
			getServerInstances();
		}

		private function initializeMonitorViewEventHandlers():void
		{
			//lsMonitorView.addEventListener(ProblemsViewEvent.OPEN_PROBLEM, problemsPanel_openProblemHandler);
			lsMonitorView.addEventListener(Event.REMOVED_FROM_STAGE, monitorPanel_removedFromStageHandler);
		}

		private function cleanupMonitorViewEventHandlers():void
		{
			//lsMonitorView.removeEventListener(ProblemsViewEvent.OPEN_PROBLEM, problemsPanel_openProblemHandler);
			lsMonitorView.removeEventListener(Event.REMOVED_FROM_STAGE, monitorPanel_removedFromStageHandler);
		}

		private function monitorPanel_removedFromStageHandler(event:Event):void
		{
			isMonitorViewVisible = false;
		}

		private function getServerInstances():void
		{

			var globalInstances:Array = LanguageServerGlobals.getInstance().getLanguageServerInstances();
			var instances:ArrayCollection = new ArrayCollection();

			instances.sortCompareFunction = languageServerSort;

			for (var i:int=0; i < globalInstances.length; i++)
			{
				var instance:ILanguageServerManager = globalInstances[ i ];
				var lsInstance:LanguageServerInstanceVO = new LanguageServerInstanceVO();
				lsInstance.projectName = instance.project.name;
				lsInstance.processID = String( instance.pid );
				if ( instance.pid > -1 ) instances.add(lsInstance);

			}

			lsMonitorView.languageServerInstances = instances;

			/*
			// for MacOS platform
			var shFile : File = File.applicationDirectory.resolvePath("macOScripts/LanguageServerStats.sh");

			// making proper case-sensitive to work in case-sensitive system like Linux
			var pattern : RegExp = new RegExp( /( )/g );
			var shPath : String = shFile.nativePath;
			shPath = shPath.replace( pattern, "\\ " );

			//print("%s", command);
			this.start(
					new <String>[shPath], null
			);
			*/
		}

		private function languageServerSort( item1:LanguageServerInstanceVO, item2:LanguageServerInstanceVO ):int {

			if ( item1.projectName > item2.projectName ) {
				return 1;
			} else if ( item1.projectName < item2.projectName ) {
				return -1;
			}
			return 0;

		}

	}
}

import actionScripts.interfaces.IViewWithTitle;
import actionScripts.ui.FeathersUIWrapper;

import moonshine.plugin.lsmonitor.view.LanguageServersMonitorView;

class LanguageServersMonitorViewWrapper extends FeathersUIWrapper implements IViewWithTitle
{
	public function LanguageServersMonitorViewWrapper(feathersUIControl:LanguageServersMonitorView)
	{
		super(feathersUIControl);
	}

	public function get title():String
	{
		return LanguageServersMonitorView(feathersUIControl).title;
	}

	override public function get className():String
	{
		//className may be used by LayoutModifier
		return "LanguageServersMonitorView";
	}

	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
	}
}
