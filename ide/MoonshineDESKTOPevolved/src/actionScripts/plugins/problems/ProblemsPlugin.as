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
package actionScripts.plugins.problems
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.controls.AdvancedDataGrid;
	import mx.events.ListEvent;
	
	import actionScripts.events.DiagnosticsEvent;
	import actionScripts.events.GeneralEvent;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugins.problems.view.ProblemsView;
	import actionScripts.ui.IPanelWindow;
	import actionScripts.ui.LayoutModifier;
	import actionScripts.valueObjects.Diagnostic;

	public class ProblemsPlugin extends PluginBase
	{
		public static const EVENT_PROBLEMS:String = "EVENT_PROBLEMS";

		public function ProblemsPlugin()
		{
		}

		override public function get name():String { return "Problems Plugin"; }
		override public function get author():String { return "Moonshine Project Team"; }
		override public function get description():String { return "Displays problems in source files."; }

		private var problemsPanel:ProblemsView = new ProblemsView();
		private var isStartupCall:Boolean = true;

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
			/*if (!LayoutModifier.isProblemsWindow && isStartupCall)
			{
				LayoutModifier.setButNotSaveValue(LayoutModifier.PROBLEMS_VIEW_FIELD, true);
				isStartupCall = false;
				return;
			}*/
			
			IDEModel.getInstance().mainView.addPanel(problemsPanel);
			if (event is GeneralEvent && GeneralEvent(event).value != -1) problemsPanel.height = int(GeneralEvent(event).value);
			
			problemsPanel.validateNow();
			problemsPanel.problemsTree.addEventListener(ListEvent.ITEM_CLICK, handleProblemClick);
			LayoutModifier.isProblemsWindow = true;
			isStartupCall = false;
		}

		private function handleShowDiagnostics(event:DiagnosticsEvent):void
		{
			var path:String = event.path;
			var objectTree:ArrayCollection = problemsPanel.objectTree;
			var itemCount:int = objectTree.length;
			for(var i:int = itemCount - 1; i >= 0; i--)
			{
				var item:Diagnostic = Diagnostic(objectTree.getItemAt(i));
				if(item.path === path)
				{
					objectTree.removeItemAt(i);
				}
			}
			var diagnostics:Vector.<Diagnostic> = event.diagnostics;
			itemCount = diagnostics.length;
			for(i = 0; i < itemCount; i++)
			{
				var diagnostic:Diagnostic = diagnostics[i];
				objectTree.addItem(diagnostic);
			}
		}

		private function handleProblemClick(event:ListEvent):void
		{
			var diagnostic:Diagnostic = Diagnostic(event.itemRenderer.data);
			var openEvent:OpenFileEvent = new OpenFileEvent(OpenFileEvent.OPEN_FILE,
				new FileLocation(diagnostic.path), diagnostic.range.start.line);
			openEvent.atChar = diagnostic.range.start.character;
			dispatcher.dispatchEvent(openEvent);
		}

	}
}
