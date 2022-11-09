////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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
package actionScripts.plugin.problems
{
	import flash.events.Event;
	import flash.utils.Dictionary;

	import actionScripts.events.DiagnosticsEvent;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.projectPanel.events.ProjectPanelPluginEvent;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;

	import moonshine.lsp.Diagnostic;
	import moonshine.plugin.problems.data.DiagnosticHierarchicalCollection;
	import moonshine.plugin.problems.events.ProblemsViewEvent;
	import moonshine.plugin.problems.view.ProblemsView;
	import moonshine.plugin.problems.vo.MoonshineDiagnostic;

	public class ProblemsPlugin extends PluginBase
	{
		public static const EVENT_PROBLEMS:String = "EVENT_PROBLEMS";

		public function ProblemsPlugin()
		{
			problemsView = new ProblemsView();
			problemsViewWrapper = new ProblemsViewWrapper(problemsView);
			problemsViewWrapper.percentWidth = 100;
			problemsViewWrapper.percentHeight = 100;
			problemsViewWrapper.minWidth = 0;
			problemsViewWrapper.minHeight = 0;
		}

		override public function get name():String { return "Problems Plugin"; }
		override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String { return "Displays problems in source files."; }

		private var problemsViewWrapper:ProblemsViewWrapper;
		private var problemsView:ProblemsView = new ProblemsView();
		private var isStartupCall:Boolean = true;
		private var isProblemsViewVisible:Boolean = false;
		private var diagnosticsByProject:Dictionary = new Dictionary();

		override public function activate():void
		{
			super.activate();
			dispatcher.addEventListener(EVENT_PROBLEMS, handleProblemsShow);
			dispatcher.addEventListener(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, handleShowDiagnostics);
			dispatcher.addEventListener(ProjectEvent.LANGUAGE_SERVER_CLOSED, handleLanguageServerClosed);
			dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, handleRemoveProject);
		}

		override public function deactivate():void
		{
			super.deactivate();
			dispatcher.removeEventListener(EVENT_PROBLEMS, handleProblemsShow);
			dispatcher.removeEventListener(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, handleShowDiagnostics);
			dispatcher.removeEventListener(ProjectEvent.LANGUAGE_SERVER_CLOSED, handleLanguageServerClosed);
			dispatcher.removeEventListener(ProjectEvent.REMOVE_PROJECT, handleRemoveProject);
		}

		private function handleProblemsShow(event:Event):void
		{
			if (!isProblemsViewVisible)
            {
                dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.ADD_VIEW_TO_PROJECT_PANEL, problemsViewWrapper));
                initializeProblemsViewEventHandlers(event);
				isProblemsViewVisible = true;
            }
			else
			{
				dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.REMOVE_VIEW_TO_PROJECT_PANEL, problemsViewWrapper));
                cleanupProblemsViewEventHandlers();
				isProblemsViewVisible = false;
			}
			isStartupCall = false;
		}
		
		private function initializeProblemsViewEventHandlers(event:Event):void
		{
			problemsView.addEventListener(ProblemsViewEvent.OPEN_PROBLEM, problemsPanel_openProblemHandler);
			problemsView.addEventListener(Event.REMOVED_FROM_STAGE, problemsPanel_removedFromStageHandler);
		}

		private function cleanupProblemsViewEventHandlers():void
		{
			problemsView.removeEventListener(ProblemsViewEvent.OPEN_PROBLEM, problemsPanel_openProblemHandler);
			problemsView.removeEventListener(Event.REMOVED_FROM_STAGE, problemsPanel_removedFromStageHandler);
		}

		private function clearProblemsForProject(project:ProjectVO):void
		{
			if(!project)
			{
				return;
			}
			var diagnosticsByUri:Object = diagnosticsByProject[project];
			delete diagnosticsByProject[project];
			if(!diagnosticsByUri)
			{
				return;
			}
			var problems:DiagnosticHierarchicalCollection = problemsView.problems;
			for(var uri:String in diagnosticsByUri)
			{
				problems.clearDiagnostics(uri, project);
			}
		}

		private function problemsPanel_removedFromStageHandler(event:Event):void
		{
            isProblemsViewVisible = false;
		}

		private function handleLanguageServerClosed(event:ProjectEvent):void
		{
			this.clearProblemsForProject(event.project);
		}

		private function handleRemoveProject(event:ProjectEvent):void
		{
			this.clearProblemsForProject(event.project);
		}

		private function handleShowDiagnostics(event:DiagnosticsEvent):void
		{
			var problems:DiagnosticHierarchicalCollection = problemsView.problems;
			var project:ProjectVO = event.project;
			var diagnosticsByUri:Object = diagnosticsByProject[project];
			if(!diagnosticsByUri)
			{
				diagnosticsByUri = {};
				diagnosticsByProject[project] = diagnosticsByUri;
			}
			var uri:String = event.uri;
			var diagnostics:Array = event.diagnostics;
			diagnostics = diagnostics.map(function(diagnostic:Diagnostic, index:int, source:Array):MoonshineDiagnostic
			{
				var result:MoonshineDiagnostic = new MoonshineDiagnostic(new FileLocation(uri, true), project);
				result.code = diagnostic.code;
				result.message = diagnostic.message;
				result.range = diagnostic.range;
				result.severity = diagnostic.severity;
				return result;
			});
			diagnosticsByUri[uri] = diagnostics;
			problems.setDiagnostics(uri, project, diagnostics);
		}

		private function problemsPanel_openProblemHandler(event:ProblemsViewEvent):void
		{
			var diagnostic:MoonshineDiagnostic = event.problem;
			var openEvent:OpenFileEvent = new OpenFileEvent(OpenFileEvent.OPEN_FILE,
				[diagnostic.fileLocation], diagnostic.range.start.line);
			openEvent.atChar = diagnostic.range.start.character;
			dispatcher.dispatchEvent(openEvent);
		}

	}
}


import actionScripts.interfaces.IViewWithTitle;
import actionScripts.ui.FeathersUIWrapper;

import moonshine.plugin.problems.view.ProblemsView;

class ProblemsViewWrapper extends FeathersUIWrapper implements IViewWithTitle {
	public function ProblemsViewWrapper(feathersUIControl:ProblemsView)
	{
		super(feathersUIControl);
	}

	public function get title():String {
		return ProblemsView(feathersUIControl).title;
	}

	override public function get className():String
	{
		//className may be used by LayoutModifier
		return "ProblemsView";
	}

	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
	}
}