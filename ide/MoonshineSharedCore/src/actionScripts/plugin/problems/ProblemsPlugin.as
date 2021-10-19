////////////////////////////////////////////////////////////////////////////////
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
// 
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugin.problems
{
	import flash.events.Event;

	import actionScripts.events.DiagnosticsEvent;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.projectPanel.events.ProjectPanelPluginEvent;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;

	import feathers.data.IFlatCollection;

	import moonshine.lsp.Diagnostic;
	import moonshine.plugin.problems.view.ProblemsView;
	import moonshine.plugin.problems.vo.MoonshineDiagnostic;
	import flash.utils.Dictionary;
	import moonshine.plugin.problems.events.ProblemsViewEvent;

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
			var problems:IFlatCollection = problemsView.problems;
			for(var uri:String in diagnosticsByUri)
			{
				var oldDiagnostics:Array = diagnosticsByUri[uri];
				for each(var oldDiagnostic:MoonshineDiagnostic in oldDiagnostics)
				{
					problems.remove(oldDiagnostic);
				}
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
			var problems:IFlatCollection = problemsView.problems;
			var project:ProjectVO = event.project;
			var diagnosticsByUri:Object = diagnosticsByProject[project];
			if(!diagnosticsByUri)
			{
				diagnosticsByUri = {};
				diagnosticsByProject[project] = diagnosticsByUri;
			}
			var uri:String = event.uri;
			if(uri in diagnosticsByUri)
			{
				var oldDiagnostics:Array = diagnosticsByUri[uri];
				for each(var oldDiagnostic:MoonshineDiagnostic in oldDiagnostics)
				{
					problems.remove(oldDiagnostic);
				}
				delete diagnosticsByUri[uri];
			}
			var newDiagnostics:Array = event.diagnostics;
			newDiagnostics = newDiagnostics.map(function(diagnostic:Diagnostic, index:int, source:Array):MoonshineDiagnostic
			{
				var result:MoonshineDiagnostic = new MoonshineDiagnostic(new FileLocation(uri, true), project);
				result.code = diagnostic.code;
				result.message = diagnostic.message;
				result.range = diagnostic.range;
				result.severity = diagnostic.severity;
				return result;
			});
			diagnosticsByUri[uri] = newDiagnostics;
			for each(var newDiagnostic:MoonshineDiagnostic in newDiagnostics)
			{
				if(newDiagnostic.severity == 4 /* DiagnosticSeverity.Hint */)
				{
					//hints aren't meant to be displayed in the list of problems
					continue;
				}
				problems.add(newDiagnostic);
			}
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