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
    
    import mx.core.FlexGlobals;
    import mx.events.FlexEvent;
    import mx.managers.IFocusManagerComponent;
    import mx.managers.PopUpManager;
    import mx.utils.ObjectUtil;
    
    import spark.components.Group;
    
    import actionScripts.controllers.DataAgent;
    import actionScripts.events.ChangeEvent;
    import actionScripts.events.CodeActionsEvent;
    import actionScripts.events.CompletionItemsEvent;
    import actionScripts.events.DiagnosticsEvent;
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.events.LanguageServerMenuEvent;
    import actionScripts.events.ProjectEvent;
    import actionScripts.events.RefreshTreeEvent;
    import actionScripts.events.SaveFileEvent;
    import actionScripts.events.SignatureHelpEvent;
    import actionScripts.events.UpdateTabEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.locator.IDEModel;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.plugin.console.ConsoleOutputEvent;
    import actionScripts.ui.IContentWindow;
    import actionScripts.ui.IContentWindowReloadable;
    import actionScripts.ui.editor.text.DebugHighlightManager;
    import actionScripts.ui.editor.text.TextEditor;
    import actionScripts.ui.editor.text.vo.SearchResult;
    import actionScripts.ui.tabview.CloseTabEvent;
    import actionScripts.ui.tabview.TabEvent;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.valueObjects.URLDescriptorVO;
    
    import components.popup.FileSavePopup;
    import components.popup.SelectOpenedProject;
    import components.views.project.TreeView;

    public class BasicTextEditor extends Group implements IContentWindow, IFocusManagerComponent, IContentWindowReloadable
	{
		public var defaultLabel:String = "New";
		public var projectPath:String;
		public var editor:TextEditor;
		public var lastOpenType:String;
		
		protected var lastOpenedUpdatedInMoonshine:Date;
		protected var file:FileLocation;
		protected var created:Boolean;
		protected var loadingFile:Boolean;
		protected var tempScrollTo:int = -1;
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
			return editor.dataProvider;
		}
		public function set text(value:String):void
		{
			editor.dataProvider = value;
		}
		
		// Search may be RegExp or String
		public function search(search:*, backwards:Boolean=false):SearchResult
		{
			return editor.search(search, backwards);
		}
		
		// Search all instances and highlight
		// Preferably used in 'search in project' sequence
		public function searchAndShowAll(search:*):void
		{
			editor.searchAndShowAll(search);
		}
		
		// Search may be RegExp or String
		public function searchReplace(search:*, replace:String, all:Boolean=false):SearchResult
		{
			return editor.searchReplace(search, replace, all);
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
		
		protected function addedToStageHandler(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			this.addGlobalListeners();
		}
		
		protected function removedFromStageHandler(event:Event):void
		{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
			this.removeGlobalListeners();
		}
		
		protected function addGlobalListeners():void
		{
			dispatcher.addEventListener(CloseTabEvent.EVENT_CLOSE_TAB, closeTabHandler);
			dispatcher.addEventListener(TabEvent.EVENT_TAB_SELECT, tabSelectHandler);
		}
		
		protected function removeGlobalListeners():void
		{
			dispatcher.removeEventListener(CloseTabEvent.EVENT_CLOSE_TAB, closeTabHandler);
			dispatcher.removeEventListener(TabEvent.EVENT_TAB_SELECT, tabSelectHandler);
		}
		
		protected function closeTabHandler(event:CloseTabEvent):void
		{
		}
		
		protected function tabSelectHandler(event:TabEvent):void
		{
			if (event.child == this)
			{
				// check for any externally update
				checkFileIfChanged();
			}
		}
		
		protected function initializeChildrens():void
		{
			editor = new TextEditor(_readOnly);
			editor.percentHeight = 100;
			editor.percentWidth = 100;
			editor.addEventListener(ChangeEvent.TEXT_CHANGE, handleTextChange);
			text = "";
		}

		override public function setFocus():void
		{
			if (editor)
			{
				editor.hasFocus = true;
				editor.setFocus();
			}
		}

		override protected function createChildren():void
		{
			if (!isVisualEditor)
            {
				this.addElement(editor);
            }
			
			super.createChildren();
			
			// @note
			// https://github.com/prominic/Moonshine-IDE/issues/31
			// to ensure if the file has a pending debug/breakpoint call
			// call extended from OpenFileCommand/openFile(..)
			if (currentFile && currentFile.fileBridge.nativePath == DebugHighlightManager.NONOPENED_DEBUG_FILE_PATH)
			{
				editor.isNeedToBeTracedAfterOpening = true;
			}
		}

		protected function basicTextEditorCreationCompleteHandler(e:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, basicTextEditorCreationCompleteHandler);
			
			created = true;
			if (file)
				callLater(open, [file]);
		}

		public function scrollTo(line:int, eventType:String=null):void
		{
			if (loadingFile)
			{
				tempScrollTo = line;
			}
			else
			{
				editor.scrollTo(line, eventType);
				editor.selectLine(line);
			}
		}
		
		public function selectRangeAtLine(search:*, range:Object=null):void
		{
			editor.selectRangeAtLine(search, range);
		}
		
		public function setContent(content:String):void
		{
			editor.dataProvider = content;
			updateChangeStatus();
		}
		
		public function open(newFile:FileLocation, fileData:Object=null):void
		{
			loadingFile = true;
			file = newFile;
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
			if (!file.fileBridge.exists)
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
			scrollToTempValue();
		}

		protected function openHandler(event:Event):void
		{
			loadingFile = false;
			// Get data from file
			text = file.fileBridge.data.toString();

			scrollToTempValue();
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
				this.file = file;
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
						var projectReference:ProjectVO = tmpTreeView.getProjectBySelection();
						if (projectReference)
						{
							saveAsPath(projectReference.folderPath);
							return;
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
			this.file = file;
			dispatchEvent(new Event('labelChanged'));
			editor.save();
			updateChangeStatus();
			dispatcher.dispatchEvent(new SaveFileEvent(SaveFileEvent.FILE_SAVED, file, this));
		}
		
		protected function handleTextChange(event:ChangeEvent):void
		{
			if (editor.hasChanged != _isChanged)
			{
				updateChangeStatus();	
			}
		}
		
		protected function updateChangeStatus():void
		{
			_isChanged = editor.hasChanged;
			lastOpenedUpdatedInMoonshine = file.fileBridge.modificationDate;
			dispatchEvent(new Event('labelChanged'));
		}

		protected function handleSaveAsSelect(fileObj:Object):void
		{
			saveAs(new FileLocation(fileObj.nativePath));
		}

        private function scrollToTempValue():void
        {
            if (tempScrollTo > 0)
            {
                scrollTo(tempScrollTo, lastOpenType);
                tempScrollTo = -1;
            }
        }
    }
}