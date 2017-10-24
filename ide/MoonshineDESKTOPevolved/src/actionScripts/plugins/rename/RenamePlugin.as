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
package actionScripts.plugins.rename
{
	import actionScripts.utils.applyTextEditsToFile;

	import flash.display.DisplayObject;
	import flash.events.Event;

	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;

	import actionScripts.events.RenameEvent;
	import actionScripts.events.TypeAheadEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugins.rename.view.RenameView;
	import actionScripts.ui.editor.ActionScriptTextEditor;
	import actionScripts.utils.TextUtil;
	import actionScripts.valueObjects.TextEdit;

	public class RenamePlugin extends PluginBase
	{
		public static const EVENT_OPEN_RENAME_VIEW:String = "openRenameView";

		public function RenamePlugin()
		{
		}

		override public function get name():String { return "Rename Plugin"; }
		override public function get author():String { return "Moonshine Project Team"; }
		override public function get description():String { return "Rename a symbol in a project."; }
		
		private var _line:int;
		private var _startChar:int;
		private var _endChar:int;

		private var renameView:RenameView = new RenameView();

		override public function activate():void
		{
			super.activate();
			dispatcher.addEventListener(EVENT_OPEN_RENAME_VIEW, handleOpenRenameView);
			dispatcher.addEventListener(RenameEvent.EVENT_APPLY_RENAME, applyRenameHandler);
		}

		override public function deactivate():void
		{
			super.deactivate();
			dispatcher.removeEventListener(EVENT_OPEN_RENAME_VIEW, handleOpenRenameView);
			dispatcher.removeEventListener(RenameEvent.EVENT_APPLY_RENAME, applyRenameHandler);
		}

		private function handleOpenRenameView(event:Event):void
		{
			var editor:ActionScriptTextEditor = model.activeEditor as ActionScriptTextEditor;
			if(!editor)
			{
				return;
			}
			var lineText:String = editor.editor.model.selectedLine.text;
			var caretIndex:int = editor.editor.model.caretIndex;
			this._startChar = TextUtil.startOfWord(lineText, caretIndex);
			this._endChar = TextUtil.endOfWord(lineText, caretIndex);
			this._line = editor.editor.model.selectedLineIndex;
			renameView.oldName = editor.editor.model.selectedLine.text.substr(this._startChar, this._endChar - this._startChar);
			renameView.addEventListener(CloseEvent.CLOSE, renameView_closeHandler);
			PopUpManager.addPopUp(renameView, DisplayObject(editor.parentApplication), true);
			PopUpManager.centerPopUp(renameView);
		}
		
		private function renameView_closeHandler(event:CloseEvent):void
		{
			renameView.removeEventListener(CloseEvent.CLOSE, renameView_closeHandler);
			if(event.detail !== Alert.OK)
			{
				return;
			}
			dispatcher.dispatchEvent(new TypeAheadEvent(TypeAheadEvent.EVENT_RENAME,
				this._startChar, this._line, this._endChar, this._line, renameView.newName));
		}
		
		private function applyRenameHandler(event:RenameEvent):void
		{
			var changes:Object = event.changes;
			var fileCount:int = 0;
			for(var key:String in changes)
			{
				fileCount++;
				//the key is the file path, the value is a list of TextEdits
				var file:FileLocation = new FileLocation(key, true);
				var changesInFile:Vector.<TextEdit> = changes[key] as Vector.<TextEdit>;
				applyTextEditsToFile(file, changesInFile);
			}
			if(fileCount === 0)
			{
				Alert.show("Could not rename symbol.", "Rename symbol", Alert.OK, renameView);
			}
		}

	}
}
