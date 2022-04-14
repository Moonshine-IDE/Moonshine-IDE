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
package actionScripts.ui.editor
{
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.utils.clearInterval;
    import flash.utils.setTimeout;

    import mx.core.FlexGlobals;
    import mx.events.FlexEvent;
    import mx.managers.IFocusManagerComponent;
    import mx.managers.PopUpManager;
    import mx.utils.ObjectUtil;

    import spark.components.Group;

    import actionScripts.controllers.DataAgent;
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.events.RefreshTreeEvent;
    import actionScripts.events.SaveFileEvent;
    import actionScripts.events.UpdateTabEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.locator.IDEModel;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.plugin.console.ConsoleOutputEvent;
    import actionScripts.ui.FeathersUIWrapper;
    import actionScripts.ui.IContentWindow;
    import actionScripts.ui.IContentWindowReloadable;
    import actionScripts.ui.IFileContentWindow;
    import actionScripts.ui.editor.text.DebugHighlightManager;
    import actionScripts.ui.editor.text.events.DebugLineEvent;
    import actionScripts.ui.tabview.CloseTabEvent;
    import actionScripts.ui.tabview.TabEvent;
    import actionScripts.utils.SharedObjectUtil;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.valueObjects.URLDescriptorVO;

    import components.popup.FileSavePopup;
    import components.popup.SelectOpenedProject;
    import components.views.project.TreeView;

    import moonshine.editor.text.TextEditor;
    import moonshine.editor.text.TextEditorSearchResult;
    import moonshine.editor.text.events.TextEditorChangeEvent;
    import moonshine.editor.text.events.TextEditorLineEvent;

	import spark.components.Label;

	public class BasicTextEditor extends Group implements IContentWindow, IFileContentWindow, IFocusManagerComponent, IContentWindowReloadable
	{
		public var defaultLabel:String = "New";
		public var projectPath:String;
		public var editor:TextEditor;
		public var lastOpenType:String;

		protected var editorWrapper:FeathersUIWrapper;
		protected var lastOpenedUpdatedInMoonshine:Date;
		protected var file:FileLocation;
		protected var created:Boolean;
		protected var loadingFile:Boolean;
		protected var tempScrollTo:int = -1;
		protected var tempScrollToCaret:Boolean = false;
		protected var tempSelectionStartLineIndex:int = -1;
		protected var tempSelectionStartCharIndex:int = -1;
		protected var tempSelectionEndLineIndex:int = -1;
		protected var tempSelectionEndCharIndex:int = -1;
		protected var loader: DataAgent;
		protected var model:IDEModel = IDEModel.getInstance();
        protected var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
        protected var _isChanged:Boolean;

		private var pop:FileSavePopup;
		private var selectProjectPopup:SelectOpenedProject;
		protected var isVisualEditor:Boolean;

		private var _readOnly:Boolean = false;
		public function get readOnly():Boolean
		{
			return this._readOnly;
		}
		
		public function get label():String
		{
			var labelChangeIndicator:String = _isChanged ? "*" : "";
			if (!file)
            {
                return labelChangeIndicator + defaultLabel;
            }

			return labelChangeIndicator + file.fileBridge.name;
		}
		public function get longLabel():String
		{
			if (!file) 
				return defaultLabel;
			return file.fileBridge.nativePath;	
		}

		public function get currentFile():FileLocation
		{
			return file;
		}
		public function set currentFile(value:FileLocation):void
		{
			if (file != value)
            {
                file = value;
                dispatchEvent(new Event('labelChanged'));
            }
		}

		public function get text():String
		{
			return editor.text;
		}
		public function set text(value:String):void
		{
			editor.text = value;
		}

		private var _prevSearch:*;

		public function BasicTextEditor(readOnly:Boolean = false)
		{
			super();
			_readOnly = readOnly;
			
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
			
			percentHeight = 100;
			percentWidth = 100;
			addEventListener(FlexEvent.CREATION_COMPLETE, basicTextEditorCreationCompleteHandler);
			initializeChildrens();
		}

		public function isEmpty():Boolean
		{
			if (!file && text == "")
				return true;
			return false;
		}

		public function isChanged():Boolean
		{
			return _isChanged;
		}

		public function getEditorComponent():TextEditor
		{
			return editor;
		}
		
		// Search may be RegExp or String
		public function search(search:*, backwards:Boolean=false):TextEditorSearchResult
		{
			if(checkIfNewSearchMatchesPrevious(search))
			{
				return editor.findNext(backwards, true);
			}
			return editor.find(search, backwards);
		}
		
		// Search all instances and highlight
		// Preferably used in 'search in project' sequence
		public function searchAndShowAll(search:*):void
		{
			//editor.searchAndShowAll(search);
		}
		
		// Search may be RegExp or String
		public function searchReplace(search:*, replace:String, all:Boolean=false):TextEditorSearchResult
		{
			if(!checkIfNewSearchMatchesPrevious(search))
			{
				editor.find(search);
			}
			if(all)
			{
				return editor.replaceAll(replace)
			}
			return editor.replaceOne(replace);
		}

		public function clearSearch():void
		{
			_prevSearch = null;
			editor.clearFind();
		}

		protected function checkIfNewSearchMatchesPrevious(search:*):Boolean
		{
			var matches:Boolean = false;
			if(search is RegExp && _prevSearch is RegExp)
			{
				matches = search.toString() == _prevSearch.toString();
			}
			else if(search is String && _prevSearch is String)
			{
				matches = search == _prevSearch;
			}
			_prevSearch = search;
			return matches;
		}
		
		protected function addedToStageHandler(event:Event):void
		{
			this.addGlobalListeners();
		}
		
		protected function removedFromStageHandler(event:Event):void
		{
			this.removeGlobalListeners();
		}
		
		protected function addGlobalListeners():void
		{
			dispatcher.addEventListener(CloseTabEvent.EVENT_CLOSE_TAB, closeTabHandler);
			dispatcher.addEventListener(TabEvent.EVENT_TAB_SELECT, tabSelectHandler);
			dispatcher.addEventListener(DebugLineEvent.SET_DEBUG_FINISH, setDebugFinishHandler);
		}
		
		protected function removeGlobalListeners():void
		{
			dispatcher.removeEventListener(CloseTabEvent.EVENT_CLOSE_TAB, closeTabHandler);
			dispatcher.removeEventListener(TabEvent.EVENT_TAB_SELECT, tabSelectHandler);
			dispatcher.removeEventListener(DebugLineEvent.SET_DEBUG_FINISH, setDebugFinishHandler);
		}
		
		protected function closeTabHandler(event:Event):void
		{
			if (event is CloseTabEvent)
			{
				if ((event as CloseTabEvent).isUserTriggered)
				{
					SharedObjectUtil.removeLocationOfEditorFile(
						(event as CloseTabEvent).tab as IContentWindow
					);
				}
			}
			// suppose to call only when keyboard shortcuts Event
			else if (model.activeEditor == this)
			{
				SharedObjectUtil.removeLocationOfEditorFile(model.activeEditor);
			}
		}
		
		protected function tabSelectHandler(event:TabEvent):void
		{
			if (event.child == this)
			{
				// check for any externally update
				checkFileIfChanged();
				editorWrapper.enabled = true;
			}
			else
			{
				editorWrapper.enabled = false;
			}
		}
		
		protected function initializeChildrens():void
		{
			if(!editor)
			{
				editor = new TextEditor(null, _readOnly);
			}
			editor.addEventListener(TextEditorChangeEvent.TEXT_CHANGE, handleTextChange);
			editor.addEventListener(TextEditorLineEvent.TOGGLE_BREAKPOINT, handleToggleBreakpoint);
			editorWrapper = new FeathersUIWrapper(editor);
			editorWrapper.percentHeight = 100;
			editorWrapper.percentWidth = 100;
			text = "";
		}

		override public function setFocus():void
		{
			if (editor)
			{
				editorWrapper.setFocus();
			}
		}

		override protected function createChildren():void
		{
			if (!isVisualEditor)
            {
				this.addElement(editorWrapper);
            }

			super.createChildren();
			
			// @note
			// https://github.com/Moonshine-IDE/Moonshine-IDE/issues/31
			// to ensure if the file has a pending debug/breakpoint call
			// call extended from OpenFileCommand/openFile(..)
			if (currentFile && currentFile.fileBridge.nativePath == DebugHighlightManager.NONOPENED_DEBUG_FILE_PATH)
			{
				editor.debuggerLineIndex = DebugHighlightManager.NONOPENED_DEBUG_FILE_LINE;
			}
		}

		protected function basicTextEditorCreationCompleteHandler(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, basicTextEditorCreationCompleteHandler);
			
			created = true;
			if (file)
				callLater(open, [file]);
		}

		public function setSelection(startLine:int, startChar:int, endLine:int, endChar:int):void
		{
			if (loadingFile)
			{
				tempSelectionStartLineIndex = startLine;
				tempSelectionStartCharIndex = startChar;
				tempSelectionEndLineIndex = endLine;
				tempSelectionEndCharIndex = endChar;
			}
			else
			{
				editor.setSelection(startLine, startChar, endLine, endChar);
			}
		}

		public function scrollToCaret():void
		{
			if (loadingFile)
			{
				tempScrollTo = -1;
				tempScrollToCaret = true;
			}
			else
			{
				editor.scrollToCaret();
			}
		}

		public function scrollTo(line:int, eventType:String=null):void
		{
			if (loadingFile)
			{
				tempScrollToCaret = false;
				tempScrollTo = line;
			}
			else
			{
				editor.lineScrollY = line;
			}
		}
		
		public function setContent(content:String):void
		{
			editor.text = content;
			updateChangeStatus();
		}
		
		public function open(newFile:FileLocation, fileData:Object=null):void
		{
			loadingFile = true;
			currentFile = newFile;
			if (fileData) 
			{
				openFileAsStringHandler(fileData as String);
				return;
			}
			else if (!created || !file.fileBridge.exists)	return;
			
			file.fileBridge.getFile.addEventListener(Event.COMPLETE, openHandler);
			
			// Load later so we have time to draw before everything happens
			callLater(file.fileBridge.load);
		}
		
		public function checkFileIfChanged():void
		{
			// physical file do not exist anymore
			if (file && !file.fileBridge.exists)
			{
				dispatcher.dispatchEvent(new UpdateTabEvent(UpdateTabEvent.EVENT_TAB_FILE_EXIST_NOMORE, this));
			}
			
			// physical file is an updated one
			else if (lastOpenedUpdatedInMoonshine && 
				ObjectUtil.dateCompare(file.fileBridge.modificationDate, lastOpenedUpdatedInMoonshine) != 0)
			{
				dispatcher.dispatchEvent(new UpdateTabEvent(UpdateTabEvent.EVENT_TAB_UPDATED_OUTSIDE, this));
			}
		}
		
		public function reload():void
		{
			loadingFile = true;
			file.fileBridge.getFile.addEventListener(Event.COMPLETE, openHandler);
			callLater(file.fileBridge.load);
		}
		
		protected function openFileAsStringHandler(data:String):void
		{
			loadingFile = false;
			// Get data from file
			text = data;
			commitTempValues();
		}

		protected function openHandler(event:Event):void
		{
			loadingFile = false;
			// Get data from file
			text = file.fileBridge.data.toString();

			commitTempValues();
			updateChangeStatus();
			file.fileBridge.getFile.removeEventListener(Event.COMPLETE, openHandler);
		}

		public function save():void
		{
			if (!file)
			{
				saveAs();
				return;
			}

			if (ConstantsCoreVO.IS_AIR && !file.fileBridge.exists)
			{
				file.fileBridge.createFile();
				file.fileBridge.save(text);
				editor.save();
				updateChangeStatus();
				
				// Tell the world we've changed
				dispatcher.dispatchEvent(
					new SaveFileEvent(SaveFileEvent.FILE_SAVED, file, this)
				);
			}
			else if (ConstantsCoreVO.IS_AIR)
			{
				file.fileBridge.save(text);
				editor.save();
				updateChangeStatus();
				
				// Tell the world we've changed
				dispatcher.dispatchEvent(
					new SaveFileEvent(SaveFileEvent.FILE_SAVED, file, this)
				);
			}
			else if (!ConstantsCoreVO.IS_AIR)
			{
				dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, file.fileBridge.name +": Saving in process..."));
				loader = new DataAgent(URLDescriptorVO.FILE_MODIFY, onSaveSuccess, onSaveFault,
						{path:file.fileBridge.nativePath,text:text});
			}
		}
		
		private function onSaveFault(message:String):void
		{
			//Alert.show("Save Fault"+message);
			dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, file.fileBridge.name +": Save error!"));
			loader = null;
		}
		
		private function onSaveSuccess(value:Object, message:String=null):void
		{
			//Alert.show("Save Fault"+message);
			loader = null;
			editor.save();
			updateChangeStatus();
			dispatcher.dispatchEvent(
					new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, file.fileBridge.name +": Saving successful."));
			dispatcher.dispatchEvent(new SaveFileEvent(SaveFileEvent.FILE_SAVED, file, this));
		}
 
		public function saveAs(file:FileLocation=null):void
		{
			if (file)
			{
				currentFile = file;
				save();
				// Update labels
				dispatchEvent(new Event('labelChanged'));
				dispatcher.dispatchEvent(new RefreshTreeEvent(file));
			    return;
			}
			
			if (ConstantsCoreVO.IS_AIR)
			{ 
				if(this.file)
                {
                    saveAsPath(this.file.fileBridge.parent.fileBridge.nativePath);
                }
				else if (model.projects.length > 1 )
				{
					if (model.mainView.isProjectViewAdded)
					{
						var tmpTreeView:TreeView = model.mainView.getTreeViewPanel();
						if(tmpTreeView) //might be null if closed by user
						{
							var projectReference:ProjectVO = tmpTreeView.getProjectBySelection();
							if (projectReference)
							{
								saveAsPath(projectReference.folderPath);
								return;
							}
						}
					}
					selectProjectPopup = new SelectOpenedProject();
					PopUpManager.addPopUp(selectProjectPopup, FlexGlobals.topLevelApplication as DisplayObject, false);
					PopUpManager.centerPopUp(selectProjectPopup);
					selectProjectPopup.addEventListener(SelectOpenedProject.PROJECT_SELECTED, onProjectSelected);
					selectProjectPopup.addEventListener(SelectOpenedProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
				}
				else if (model.projects.length != 0)
				{
					saveAsPath((model.projects[0] as ProjectVO).folderPath);
				}
			    else
					saveAsPath(null)
			}
			else
			{
				pop = new FileSavePopup();
				PopUpManager.addPopUp(pop, FlexGlobals.topLevelApplication as DisplayObject, false);
				PopUpManager.centerPopUp(pop);
			}
			function saveAsPath(path:String):void{
				model.fileCore.browseForSave(handleSaveAsSelect, null, "Save As", path);
			}
			function onProjectSelected(event:Event):void
			{
				saveAsPath((selectProjectPopup.selectedProject as AS3ProjectVO).folderPath );
				onProjectSelectionCancelled(null);
			}
			function onProjectSelectionCancelled(event:Event):void
			{
				selectProjectPopup.removeEventListener(SelectOpenedProject.PROJECT_SELECTED, onProjectSelected);
				selectProjectPopup.removeEventListener(SelectOpenedProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
				selectProjectPopup = null;
			}
		}
		
		public function onFileSaveSuccess(file:FileLocation=null):void
		{
			//saveAs(file);
			currentFile = file;
			dispatchEvent(new Event('labelChanged'));
			editor.save();
			dispatcher.dispatchEvent(new SaveFileEvent(SaveFileEvent.FILE_SAVED, file, this));
			updateChangeStatus();
		}
		
		protected function handleTextChange(event:TextEditorChangeEvent):void
		{
			if (editor.edited != _isChanged)
			{
				updateChangeStatus();	
			}
		}

		protected function handleToggleBreakpoint(event:TextEditorLineEvent):void
		{
			var lineIndex:int = event.lineIndex;
			var enabled:Boolean = editor.breakpoints.indexOf(lineIndex) != -1;
			dispatcher.dispatchEvent(new DebugLineEvent(DebugLineEvent.SET_DEBUG_LINE, lineIndex, enabled));
		}
		
		protected function updateChangeStatus():void
		{
			_isChanged = editor.edited;
			dispatchEvent(new Event('labelChanged'));
			
			var setLastUpdateTime:uint = setTimeout(function():void
			{
				clearInterval(setLastUpdateTime);
				lastOpenedUpdatedInMoonshine = file.fileBridge.modificationDate;
			}, 1000);
		}

		protected function handleSaveAsSelect(fileObj:Object):void
		{
			saveAs(new FileLocation(fileObj.nativePath));
		}

        private function commitTempValues():void
        {
			if (loadingFile)
			{
				//not ready yet
				return;
			}
            if (tempSelectionStartLineIndex != -1)
            {
                setSelection(tempSelectionStartLineIndex, tempSelectionStartCharIndex, tempSelectionEndLineIndex, tempSelectionEndCharIndex);
                tempSelectionStartLineIndex = -1;
                tempSelectionStartCharIndex = -1;
                tempSelectionEndLineIndex = -1;
                tempSelectionEndCharIndex = -1;
            }
            if (tempScrollToCaret)
            {
                scrollToCaret();
                tempScrollToCaret = false;
            }
            if (tempScrollTo != -1)
            {
                scrollTo(tempScrollTo, lastOpenType);
                tempScrollTo = -1;
            }
        }

		private function setDebugFinishHandler(event:DebugLineEvent):void
		{
			editor.debuggerLineIndex = -1;
		}
    }
}