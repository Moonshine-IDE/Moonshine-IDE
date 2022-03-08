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
    import actionScripts.events.RenameEvent;
    import actionScripts.events.TreeMenuItemEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.plugin.recentlyOpened.RecentlyOpenedPlugin;
    import moonshine.plugin.rename.view.RenameFileView;
    import moonshine.plugin.rename.view.RenameSymbolView;
    import actionScripts.ui.IContentWindow;
    import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.ui.editor.LanguageServerTextEditor;
    import actionScripts.utils.CustomTree;
    import actionScripts.utils.TextUtil;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.FileWrapper;
    import actionScripts.valueObjects.ProjectReferenceVO;
    
    import components.popup.newFile.NewFilePopup;
    import actionScripts.ui.FeathersUIWrapper;
    import actionScripts.ui.menu.MenuPlugin;
    import moonshine.lsp.WorkspaceEdit;
    import moonshine.lsp.Position;
    import actionScripts.utils.applyWorkspaceEdit;

	public class RenamePlugin extends PluginBase
	{
		private var renameSymbolViewWrapper:FeathersUIWrapper;
		private var renameSymbolView:RenameSymbolView;
		private var newFilePopup:NewFilePopup;
		private var renameFileViewWrapper:FeathersUIWrapper;
		private var renameFileView:RenameFileView;
		
		public function RenamePlugin()
		{
			renameSymbolView = new RenameSymbolView();
			renameSymbolView.addEventListener(Event.CLOSE, renameSymbolView_closeHandler);
			renameSymbolViewWrapper = new FeathersUIWrapper(renameSymbolView);
		}

		override public function get name():String { return "Rename Plugin"; }
		override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String { return "Rename a symbol in a project."; }
		
		private var _line:int;
		private var _startChar:int;
		private var _endChar:int;
		private var _existingFilePath:String;

		override public function activate():void
		{
			super.activate();
			dispatcher.addEventListener(RenameEvent.EVENT_OPEN_RENAME_SYMBOL_VIEW, handleOpenRenameSymbolView);
			dispatcher.addEventListener(RenameEvent.EVENT_OPEN_RENAME_FILE_VIEW, handleOpenRenameFileView);
			dispatcher.addEventListener(DuplicateEvent.EVENT_OPEN_DUPLICATE_FILE_VIEW, handleOpenDuplicateFileView);
		}

		override public function deactivate():void
		{
			super.deactivate();
			dispatcher.removeEventListener(RenameEvent.EVENT_OPEN_RENAME_SYMBOL_VIEW, handleOpenRenameSymbolView);
			dispatcher.removeEventListener(RenameEvent.EVENT_OPEN_RENAME_FILE_VIEW, handleOpenRenameFileView);
			dispatcher.removeEventListener(DuplicateEvent.EVENT_OPEN_DUPLICATE_FILE_VIEW, handleOpenDuplicateFileView);
		}

		private function handleOpenRenameSymbolView(event:Event):void
		{
			var lspEditor:LanguageServerTextEditor = model.activeEditor as LanguageServerTextEditor;
			if (!lspEditor || !lspEditor.languageClient)
			{
				Alert.show("Nothing to rename", ConstantsCoreVO.MOONSHINE_IDE_LABEL);
				return;
			}
			var lineText:String = lspEditor.editor.caretLine.text;
			var caretIndex:int = lspEditor.editor.caretCharIndex;
			this._startChar = TextUtil.startOfWord(lineText, caretIndex);
			this._endChar = TextUtil.endOfWord(lineText, caretIndex);
			this._line = lspEditor.editor.caretLineIndex;
			renameSymbolView.existingSymbolName = lineText.substr(this._startChar, this._endChar - this._startChar);
			PopUpManager.addPopUp(renameSymbolViewWrapper, FlexGlobals.topLevelApplication as DisplayObject, true);
			PopUpManager.centerPopUp(renameSymbolViewWrapper);
			renameSymbolViewWrapper.assignFocus("top");
			renameSymbolViewWrapper.stage.addEventListener(Event.RESIZE, renameSymbolView_stage_resizeHandler, false, 0, true);
		}
		
		private function renameSymbolView_closeHandler(event:Event):void
		{
			var lspEditor:LanguageServerTextEditor = model.activeEditor as LanguageServerTextEditor;
			if(!lspEditor || !lspEditor.languageClient)
			{
				return;
			}
			
			if(renameSymbolView.newSymbolName != null)
			{
				var startLine:int = lspEditor.editor.caretLineIndex;
				var startChar:int = lspEditor.editor.caretCharIndex;
				lspEditor.languageClient.rename({
					textDocument: {
						uri: lspEditor.currentFile.fileBridge.url
					},
					position: new Position(startLine, startChar),
					newName: renameSymbolView.newSymbolName
				}, function(edit:WorkspaceEdit):void
				{
					if(!edit)
					{
						return;
					}
					applyWorkspaceEdit(edit);
				});
			}
			
			renameSymbolViewWrapper.stage.removeEventListener(Event.RESIZE, renameSymbolView_stage_resizeHandler);
			PopUpManager.removePopUp(renameSymbolViewWrapper);
		}

		private function renameSymbolView_stage_resizeHandler(event:Event):void
		{
			PopUpManager.centerPopUp(renameSymbolViewWrapper);
		}

		private function renameFileView_stage_resizeHandler(event:Event):void
		{
			PopUpManager.centerPopUp(renameFileViewWrapper);
		}
		
		private function handleOpenRenameFileView(event:RenameEvent):void
		{
			if (!(event.changes as FileWrapper).file.fileBridge.checkFileExistenceAndReport()) return;
			
			if (!renameFileView)
			{
				renameFileView = new RenameFileView();
				renameFileView.fileWrapper = event.changes as FileWrapper;
				renameFileView.addEventListener(Event.CLOSE, handleRenameFileViewClose);
				renameFileViewWrapper = new FeathersUIWrapper(renameFileView);
				PopUpManager.addPopUp(renameFileViewWrapper, FlexGlobals.topLevelApplication as DisplayObject, true);
				PopUpManager.centerPopUp(renameFileViewWrapper);
				renameFileViewWrapper.assignFocus("top");
				renameFileViewWrapper.stage.addEventListener(Event.RESIZE, renameFileView_stage_resizeHandler, false, 0, true);
				
				dispatcher.dispatchEvent(new Event(MenuPlugin.CHANGE_MENU_MAC_DISABLE_STATE));
			}
		}
		
		private function handleRenameFileViewClose(event:Event):void
		{
			if(renameFileView.newName != null)
			{
				onFileRenamedRequest(renameFileView.fileWrapper, renameFileView.newName);
			}

			dispatcher.dispatchEvent(new Event(MenuPlugin.CHANGE_MENU_MAC_ENABLE_STATE));

			renameFileView.removeEventListener(CloseEvent.CLOSE, handleRenameFileViewClose);
			renameFileView = null;

			renameFileViewWrapper.stage.removeEventListener(Event.RESIZE, renameFileView_stage_resizeHandler);
			PopUpManager.removePopUp(renameFileViewWrapper);
			renameFileViewWrapper = null;
		}
		
		private function onFileRenamedRequest(fileWrapper:FileWrapper, newName:String):void
		{
			var fileVisualEditor:FileLocation = UtilsCore.getVisualEditorSourceFile(fileWrapper);
			var newFile:FileLocation = fileWrapper.file.fileBridge.parent.resolvePath(newName);
			_existingFilePath = fileWrapper.nativePath;
			
			fileWrapper.file.fileBridge.moveTo(newFile, false);
			fileWrapper.name = newFile.name;
			fileWrapper.file = newFile;

			if (fileVisualEditor)
			{
				var newVisualEditorFile:FileLocation = fileVisualEditor.fileBridge.parent.resolvePath(newFile.fileBridge.nameWithoutExtension + ".xml");
				fileVisualEditor.fileBridge.moveTo(newVisualEditorFile, false);
			}

			// we need to update file location of the (if any) opened instance 
			// of the file template
			if (newFile.fileBridge.isDirectory)
			{
				updateChildrenPath(fileWrapper, _existingFilePath + newFile.fileBridge.separator, newFile.fileBridge.nativePath + newFile.fileBridge.separator);
			}
			else
			{
				checkAndUpdateOpenedTabs(_existingFilePath, newFile);
			}
			
			// updating the tree view
			var tree:CustomTree = model.mainView.getTreeViewPanel().tree;
			var tmpParent:FileWrapper = tree.getParentItem(fileWrapper);
			
			var timeoutValue:uint = setTimeout(function():void 
				{
					model.mainView.getTreeViewPanel().sortChildren(fileWrapper);
					
					var tmpFileW:FileWrapper = UtilsCore.findFileWrapperAgainstProject(fileWrapper, null, tmpParent);
					tree.selectedItem = tmpFileW;
					
					var indexToItemRenderer:int = tree.getItemIndex(tmpFileW);
					tree.callLater(tree.scrollToIndex, [indexToItemRenderer]);
					
					dispatcher.dispatchEvent(new TreeMenuItemEvent(TreeMenuItemEvent.FILE_RENAMED, null, fileWrapper));
					clearTimeout(timeoutValue);
				}, 300);
		}
		
		private function handleOpenDuplicateFileView(event:DuplicateEvent):void
		{
			if (!event.fileWrapper.file.fileBridge.checkFileExistenceAndReport()) return;
			
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
			var fileToSave:FileLocation = event.fileWrapper.file.fileBridge.resolvePath(event.fileName + 
				(event.fileLocation.fileBridge.extension ? "."+ event.fileLocation.fileBridge.extension : ""));
			
			// based on request, we also updates class name and package path
			// to the duplicated file, in case of actionScript class
			if (event.fileLocation.fileBridge.extension && event.fileLocation.fileBridge.extension == "as")
			{
				var updatedContent:String = getUpdatedFileContent(event.fileWrapper, event.fileLocation, event.fileName);
				fileToSave.fileBridge.save(updatedContent);
			}
			else
			{
				event.fileLocation.fileBridge.copyTo(fileToSave, true);
			}
			
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
		
		private function getUpdatedFileContent(projectRef:FileWrapper, source:FileLocation, newFileName:String):String
		{
			var sourceContentLines:Array = String(source.fileBridge.read()).split("\n");
			var classNameStartIndex:int;
			
			var nameOnly:Array = source.fileBridge.name.split(".");
			nameOnly.pop();
			var sourceFileName:String = nameOnly.join(".");
			
			var isPackageFound:Boolean;
			var isClassDecFound:Boolean;
			var isConstructorFound:Boolean;
			
			sourceContentLines = sourceContentLines.map(function(line:String, index:int, arr:Array):String
			{
				if (!isPackageFound && line.indexOf("package") !== -1)
				{
					isPackageFound = true;
					
					var project:AS3ProjectVO = UtilsCore.getProjectFromProjectFolder(projectRef) as AS3ProjectVO;
					var isInsideSourceDirectory:Boolean = source.fileBridge.nativePath.indexOf(project.sourceFolder.fileBridge.nativePath + source.fileBridge.separator) != -1;
					
					// do not update package path if not inside source directory
					if (isInsideSourceDirectory)
					{
						var tmpPackagePath:String = UtilsCore.getPackageReferenceByProjectPath(Vector.<FileLocation>([project.sourceFolder]), projectRef.nativePath, null, null, false);
						if (tmpPackagePath.charAt(0) == ".")
						{
							tmpPackagePath = tmpPackagePath.substr(1, tmpPackagePath.length);
						}
						
						return "package "+ tmpPackagePath;
					}
				}

                classNameStartIndex = line.indexOf(" class "+ sourceFileName);
				if (!isClassDecFound && classNameStartIndex !== -1)
				{
					isClassDecFound = true;
					return line.substr(0, classNameStartIndex + 7) + newFileName + line.substr(classNameStartIndex + 7 + sourceFileName.length, line.length);
				}

                classNameStartIndex = line.indexOf(" function "+ sourceFileName +"(");
				if (!isConstructorFound && classNameStartIndex !== -1)
				{
					isConstructorFound = true;
					return line.substr(0, classNameStartIndex + 10) + newFileName + line.substr(classNameStartIndex + 10 + sourceFileName.length, line.length);
				}

				return line;
			});

			return sourceContentLines.join("\n");
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