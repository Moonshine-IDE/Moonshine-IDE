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
package actionScripts.plugin.organizeImports
{
	import actionScripts.events.ExecuteLanguageServerCommandEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.NewFileEvent;
	import actionScripts.events.OrganizeImportsEvent;
	import actionScripts.events.RenameEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.recentlyOpened.RecentlyOpenedPlugin;
	import actionScripts.plugin.rename.view.RenameView;
	import actionScripts.ui.IContentWindow;
	import actionScripts.ui.editor.ActionScriptTextEditor;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.utils.CustomTree;
	import actionScripts.utils.TextUtil;
	import actionScripts.utils.UtilsCore;
	import actionScripts.utils.applyTextEditsToFile;
	import actionScripts.valueObjects.FileWrapper;
	import actionScripts.valueObjects.ProjectReferenceVO;
	import actionScripts.valueObjects.TextEdit;

	import components.popup.RenamePopup;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;

	public class OrganizeImportsPlugin extends PluginBase
	{
		private static const COMMAND_ORGANIZE_IMPORTS_IN_URI:String = "nextgenas.organizeImportsInUri";

		public function OrganizeImportsPlugin() {	}

		override public function get name():String { return "Organize Imports Plugin"; }
		override public function get author():String { return "Moonshine Project Team"; }
		override public function get description():String { return "Organize imports in a file."; }

		override public function activate():void
		{
			super.activate();
			dispatcher.addEventListener(OrganizeImportsEvent.EVENT_ORGANIZE_IMPORTS, handleOrganizeImports);
		}

		override public function deactivate():void
		{
			super.deactivate();
			dispatcher.removeEventListener(OrganizeImportsEvent.EVENT_ORGANIZE_IMPORTS, handleOrganizeImports);
		}

		private function handleOrganizeImports(event:Event):void
		{
			var editor:ActionScriptTextEditor = model.activeEditor as ActionScriptTextEditor;
			if(!editor)
			{
				return;
			}
			var uri:String = editor.currentFile.fileBridge.url;
			dispatcher.dispatchEvent(new ExecuteLanguageServerCommandEvent(
				ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND,
				COMMAND_ORGANIZE_IMPORTS_IN_URI, [{external: uri}]));
		}
	}
}