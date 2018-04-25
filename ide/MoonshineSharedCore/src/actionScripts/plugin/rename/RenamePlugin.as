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
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import actionScripts.events.DuplicateEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.NewFileEvent;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.events.RenameEvent;
	import actionScripts.events.TreeMenuItemEvent;
	import actionScripts.events.TypeAheadEvent;
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
	
	import components.popup.NewFilePopup;
	import components.popup.RenamePopup;

	public class RenamePlugin extends PluginBase
	{
		private var renameView:RenameView = new RenameView();
		private var newFilePopup:NewFilePopup;
		private var renameFileView:RenamePopup;
		
		public function RenamePlugin() {	}

		override public function get name():String { return "Rename Plugin"; }
		override public function get author():String { return "Moonshine Project Team"; }
		override public function get description():String { return "Rename a symbol in a project."; }
		
		private var _line:int;
		private var _startChar:int;
		private var _endChar:int;
		private var _existingFilePath:String;

		override public function activate():void
		{
			super.activate();
			dispatcher.addEventListener(RenameEvent.EVENT_OPEN_RENAME_SYMBOL_VIEW, handleOpenRenameView);
			dispatcher.addEventListener(RenameEvent.EVENT_APPLY_RENAME, applyRenameHandler);
			dispatcher.addEventListener(RenameEvent.EVENT_OPEN_RENAME_FILE_VIEW, handleOpenRenameFileView);
			dispatcher.addEventListener(DuplicateEvent.EVENT_OPEN_DUPLICATE_FILE_VIEW, handleOpenDuplicateFileView);
		}

		override public function deactivate():void
		{
			super.deactivate();
			dispatcher.removeEventListener(RenameEvent.EVENT_OPEN_RENAME_SYMBOL_VIEW, handleOpenRenameView);
			dispatcher.removeEventListener(RenameEvent.EVENT_APPLY_RENAME, applyRenameHandler);
			dispatcher.removeEventListener(RenameEvent.EVENT_OPEN_RENAME_FILE_VIEW, handleOpenRenameFileView);
			dispatcher.removeEventListener(DuplicateEvent.EVENT_OPEN_DUPLICATE_FILE_VIEW, handleOpenDuplicateFileView);
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
			_existingFilePath = event.insideLocation.nativePath;
			
			event.insideLocation.file.fileBridge.moveTo(newFile, false);
			event.insideLocation.file = newFile;
			
			// we need to update file location of the (if any) opened instance 
			// of the file template
			if (newFile.fileBridge.isDirectory)
			{
				updateChildrenPath(event.insideLocation, _existingFilePath + newFile.fileBridge.separator, newFile.fileBridge.nativePath + newFile.fileBridge.separator);
			}
			else
			{
				checkAndUpdateOpenedTabs(_existingFilePath, newFile);
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
					
					dispatcher.dispatchEvent(new TreeMenuItemEvent(TreeMenuItemEvent.FILE_RENAMED, null, event.insideLocation));
					clearTimeout(timeoutValue);
				}, 300);
		}
		
		private function handleOpenDuplicateFileView(event:DuplicateEvent):void
		{
			if (!newFilePopup)
			{
				newFilePopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, NewFilePopup, true) as NewFilePopup;
				newFilePopup.addEventListener(CloseEvent.CLOSE, handleFilePopupClose);
				newFilePopup.addEventListener(DuplicateEvent.EVENT_APPLY_DUPLICATE, onFileDuplicateRequest);
				newFilePopup.openType = NewFilePopup.AS_DUPLICATE_FILE;
				newFilePopup.folderFileLocation = event.fileWrapper.file;
				
				var creatingItemIn:FileWrapper = FileWrapper(model.mainView.getTreeViewPanel().tree.getParentItem(event.fileWrapper));
				newFilePopup.wrapperOfFolderLocation = creatingItemIn;
				newFilePopup.wrapperBelongToProject = UtilsCore.getProjectFromProjectFolder(creatingItemIn);
				
				PopUpManager.centerPopUp(newFilePopup);
			}
		}
		
		private function handleFilePopupClose(event:CloseEvent):void
		{
			newFilePopup.removeEventListener(CloseEvent.CLOSE, handleFilePopupClose);
			newFilePopup.removeEventListener(NewFileEvent.EVENT_NEW_FILE, onFileDuplicateRequest);
			newFilePopup = null;
		}
		
		private function onFileDuplicateRequest(event:DuplicateEvent):void
		{
			var fileToSave:FileLocation = event.fileWrapper.file.fileBridge.resolvePath(event.fileName +"."+ event.fileLocation.fileBridge.extension);
			event.fileLocation.fileBridge.copyTo(fileToSave, true);
			
			// opens the file after writing done
			/*dispatcher.dispatchEvent(
				new OpenFileEvent(OpenFileEvent.OPEN_FILE, fileToSave, -1, event.insideLocation)
			);*/
			
			// notify the tree view if it needs to refresh
			// the containing folder to make newly created file show
			if (event.fileWrapper)
			{
				dispatcher.dispatchEvent(
					new TreeMenuItemEvent(TreeMenuItemEvent.NEW_FILE_CREATED, fileToSave.fileBridge.nativePath, event.fileWrapper)
				);
			}
		}
		
		private function updateChildrenPath(fw:FileWrapper, oldPath:String, newPath:String):void
		{
			for each (var i:FileWrapper in fw.children)
			{
				_existingFilePath = i.file.fileBridge.nativePath;
				i.file = new FileLocation(i.file.fileBridge.nativePath.replace(oldPath, newPath));
				if (!i.children) 
				{
					checkAndUpdateOpenedTabs(_existingFilePath, i.file);
				}
				else updateChildrenPath(i, oldPath, newPath);
			}
		}
		
		private function checkAndUpdateOpenedTabs(oldPath:String, newFile:FileLocation):void
		{
			// updates to tab
			for each (var tab:IContentWindow in model.editors)
			{
				var ed:BasicTextEditor = tab as BasicTextEditor;
				if (ed 
					&& ed.currentFile
					&& ed.currentFile.fileBridge.nativePath == oldPath)
				{
					ed.currentFile = newFile;
					break;
				}
			}
			
			// updates entry in recent files list
			for each (var i:ProjectReferenceVO in model.recentlyOpenedFiles)
			{
				if (i.path == oldPath)
				{
					i.path = newFile.fileBridge.nativePath;
					i.name = newFile.name;
					GlobalEventDispatcher.getInstance().dispatchEvent(new Event(RecentlyOpenedPlugin.RECENT_FILES_LIST_UPDATED));
					break;
				}
			}
		}
	}
}