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
package actionScripts.plugin.rename
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import actionScripts.events.NewFileEvent;
	import actionScripts.events.RenameEvent;
	import actionScripts.events.TypeAheadEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.rename.view.RenameView;
	import actionScripts.ui.IContentWindow;
	import actionScripts.ui.editor.ActionScriptTextEditor;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.utils.CustomTree;
	import actionScripts.utils.TextUtil;
	import actionScripts.utils.UtilsCore;
	import actionScripts.utils.applyTextEditsToFile;
	import actionScripts.valueObjects.FileWrapper;
	import actionScripts.valueObjects.TextEdit;
	
	import components.popup.RenamePopup;

	public class RenamePlugin extends PluginBase
	{
		public static var RENAMED_FOLDER_STACK:Dictionary = new Dictionary();
		
		private var renameView:RenameView = new RenameView();
		private var renameFileView:RenamePopup;
		
		public function RenamePlugin() {	}

		override public function get name():String { return "Rename Plugin"; }
		override public function get author():String { return "Moonshine Project Team"; }
		override public function get description():String { return "Rename a symbol in a project."; }
		
		private var _line:int;
		private var _startChar:int;
		private var _endChar:int;

		override public function activate():void
		{
			super.activate();
			dispatcher.addEventListener(RenameEvent.EVENT_OPEN_RENAME_SYMBOL_VIEW, handleOpenRenameView);
			dispatcher.addEventListener(RenameEvent.EVENT_APPLY_RENAME, applyRenameHandler);
			dispatcher.addEventListener(RenameEvent.EVENT_OPEN_RENAME_FILE_VIEW, handleOpenRenameFileView);
		}

		override public function deactivate():void
		{
			super.deactivate();
			dispatcher.removeEventListener(RenameEvent.EVENT_OPEN_RENAME_SYMBOL_VIEW, handleOpenRenameView);
			dispatcher.removeEventListener(RenameEvent.EVENT_APPLY_RENAME, applyRenameHandler);
			dispatcher.removeEventListener(RenameEvent.EVENT_OPEN_RENAME_FILE_VIEW, handleOpenRenameFileView);
		}
		
		public static function updateFilePath(value:FileLocation):FileLocation
		{
			for (var i:String in RENAMED_FOLDER_STACK)
			{
				// we have a match
				if (value.fileBridge.nativePath.indexOf(i) != -1)
				{
					value = new FileLocation(value.fileBridge.nativePath.replace(i, RENAMED_FOLDER_STACK[i] + value.fileBridge.separator));
					break;
				}
			}
			
			return value;
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
			if (event.detail !== Alert.OK)
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
			
			if (fileCount === 0)
			{
				Alert.show("Could not rename symbol.", "Rename symbol", Alert.OK, renameView);
			}
		}
		
		private function handleOpenRenameFileView(event:RenameEvent):void
		{
			if (!renameFileView)
			{
				renameFileView = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, RenamePopup, true) as RenamePopup;
				renameFileView.addEventListener(CloseEvent.CLOSE, handleRenamePopupClose);
				renameFileView.addEventListener(NewFileEvent.EVENT_FILE_RENAMED, onFileRenamedRequest);
				renameFileView.wrapperOfFolderLocation = event.changes as FileWrapper;
				
				PopUpManager.centerPopUp(renameFileView);
			}
		}
		
		private function handleRenamePopupClose(event:CloseEvent):void
		{
			renameFileView.removeEventListener(CloseEvent.CLOSE, handleRenamePopupClose);
			renameFileView.removeEventListener(NewFileEvent.EVENT_FILE_RENAMED, onFileRenamedRequest);
			renameFileView = null;
		}
		
		private function onFileRenamedRequest(event:NewFileEvent):void
		{
			var newFile:FileLocation = event.insideLocation.file.fileBridge.parent.resolvePath(event.fileName);
			var existingFilePath:String = event.insideLocation.nativePath;
			
			event.insideLocation.file.fileBridge.moveTo(newFile, false);
			event.insideLocation.file = newFile;
			
			// we need to update file location of the (if any) opened instance 
			// of the file template
			if (!newFile.fileBridge.isDirectory)
			{
				for each (var tab:IContentWindow in model.editors)
				{
					var ed:BasicTextEditor = tab as BasicTextEditor;
					if (ed 
						&& ed.currentFile
						&& ed.currentFile.fileBridge.nativePath == existingFilePath)
					{
						ed.currentFile = newFile;
						ed.label = newFile.name;
					}
				}
			}
			else
			{
				// we shall going to use this stack to test while opening a file,
				// rename, delete etc. cases instead of updating unknown level of files/folders
				// inside the renamed folder
				trace(existingFilePath + newFile.fileBridge.separator, newFile.fileBridge.nativePath);
				RENAMED_FOLDER_STACK[existingFilePath + newFile.fileBridge.separator] = newFile.fileBridge.nativePath;
			}
			
			// updating the tree view
			var tree:CustomTree = model.mainView.getTreeViewPanel().tree;
			var tmpParent:FileWrapper = tree.getParentItem(event.insideLocation);
			var timeoutValue:uint = setTimeout(function():void 
				{
					var tmpFileW:FileWrapper = UtilsCore.findFileWrapperAgainstProject(event.insideLocation, null, tmpParent);
					tree.selectedItem = tmpFileW;
					
					var indexToItemRenderer:int = tree.getItemIndex(tmpFileW);
					tree.callLater(tree.scrollToIndex, [indexToItemRenderer]);
					clearTimeout(timeoutValue);
				}, 300);
		}
	}
}
