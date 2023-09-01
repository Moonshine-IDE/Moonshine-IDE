////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
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
	import actionScripts.interfaces.IVisualEditorProjectVO;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugins.ui.editor.VisualEditorViewer;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.FileWrapper;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.ResourceVO;
	import components.popup.DominoSharedColumnListPopup;
	import spark.components.TitleWindow;
	import view.VisualEditor;
	import view.interfaces.IVisualEditorLibraryBridge;
	
	import flash.events.MouseEvent;
	import actionScripts.plugin.templating.TemplatingPlugin;

	import mx.collections.ArrayList;
	import flash.events.Event;
	import flash.filesystem.File;
	import actionScripts.utils.TextUtil;
	import mx.controls.Alert;

	public class IVisualEditorLibraryBridgeImp implements IVisualEditorLibraryBridge
	{
		public var visualEditorProject:ProjectVO;
		
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var model:IDEModel = IDEModel.getInstance();
		private var updateHandler:Function;
		
		public function getXhtmlFileUpdates(updateHandler:Function=null):void
		{
			this.updateHandler = updateHandler;
			if (!(visualEditorProject as IVisualEditorProjectVO).filesList)
			{
				(visualEditorProject as IVisualEditorProjectVO).filesList = new ArrayCollection();
				UtilsCore.parseFilesList((visualEditorProject as IVisualEditorProjectVO).filesList, null, visualEditorProject as ProjectVO, ["xhtml"], true); // to be use in includes files list in primefaces
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
			var tmpOpenFile:FileLocation = new FileLocation(visualEditorProject.sourceFolder.fileBridge.nativePath + visualEditorProject.projectFile.fileBridge.separator + path);
			if (!tmpOpenFile) return;
			
			dispatcher.dispatchEvent(new OpenFileEvent(OpenFileEvent.OPEN_FILE, [tmpOpenFile]))
		}

		public function openDominoActionFile(path:String):void 
		{
			var tmpOpenFile:FileLocation = new FileLocation(path);
			if (!tmpOpenFile) return;
			dispatcher.dispatchEvent(new OpenFileEvent(OpenFileEvent.OPEN_FILE, [tmpOpenFile]))
		}

		public function openDominoSharedColumnFile(columnName:String):void 
		{
			var selectedProject:AS3ProjectVO=model.activeProject as AS3ProjectVO;
			if(selectedProject&&selectedProject.sourceFolder){
				var shareColumnFileName:String=TextUtil.fixDominoViewName(columnName);
				var formFolder:String=selectedProject.sourceFolder.fileBridge.nativePath;
				var parentPath:String=formFolder.substring(0,formFolder.length-5);
				var shareColumnFilePath:String=parentPath+"SharedElements"+File.separator+"Columns"+File.separator+shareColumnFileName+".column";
				//Alert.show("shareColumnFilePath:"+shareColumnFilePath);
				var tmpOpenFile:FileLocation = new FileLocation(shareColumnFilePath);
				if (!tmpOpenFile) return;
				var openFileEvent:OpenFileEvent=new OpenFileEvent(OpenFileEvent.OPEN_FILE, [tmpOpenFile]);
				openFileEvent.openAsTourDe=false;
				dispatcher.dispatchEvent(openFileEvent)
			}
			
		}
		
		public function getVisualEditorComponent():VisualEditor
		{
			if(model==null){ 
				
			}else{
				var editor:VisualEditorViewer = model.activeEditor as VisualEditorViewer;
				if (editor) return editor.editorView.visualEditor;
			}
			
			return null;
		}
		
		public function getCustomTooltipFunction():Function
		{
			return UtilsCore.createCustomToolTip;	
		}
		
		public function getPositionTooltipFunction():Function
		{
			return UtilsCore.positionTip;
		}

        public function getRelativeFilePath():String
        {
            var editor:VisualEditorViewer = model.activeEditor as VisualEditorViewer;
            if (!editor) return "";

            return editor.currentFile.fileBridge.getRelativePath(visualEditorProject.sourceFolder, true);
        }

		public function openCreateDominoActionPanel(event:MouseEvent):void
        {
			var templaetPulgin:TemplatingPlugin=new TemplatingPlugin();

            templaetPulgin.openDominoActionComponentTypeChoose(event);
        }

		//Copy& Past from Visual editor need update the status for it;

		public function updateCurrentVisualEditorStatus():void{
			var editor:VisualEditorViewer = model.activeEditor as VisualEditorViewer;
			if(editor!=null){
				editor.editorView.visualEditor.editingSurface.hasChanged=true;
				editor.editorView.visualEditor.dispatchEvent(new Event('labelChanged'));
			}
		}

		//getDominoActionList

		public function getDominoActionList():ArrayList
        {              
			var editor:VisualEditorViewer = model.activeEditor as VisualEditorViewer;
			if (!editor) return null;
			return editor.getDominoActionList();

		}

		public function getDominoShareFieldList():ArrayList
        {              
			var editor:VisualEditorViewer = model.activeEditor as VisualEditorViewer;
			if (!editor) return null;
			return editor.getDominoShareFieldList();

		}

		

		private function onNewFileAdded(event:TreeMenuItemEvent):void
		{
			// add resource only relative to the project
			if (event.data.projectReference.path == visualEditorProject.projectFolder.nativePath)
			{
				// make sure we use existing object only and not create new
				var newFileWrapper:FileWrapper = UtilsCore.findFileWrapperAgainstFileLocation(event.data, (event.extra as FileLocation));
				if (newFileWrapper)
				{
					(visualEditorProject as IVisualEditorProjectVO).filesList.addItem(new ResourceVO((event.extra as FileLocation).name, newFileWrapper));
					sendXHtmlUpdates();
				}
			}
		}
		
		private function onFileRemoved(event:TreeMenuItemEvent):void
		{
			// remove resource only relative to the project
			if (event.data.projectReference.path == visualEditorProject.projectFolder.nativePath)
			{
				var pathSeparator:String = event.data.file.fileBridge.separator;
				var filesList:ArrayCollection = (visualEditorProject as IVisualEditorProjectVO).filesList;
				for (var i:int=0; i < filesList.length; i ++)
				{
					// direct == path check or
					// path check if the xhtml file is children of deleted file/folder
					if (event.data.file.fileBridge.nativePath == filesList[i].sourceWrapper.file.fileBridge.nativePath)
					{
						filesList.removeItemAt(i);
						break;
					}
					else if (filesList[i].sourceWrapper.file.fileBridge.nativePath.indexOf(event.data.file.fileBridge.nativePath + pathSeparator) != -1)
					{
						filesList.removeItemAt(i);
						i--;
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
				var filesList:ArrayCollection = (visualEditorProject as IVisualEditorProjectVO).filesList;
				for each (var i:ResourceVO in filesList)
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
			this.updateHandler((visualEditorProject as IVisualEditorProjectVO).filesList);
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

		public function getDominoSharedColumnListPopup(file:File):TitleWindow
        {
            var tmpPopup:DominoSharedColumnListPopup = new DominoSharedColumnListPopup();
            tmpPopup.initializeColumnList(file);
            return tmpPopup as TitleWindow;
        }
	}
}