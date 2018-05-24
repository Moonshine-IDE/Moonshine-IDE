////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.impls
{
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.events.TreeMenuItemEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugins.ui.editor.VisualEditorViewer;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.ResourceVO;
	
	import view.VisualEditor;
	import view.interfaces.IVisualEditorLibraryBridge;
	
	public class IVisualEditorLibraryBridgeImp implements IVisualEditorLibraryBridge
	{
		public var visualEditorProject:AS3ProjectVO;
		
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var model:IDEModel = IDEModel.getInstance();
		private var updateHandler:Function;
		
		public function getXhtmlFileUpdates(updateHandler:Function=null):void
		{
			this.updateHandler = updateHandler;
			if (!visualEditorProject.filesList)
			{
				visualEditorProject.filesList = new ArrayCollection();
				UtilsCore.parseFilesList(visualEditorProject.filesList, visualEditorProject as ProjectVO, ["xhtml"]); // to be use in includes files list in primefaces
				dispatcher.addEventListener(TreeMenuItemEvent.NEW_FILE_CREATED, onNewFileAdded, false, 0, true);
				dispatcher.addEventListener(TreeMenuItemEvent.FILE_DELETED, onFileRemoved, false, 0, true);
				dispatcher.addEventListener(TreeMenuItemEvent.FILE_RENAMED, onFileRenamed, false, 0, true);
				
				// remove footprint when project is removed
				model.projects.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleEditorChange, false, 0, true);
			}
			
			sendXHtmlUpdates();
		}
		
		public function openXhtmlFile(path:String):void
		{
			var tmpOpenFile:FileLocation = new FileLocation(visualEditorProject.folderLocation.fileBridge.parent.fileBridge.nativePath + visualEditorProject.projectFile.fileBridge.separator + path);
			if (!tmpOpenFile) return;
			
			dispatcher.dispatchEvent(
				new OpenFileEvent(OpenFileEvent.OPEN_FILE, tmpOpenFile)
			);
		}
		
		public function getVisualEditorComponent():VisualEditor
		{
			var editor:VisualEditorViewer = model.activeEditor as VisualEditorViewer;
			if (editor) return editor.editorView.visualEditor;
			
			return null;
		}
		
		private function onNewFileAdded(event:TreeMenuItemEvent):void
		{
			// add resource only relative to the project
			if (event.data.projectReference.path == visualEditorProject.projectFolder.nativePath)
			{
				visualEditorProject.filesList.addItem(new ResourceVO(FileLocation(event.extra).name, event.data));
				sendXHtmlUpdates();
			}
		}
		
		private function onFileRemoved(event:TreeMenuItemEvent):void
		{
			// remove resource only relative to the project
			if (event.data.projectReference.path == visualEditorProject.projectFolder.nativePath)
			{
				for each (var i:ResourceVO in visualEditorProject.filesList)
				{
					if (event.data.file.fileBridge.nativePath == i.sourceWrapper.file.fileBridge.nativePath)
					{
						visualEditorProject.filesList.removeItem(i);
						break;
					}
				}
				sendXHtmlUpdates();
			}
		}
		
		private function onFileRenamed(event:TreeMenuItemEvent):void
		{
			// remove resource only relative to the project
			if (event.data.projectReference.path == visualEditorProject.projectFolder.nativePath)
			{
				for each (var i:ResourceVO in visualEditorProject.filesList)
				{
					if (event.data.file.fileBridge.nativePath == i.sourceWrapper.file.fileBridge.nativePath)
					{
						i.name = event.data.name;
						i.resourcePath = event.data.nativePath;
						break;
					}
				}
				sendXHtmlUpdates();
			}
		}
		
		private function sendXHtmlUpdates():void
		{
			this.updateHandler(visualEditorProject.filesList);
		}
		
		protected function handleEditorChange(event:CollectionEvent):void
		{
			if (event.kind == CollectionEventKind.REMOVE && (AS3ProjectVO(event.items[0]).folderPath == visualEditorProject.folderPath))
			{
				model.projects.removeEventListener(CollectionEvent.COLLECTION_CHANGE, handleEditorChange);
				dispatcher.removeEventListener(TreeMenuItemEvent.NEW_FILE_CREATED, onNewFileAdded);
				dispatcher.removeEventListener(TreeMenuItemEvent.FILE_DELETED, onFileRemoved);
				dispatcher.removeEventListener(TreeMenuItemEvent.FILE_RENAMED, onFileRenamed);
				
				this.updateHandler = null;
			}
		}
	}
}