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
	import actionScripts.events.ChangeEvent;
	import actionScripts.events.EditorPluginEvent;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.events.RenameEvent;
	import actionScripts.events.TypeAheadEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugins.rename.view.RenameView;
	import actionScripts.ui.IContentWindow;
	import actionScripts.ui.editor.ActionScriptTextEditor;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.editor.text.TextEditor;
	import actionScripts.ui.editor.text.change.TextChangeInsert;
	import actionScripts.ui.editor.text.change.TextChangeMulti;
	import actionScripts.ui.editor.text.change.TextChangeRemove;
	import actionScripts.utils.TextUtil;
	import actionScripts.valueObjects.Position;
	import actionScripts.valueObjects.Range;
	import actionScripts.valueObjects.TextEdit;

	import flash.display.DisplayObject;
	import flash.events.Event;

	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;

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
		private var _pendingChanges:Object = {};

		private var renameView:RenameView = new RenameView();

		override public function activate():void
		{
			super.activate();
			dispatcher.addEventListener(EVENT_OPEN_RENAME_VIEW, handleOpenRenameView);
			dispatcher.addEventListener(RenameEvent.EVENT_APPLY_RENAME, applyRenameHandler);
			dispatcher.addEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, editorOpenHandler);
		}

		override public function deactivate():void
		{
			super.deactivate();
			dispatcher.removeEventListener(EVENT_OPEN_RENAME_VIEW, handleOpenRenameView);
			dispatcher.removeEventListener(RenameEvent.EVENT_APPLY_RENAME, applyRenameHandler);
			dispatcher.removeEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, editorOpenHandler);
		}

		private function findTextEditor(file:FileLocation):TextEditor
		{
			var editors:ArrayCollection = model.editors;
			var editorCount:int = editors.length;
			for(var i:int = 0; i < editorCount; i++)
			{
				var contentWindow:IContentWindow = IContentWindow(editors.getItemAt(i));
				if(contentWindow is BasicTextEditor)
				{
					var editor:BasicTextEditor = BasicTextEditor(contentWindow);
					if(editor.currentFile.fileBridge.nativePath === file.fileBridge.nativePath)
					{
						return editor.editor;
					}
				}
			}
			return null;
		}
		
		private function applyTextEditsToTextEditor(textEditor:TextEditor, textEdits:Vector.<TextEdit>):void
		{
			var multi:TextChangeMulti = new TextChangeMulti();
			var textEditsCount:int = textEdits.length;
			for(var i:int = 0; i < textEditsCount; i++)
			{
				var change:TextEdit = textEdits[i];
				var range:Range = change.range;
				var start:Position = range.start;
				var end:Position = range.end;
				var insert:TextChangeInsert = new TextChangeInsert(start.line, start.character, new <String>[change.newText]);
				if(start.line !== end.line || start.character !== end.character)
				{
					var remove:TextChangeRemove = new TextChangeRemove(start.line, start.character, end.line, end.character);
					multi.changes.push(remove)
				}
				multi.changes.push(insert);
			}
			textEditor.dispatchEvent(new ChangeEvent(ChangeEvent.TEXT_CHANGE, multi));
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
				var textEditor:TextEditor = this.findTextEditor(file);
				if(textEditor === null)
				{
					//we need to open the file before appling the changes
					//so we'll save the changes for later
					this._pendingChanges[key] = changesInFile;
					var openEvent:OpenFileEvent = new OpenFileEvent(OpenFileEvent.OPEN_FILE, file);
					dispatcher.dispatchEvent(openEvent);
					continue;
				}
				this.applyTextEditsToTextEditor(textEditor, changesInFile);
			}
			if(fileCount === 0)
			{
				Alert.show("Could not rename symbol.", "Rename symbol", Alert.OK, renameView);
			}
		}
		
		private function editorOpenHandler(event:EditorPluginEvent):void
		{
			var url:String = event.file.fileBridge.url;
			if(!(url in this._pendingChanges))
			{
				return;
			}
			var textEditor:TextEditor = event.editor;
			var changesInFile:Vector.<TextEdit> = this._pendingChanges[url] as Vector.<TextEdit>;
			delete this._pendingChanges[url];
			var file:Object = event.file.fileBridge.getFile;
			//this seems to be the only way to be sure that the editor is
			//displaying the file -JT
			file.addEventListener(Event.COMPLETE, function(event:Event):void
			{
				file.removeEventListener(event.target, arguments.callee);
				//this is pretty hacky! but otherwise, we get an error -JT
				renameView.callLater(applyTextEditsToTextEditor, [textEditor, changesInFile]);
			});
		}

	}
}
