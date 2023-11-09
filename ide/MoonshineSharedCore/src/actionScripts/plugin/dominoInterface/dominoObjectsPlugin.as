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
package actionScripts.plugin.dominoInterface
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
	import actionScripts.plugin.console.view.DominoObjectsView;
	public class DominoObjectsPlugin extends PluginBase
	{
		public static const EVENT_DOMINO_OBJECTS:String = "EVENT_DOMINO_OBJECTS";

		public function dominoObjectsPlugin()
		{
			dominoObjectView = new DominoObjectsView();
			dominoObjectView.percentWidth = 100;
			dominoObjectView.percentHeight = 100;
			dominoObjectView.minWidth = 0;
			dominoObjectView.minHeight = 0;
		}

		override public function get name():String { return "Problems Plugin"; }
		override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String { return "Displays problems in source files."; }

		private var dominoObjectView:DominoObjectsView = new DominoObjectsView();
		private var isStartupCall:Boolean = true;
		private var isDominoObjectsViewVisible:Boolean = false;
		private var diagnosticsByProject:Dictionary = new Dictionary();
		
		
		


		override public function activate():void
		{
			super.activate();
			dispatcher.addEventListener(EVENT_DOMINO_OBJECTS, handleDominoObjectsShow);
			dispatcher.addEventListener(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, handleShowDiagnostics);
			dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, handleRemoveProject);
		}

		override public function deactivate():void
		{
			super.deactivate();
			dispatcher.removeEventListener(EVENT_DOMINO_OBJECTS, handleDominoObjectsShow);
			dispatcher.removeEventListener(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, handleShowDiagnostics);
			dispatcher.removeEventListener(ProjectEvent.REMOVE_PROJECT, handleRemoveProject);
		}

		private function handleDominoObjectsShow(event:Event):void
		{
			if (!isDominoObjectsViewVisible)
            {
                dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.ADD_VIEW_TO_PROJECT_PANEL, dominoObjectView));
                initializeProblemsViewEventHandlers(event);
				isDominoObjectsViewVisible = true;
            }
			else
			{
				dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.REMOVE_VIEW_TO_PROJECT_PANEL, dominoObjectView));
                cleanupProblemsViewEventHandlers();
				isDominoObjectsViewVisible = false;
			}
			isStartupCall = false;
		}
		
		private function initializeProblemsViewEventHandlers(event:Event):void
		{
			dominoObjectView.addEventListener(ProblemsViewEvent.OPEN_PROBLEM, problemsPanel_openProblemHandler);
			dominoObjectView.addEventListener(Event.REMOVED_FROM_STAGE, problemsPanel_removedFromStageHandler);
		}

		private function cleanupProblemsViewEventHandlers():void
		{
			dominoObjectView.removeEventListener(ProblemsViewEvent.OPEN_PROBLEM, problemsPanel_openProblemHandler);
			dominoObjectView.removeEventListener(Event.REMOVED_FROM_STAGE, problemsPanel_removedFromStageHandler);
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
		
		}

		private function problemsPanel_removedFromStageHandler(event:Event):void
		{
            isDominoObjectsViewVisible = false;
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