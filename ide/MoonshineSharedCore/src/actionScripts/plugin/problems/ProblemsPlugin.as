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
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.projectPanel.events.ProjectPanelPluginEvent;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.Diagnostic;
	
	import moonshine.plugin.problems.view.ProblemsView;
	import feathers.data.IFlatCollection;

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

		override public function activate():void
		{
			super.activate();
			dispatcher.addEventListener(EVENT_PROBLEMS, handleProblemsShow);
			dispatcher.addEventListener(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, handleShowDiagnostics);
		}

		override public function deactivate():void
		{
			super.deactivate();
			dispatcher.removeEventListener(EVENT_PROBLEMS, handleProblemsShow);
			dispatcher.removeEventListener(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, handleShowDiagnostics);
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
			problemsView.addEventListener(Event.CHANGE, handleProblemChange);
			problemsView.addEventListener(Event.REMOVED_FROM_STAGE, problemsPanel_removedFromStage);
		}

		private function cleanupProblemsViewEventHandlers():void
		{
			problemsView.removeEventListener(Event.CHANGE, handleProblemChange);
			problemsView.removeEventListener(Event.REMOVED_FROM_STAGE, problemsPanel_removedFromStage);
		}

		private function problemsPanel_removedFromStage(event:Event):void
		{
            isProblemsViewVisible = false;
		}

		private function handleShowDiagnostics(event:DiagnosticsEvent):void
		{
			var path:String = event.path;
			var problems:IFlatCollection = problemsView.problems;
			var itemCount:int = problems.length;
			for(var i:int = itemCount - 1; i >= 0; i--)
			{
				var item:Diagnostic = Diagnostic(problems.get(i));
				if(item.path === path)
				{
					problems.removeAt(i);
				}
			}
			var diagnostics:Vector.<Diagnostic> = event.diagnostics;
			itemCount = diagnostics.length;
			for(i = 0; i < itemCount; i++)
			{
				item = diagnostics[i];
				if(item.severity == Diagnostic.SEVERITY_HINT)
				{
					//hints aren't meant to be displayed in the list of problems
					continue;
				}
				problems.add(item);
			}
		}

		private function handleProblemChange(event:Event):void
		{
			var diagnostic:Diagnostic = problemsView.selectedProblem;
			var openEvent:OpenFileEvent = new OpenFileEvent(OpenFileEvent.OPEN_FILE,
				[new FileLocation(diagnostic.path)], diagnostic.range.start.line);
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