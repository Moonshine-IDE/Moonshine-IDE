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
package actionScripts.plugins.references
{
	import actionScripts.events.ReferencesEvent;
	import actionScripts.events.TypeAheadEvent;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugins.references.view.ReferencesView;
	import actionScripts.ui.editor.ActionScriptTextEditor;
	import actionScripts.valueObjects.Location;

	import flash.display.DisplayObject;

	import flash.events.Event;

	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;

	public class ReferencesPlugin extends PluginBase
	{
		public static const EVENT_OPEN_FIND_REFERENCES_VIEW:String = "openFindReferencesView";
		
		public function ReferencesPlugin()
		{
		}

		override public function get name():String { return "References Plugin"; }
		override public function get author():String { return "Moonshine Project Team"; }
		override public function get description():String { return "Displays all references for a symbol in the entire workspace."; }

		private var referencesView:ReferencesView = new ReferencesView();

		override public function activate():void
		{
			super.activate();
			dispatcher.addEventListener(EVENT_OPEN_FIND_REFERENCES_VIEW, handleOpenFindReferencesView);
			dispatcher.addEventListener(ReferencesEvent.EVENT_SHOW_REFERENCES, handleShowReferences);
		}

		override public function deactivate():void
		{
			super.deactivate();
			dispatcher.removeEventListener(EVENT_OPEN_FIND_REFERENCES_VIEW, handleOpenFindReferencesView);
			dispatcher.removeEventListener(ReferencesEvent.EVENT_SHOW_REFERENCES, handleShowReferences);
		}

		private function handleOpenFindReferencesView(event:Event):void
		{
			var editor:ActionScriptTextEditor = model.activeEditor as ActionScriptTextEditor;
			if(!editor)
			{
				return;
			}
			PopUpManager.addPopUp(referencesView, DisplayObject(editor.parentApplication), true);
			PopUpManager.centerPopUp(referencesView);

			var startLine:int = editor.editor.model.selectedLineIndex;
			var startChar:int = editor.editor.startPos;
			var endLine:int = editor.editor.model.selectedLineIndex;
			var endChar:int = editor.editor.model.caretIndex;
			dispatcher.dispatchEvent(new TypeAheadEvent(TypeAheadEvent.EVENT_FIND_REFERENCES,
				startChar, startLine, endChar, endLine));
		}

		private function handleShowReferences(event:ReferencesEvent):void
		{
			var collection:ArrayCollection = referencesView.references;
			collection.removeAll();
			var references:Vector.<Location> = event.references;
			var itemCount:int = references.length;
			for(var i:int = 0; i < itemCount; i++)
			{
				var symbol:Location = references[i];
				collection.addItem(symbol);
			}
			collection.filterFunction = null;
			collection.refresh();
		}

	}
}
