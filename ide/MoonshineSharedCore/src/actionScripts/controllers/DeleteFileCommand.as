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
package actionScripts.controllers
{
    import actionScripts.events.RefreshTreeEvent;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import actionScripts.events.DeleteFileEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.recentlyOpened.RecentlyOpenedPlugin;
	import actionScripts.ui.IContentWindow;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.utils.SharedObjectUtil;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.FileWrapper;
	import actionScripts.valueObjects.ProjectReferenceVO;
	import actionScripts.valueObjects.ProjectVO;
	
	import components.popup.ProjectDeletionPopup;


	public class DeleteFileCommand implements ICommand
	{
		private var file: FileLocation;
		private var wrapper: FileWrapper;
		private var treeViewHandler: Function;
		private var projectDeletePopup:ProjectDeletionPopup;
		private var thisEvent:DeleteFileEvent;
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var pendingDeletionProjectsDict:Dictionary = new Dictionary();
		private var model:IDEModel = IDEModel.getInstance();

		public function execute(event:Event):void
		{
			thisEvent = DeleteFileEvent(event);
			
			var tab:IContentWindow;
			var ed:BasicTextEditor;
			
			// project deletion
			if (thisEvent.wrappers[0].isRoot && thisEvent.showAlert)
			{
				if (!projectDeletePopup)
				{
					projectDeletePopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, ProjectDeletionPopup, true) as ProjectDeletionPopup;
					projectDeletePopup.wrapperBelongToProject = thisEvent.wrappers[0];
					projectDeletePopup.addEventListener(DeleteFileEvent.EVENT_DELETE_FILE, onProjectDeletionConfirmed);
					projectDeletePopup.addEventListener(CloseEvent.CLOSE, onProjectDeletePopupClosed);
					PopUpManager.centerPopUp(projectDeletePopup);
				}
				return;
			}
			else if (thisEvent.wrappers[0].isRoot)
			{
				// this generally when deleting a template project
				// ideally, deleting a normal project without above prompting
				// not going to happen
				onProjectDeletionConfirmed(thisEvent);
				return;
			}
			
			// file/folder deletion for desktop
			if (ConstantsCoreVO.IS_AIR)
			{
				for each (var fw:FileWrapper in thisEvent.wrappers)
				{
					onFileDeletionConfirmed(fw);
				}
				
				thisEvent.treeViewCompletionHandler(thisEvent.wrappers);
			}
			// for web
			else
			{
				file = thisEvent.file;
				treeViewHandler = thisEvent.treeViewCompletionHandler;
				wrapper = thisEvent.wrappers[0];
				wrapper.isWorking = true;
				wrapper.isDeleting = true;
				
				file.addEventListener(Event.COMPLETE, onFileDeleted);
				file.addEventListener(Event.CLOSE, onDeleteFault);
				file.deleteFileOrDirectory();
			}
		}
		
		private function onFileDeletionConfirmed(fw:FileWrapper):void
		{
			var project:ProjectVO = UtilsCore.getProjectFromProjectFolder(fw);
			var veSourceFile:FileLocation = null;
			var tab:IContentWindow;
			var ed:BasicTextEditor;
			
			project.projectFileDelete(fw);
			
			if (fw.file.fileBridge.isDirectory)
			{
				if (fw.file.fileBridge.exists) fw.file.fileBridge.deleteDirectory(true);
				
				veSourceFile = UtilsCore.getVisualEditorSourceFile(fw);
				if (veSourceFile && veSourceFile.fileBridge.exists)
				{
					veSourceFile.fileBridge.deleteDirectory(true);
				}
			}
			else
			{
				if (fw.file.fileBridge.exists) fw.file.fileBridge.deleteFile();
				
				veSourceFile = UtilsCore.getVisualEditorSourceFile(fw);
				if (veSourceFile && veSourceFile.fileBridge.exists)
				{
					veSourceFile.fileBridge.deleteFile();
					if (model.showHiddenPaths)
					{
						var fileForRefresh:FileLocation = veSourceFile;
						if (!veSourceFile.fileBridge.isDirectory)
						{
							fileForRefresh = veSourceFile.fileBridge.parent;
						}
						dispatcher.dispatchEvent(new RefreshTreeEvent(fileForRefresh));
					}
				}

				//remove the view ,if the file is form
				removeSimpleView(fw.file,project);
			}
			
			if (fw.sourceController)
			{
				fw.sourceController.remove(fw.file);
			}
			
			for each (tab in model.editors)
			{
				ed = tab as BasicTextEditor;
				if (ed 
					&& ed.currentFile
					&& (ed.currentFile.fileBridge.nativePath == fw.file.fileBridge.nativePath || 
						(ed.currentFile.fileBridge.nativePath.indexOf(fw.file.fileBridge.nativePath + fw.file.fileBridge.separator) != -1)))
				{
					dispatcher.dispatchEvent(
						new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, ed, true)
					);
				}
			}
			
			// removing the wrapper in tree view
			fw.isDeleting = true;
		}

		//we need remove the simple view after the form remove 
		private function removeSimpleView(removeFile:FileLocation,visualEditorProject:ProjectVO):void{
			var pathSeparator:String = removeFile.fileBridge.separator;
			if(removeFile.fileBridge.extension=="form"){
				var formName:String = removeFile.fileBridge.nameWithoutExtension;
				//folderLocation
				var viewPathFileLocation:FileLocation =new FileLocation(visualEditorProject.folderLocation.fileBridge.nativePath+pathSeparator+"nsfs"+pathSeparator+"nsf-moonshine"+pathSeparator+"odp"+pathSeparator+"Views"+pathSeparator+"All By UNID_5cCRUD_5c"+formName+".view");
				if(viewPathFileLocation.fileBridge.exists){
					viewPathFileLocation.fileBridge.deleteFile()
				}


			}
		}

		private function onProjectDeletionConfirmed(event:DeleteFileEvent):void
		{
			var project:ProjectVO = UtilsCore.getProjectFromProjectFolder(event.wrappers[0]);
			// sends delete call to factory classes
			
			var projectRef:ProjectReferenceVO = event.wrappers[0].projectReference;
			SharedObjectUtil.removeCookieByName("projectFiles" + projectRef.name);
			SharedObjectUtil.removeProjectTreeItemFromOpenedItems(
				{name: projectRef.name, path: projectRef.path}, "name", "path");
			
			// removal from the recently opened project in splash screen
			var toRemove:int = -1;
			for each (var file:Object in model.recentlyOpenedProjects)
			{
				if (file.path == event.wrappers[0].file.fileBridge.nativePath)
				{
					toRemove = model.recentlyOpenedProjects.getItemIndex(file);
					break;
				}
			}
			if (toRemove != -1) 
			{
				model.recentlyOpenedProjects.removeItemAt(toRemove);
				model.recentlyOpenedProjectOpenedOption.removeItemAt(toRemove);
				dispatcher.dispatchEvent(new Event(RecentlyOpenedPlugin.RECENT_PROJECT_LIST_UPDATED));
			}
			
			// removal from the recently opened files in splash screen
			// Find item & remove it if already present (path-based, since it's two different File objects)
			toRemove = -1;
			for (var i:int = 0; i < model.recentlyOpenedFiles.length; i++)
			{
				if (model.recentlyOpenedFiles[i].path.indexOf(event.wrappers[0].file.fileBridge.nativePath + event.wrappers[0].file.fileBridge.separator) != -1)
				{
					model.recentlyOpenedFiles.removeItemAt(i);
					toRemove = 0;
					i--;
				}
			}
			
			if (toRemove != -1) dispatcher.dispatchEvent(new Event(RecentlyOpenedPlugin.RECENT_FILES_LIST_UPDATED));
			
			// preparing to close the language-server against the project
			// and listen for its complete shutdown event
			// @note 
			// visual editor project do not use language server
			if (model.languageServerCore.hasLanguageServerForProject(project) && (!(project is AS3ProjectVO) || !(project as AS3ProjectVO).isVisualEditorProject))
			{
				// keep the files collection in a dictionary so we can select between multiple
				// project deletion calls - as language server shutdown event returns after some delay
				pendingDeletionProjectsDict[event.wrappers[0].projectReference] = event.wrappers[0];
				
				dispatcher.addEventListener(ProjectEvent.LANGUAGE_SERVER_CLOSED, onProjectLanguageServerClosed, false, 0, true);
				dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.REMOVE_PROJECT, project));
			}
			else
			{
				// when no language server present or not setup
				dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.REMOVE_PROJECT, project));
				model.flexCore.deleteProject(event.wrappers[0], thisEvent.treeViewCompletionHandler, false);
			}
		}
		
		private function onProjectLanguageServerClosed(event:ProjectEvent):void
		{
			if (pendingDeletionProjectsDict[event.project.projectFolder.projectReference] != undefined)
			{
				dispatcher.removeEventListener(ProjectEvent.LANGUAGE_SERVER_CLOSED, onProjectLanguageServerClosed);
				model.flexCore.deleteProject(pendingDeletionProjectsDict[event.project.projectFolder.projectReference], thisEvent.treeViewCompletionHandler, false);
				delete pendingDeletionProjectsDict[event.project.projectFolder.projectReference];
			}
		}
		
		private function onProjectDeletePopupClosed(event:CloseEvent):void
		{
			projectDeletePopup.removeEventListener(DeleteFileEvent.EVENT_DELETE_FILE, onProjectDeletionConfirmed);
			projectDeletePopup.removeEventListener(CloseEvent.CLOSE, onProjectDeletePopupClosed);
			projectDeletePopup = null;
		}
		
		private function onFileDeleted(event:Event):void
		{
			for each (var tab:IContentWindow in model.editors)
			{
				var ed:BasicTextEditor = tab as BasicTextEditor;
				if (ed 
					&& ed.currentFile
					&& ed.currentFile.fileBridge.nativePath == file.fileBridge.nativePath)
				{
					dispatcher.dispatchEvent(
						new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, ed, true)
					);
				}
			}
			
			// remove footprints
			wrapper.isDeleting = false;
			wrapper.isWorking = false;
			treeViewHandler(wrapper);
			dispose();
		}
		
		private function onDeleteFault(event:Event):void
		{
			wrapper.isDeleting = false;
			wrapper.isWorking = false;
			treeViewHandler(null);
			dispose();
		}
		
		private function dispose():void
		{
			file.removeEventListener(Event.COMPLETE, onFileDeleted);
			file.removeEventListener(Event.CLOSE, onDeleteFault);
			file = null;
			treeViewHandler = null;
			wrapper = null;
		}
	}
}