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
	import actionScripts.controllers.DataAgent;
	import actionScripts.events.ChangeEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.RefreshTreeEvent;
	import actionScripts.events.SaveFileEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.ui.IContentWindow;
	import actionScripts.ui.editor.text.TextEditor;
	import actionScripts.ui.editor.text.vo.SearchResult;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.URLDescriptorVO;
	
	import components.popup.FileSavePopup;
	import components.popup.SelectOpenedFlexProject;
	import components.views.project.TreeView;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.containers.Canvas;
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	import mx.managers.IFocusManagerComponent;
	import mx.managers.PopUpManager;
	
	public class BasicTextEditor extends Canvas implements IContentWindow, IFocusManagerComponent
	{
		public var defaultLabel:String = "New";
		
		public var editor:TextEditor;
		protected var file:FileLocation;
		protected var created:Boolean = false;
		protected var loadingFile:Boolean = false;
		protected var tempScrollTo:int = -1;
		protected var _isChanged:Boolean;
		protected var tempSaveAs: FileLocation;
		protected var loader: DataAgent;

		private var pop:FileSavePopup;
		private var path:String;
		private var textData:String;
		protected var model:IDEModel = IDEModel.getInstance();
		private var selectProjectPopup:SelectOpenedFlexProject;
		
		override public function get label():String
		{
			var ch:String = (_isChanged) ? "*":"";
			if (!file)
				return ch+defaultLabel;
			return ch + file.fileBridge.name;
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

		public function get text():String
		{
			return editor.dataProvider;
		}

		public function set text(v:String):void
		{
			editor.dataProvider = v;
		}
		
		// Search may be RegExp or String
		public function search(search:*, backwards:Boolean=false):SearchResult
		{
			return editor.search(search, backwards);
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

		public function BasicTextEditor()
		{
			super();
			
			percentHeight = 100;
			percentWidth = 100;
			addEventListener(FlexEvent.CREATION_COMPLETE, createdHandler);
			initializeChildrens();
		}
		
		protected function initializeChildrens():void
		{
			editor = new TextEditor();
			editor.percentHeight = 100;
			editor.percentWidth = 100;
			editor.addEventListener(ChangeEvent.TEXT_CHANGE, handleTextChange);
			text = "";
		}

		override public function setFocus():void
		{
			if (editor)
				editor.setFocus();
		}

		override protected function createChildren():void
		{
			addChild(editor);
			super.createChildren();
		}

		protected function createdHandler(e:Event):void
		{
			created = true;
			if (file)
				callLater(open, [file]);
		}

		public function scrollTo(line:int):void
		{
			if (loadingFile)
			{
				tempScrollTo = line;
			}
			else
			{
				editor.scrollTo(line);
				editor.selectLine(line);
			}
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
		
		protected function openFileAsStringHandler(data:String):void
		{
			loadingFile = false;
			// Get data from file
			text = data;
			if (tempScrollTo > 0)
			{
				scrollTo(tempScrollTo);
				tempScrollTo = -1;
			}
		}

		protected function openHandler(event:Event):void
		{
			loadingFile = false;
			// Get data from file
			text = file.fileBridge.data.toString();
			
			if (tempScrollTo > 0)
			{
				scrollTo(tempScrollTo);
				tempScrollTo = -1;
			}
			
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
				GlobalEventDispatcher.getInstance().dispatchEvent(
					new SaveFileEvent(SaveFileEvent.FILE_SAVED, file, this)
				);
			}
			else if (ConstantsCoreVO.IS_AIR)
			{
				file.fileBridge.save(text);
				editor.save();
				updateChangeStatus();
				
				// Tell the world we've changed
				GlobalEventDispatcher.getInstance().dispatchEvent(
					new SaveFileEvent(SaveFileEvent.FILE_SAVED, file, this)
				);
			}
			else if (!ConstantsCoreVO.IS_AIR)
			{
				GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleOutputEvent(file.fileBridge.name +": Saving in process..."));
				loader = new DataAgent(URLDescriptorVO.FILE_MODIFY, onSaveSuccess, onSaveFault, {path:file.fileBridge.nativePath,text:text});				
			}
		}
		
		private function onSaveFault(message:String):void
		{
			//Alert.show("Save Fault"+message);
			GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleOutputEvent(file.fileBridge.name +": Save error!"));
			loader = null;
		}
		
		private function onSaveSuccess(value:Object, message:String=null):void
		{
			//Alert.show("Save Fault"+message);
			loader = null;
			editor.save();
			updateChangeStatus();
			GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleOutputEvent(file.fileBridge.name +": Saving successful."));
			GlobalEventDispatcher.getInstance().dispatchEvent(
				new SaveFileEvent(SaveFileEvent.FILE_SAVED, file, this)
			);
		}
 
		public function saveAs(file:FileLocation=null):void
		{
			if (file)
			{
				this.file = file;
				save();
				// Update labels
				dispatchEvent(new Event('labelChanged'));
				GlobalEventDispatcher.getInstance().dispatchEvent(new RefreshTreeEvent(file));
			    return;
			}
			
			if (ConstantsCoreVO.IS_AIR)
			{ 
				if(this.file)
					saveAsPath(this.file.fileBridge.parent.fileBridge.nativePath)
				else if (model.projects.length > 1 )
				{
					if (model.mainView.isProjectViewAdded)
					{
						var tmpTreeView:TreeView = model.mainView.getTreeViewPanel();
						var projectReference:AS3ProjectVO = tmpTreeView.getProjectBySelection();
						if (projectReference)
						{
							saveAsPath(projectReference.folderPath);
							return;
						}
					}
					selectProjectPopup = new SelectOpenedFlexProject();
					PopUpManager.addPopUp(selectProjectPopup, FlexGlobals.topLevelApplication as DisplayObject, false);
					PopUpManager.centerPopUp(selectProjectPopup);
					selectProjectPopup.addEventListener(SelectOpenedFlexProject.PROJECT_SELECTED, onProjectSelected);
					selectProjectPopup.addEventListener(SelectOpenedFlexProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
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
				tempSaveAs = new FileLocation( path );
				tempSaveAs.fileBridge.browseForSave(handleSaveAsSelect, removeTempSaveAs, "Save As");
			}
			function onProjectSelected(event:Event):void
			{
				saveAsPath((selectProjectPopup.selectedProject as AS3ProjectVO).folderPath );
				onProjectSelectionCancelled(null);
			}
			function onProjectSelectionCancelled(event:Event):void
			{
				selectProjectPopup.removeEventListener(SelectOpenedFlexProject.PROJECT_SELECTED, onProjectSelected);
				selectProjectPopup.removeEventListener(SelectOpenedFlexProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
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
			GlobalEventDispatcher.getInstance().dispatchEvent(
				new SaveFileEvent(SaveFileEvent.FILE_SAVED, file, this)
			);
		}
		
		protected function handleTextChange(event:ChangeEvent):void
		{
			if (editor.hasChanged != _isChanged)
			{
				updateChangeStatus();	
			}
		}
		
		private function updateChangeStatus():void
		{
			_isChanged = editor.hasChanged;
			dispatchEvent(new Event('labelChanged'));
		}

		protected function handleSaveAsSelect(event:Event):void
		{
			saveAs(tempSaveAs);
			removeTempSaveAs(event);
		}

		protected function removeTempSaveAs(event:Event):void
		{
			tempSaveAs.fileBridge.getFile.removeEventListener(Event.SELECT, handleSaveAsSelect);
			tempSaveAs.fileBridge.getFile.removeEventListener(Event.CANCEL, removeTempSaveAs);
			tempSaveAs = null;
		}

	}
}