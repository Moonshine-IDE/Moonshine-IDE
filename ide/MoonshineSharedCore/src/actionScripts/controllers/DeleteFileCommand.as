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
package actionScripts.controllers
{
import flash.events.Event;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import mx.controls.Alert;
import mx.events.CloseEvent;

import actionScripts.events.DeleteFileEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.recentlyOpened.RecentlyOpenedPlugin;
import actionScripts.ui.IContentWindow;
import actionScripts.ui.editor.BasicTextEditor;
import actionScripts.ui.tabview.CloseTabEvent;
import actionScripts.utils.SharedObjectUtil;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.FileWrapper;
import actionScripts.valueObjects.ProjectReferenceVO;

import components.views.splashscreen.SplashScreen;
	
	public class DeleteFileCommand implements ICommand
	{
		private var file: FileLocation;
		private var wrapper: FileWrapper;
		private var treeViewHandler: Function;
		
		public function execute(event:Event):void
		{
			var e:DeleteFileEvent = DeleteFileEvent(event);
			var tab:IContentWindow;
			var ed:BasicTextEditor;
			
			if (!e.file.fileBridge.exists) return;
			
			// project deletion
			if (e.wrapper.isRoot && e.showAlert)
			{
				Alert.show("Are you sure you want to delete project '"+ e.wrapper.name +"'?", "Confirm", Alert.YES | Alert.NO, null, onProjectDeleteConfirm);
				return;
			}
			else if (e.wrapper.isRoot)
			{
				onProjectDeleteConfirm(null);
				return;
			}
			
			// file/folder deletion for desktop
			if (ConstantsCoreVO.IS_AIR)
			{
				if (e.file.fileBridge.isDirectory) e.file.fileBridge.deleteDirectory(true);
				else e.file.fileBridge.deleteFile();
				if (e.wrapper.sourceController) e.wrapper.sourceController.remove(e.file);
				
				for each (tab in IDEModel.getInstance().editors)
				{
					ed = tab as BasicTextEditor;
					if (ed 
						&& ed.currentFile
						&& ed.currentFile.fileBridge.nativePath == e.file.fileBridge.nativePath)
					{
						GlobalEventDispatcher.getInstance().dispatchEvent(
							new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, ed, true)
						);
					}
				}
				
				// removing the wrapper in tree view
				e.wrapper.isDeleting = true;
				e.treeViewCompletionHandler(e.wrapper);
			}
				// for web
			else
			{
				file = e.file;
				treeViewHandler = e.treeViewCompletionHandler;
				wrapper = e.wrapper;
				wrapper.isWorking = true;
				wrapper.isDeleting = true;
				
				file.addEventListener(Event.COMPLETE, onFileDeleted);
				file.addEventListener(Event.CLOSE, onDeleteFault);
				file.deleteFileOrDirectory();
			}
			
			/*
			* @local
			* to access method chain parameters
			*/
			function onProjectDeleteConfirm(event:CloseEvent):void
			{
				if (!event || event.detail == Alert.YES)
				{
					var model: IDEModel = IDEModel.getInstance();
					// sends delete call to factory classes

					var projectRef:ProjectReferenceVO = e.wrapper.projectReference;
                    SharedObjectUtil.removeCookieByName("projectFiles" + projectRef.name);
                    SharedObjectUtil.removeProjectTreeItemFromOpenedItems(
                            {name: projectRef.name, path: projectRef.path}, "name", "path");
					
					// removal from the recently opened project in splash screen
					var toRemove:int = -1;
					for each (var file:Object in model.recentlyOpenedProjects)
					{
						if (file.path == e.wrapper.file.fileBridge.nativePath)
						{
							toRemove = model.recentlyOpenedProjects.getItemIndex(file);
							break;
						}
					}
					if (toRemove != -1) 
					{
						model.recentlyOpenedProjects.removeItemAt(toRemove);
						model.recentlyOpenedProjectOpenedOption.removeItemAt(toRemove);
						GlobalEventDispatcher.getInstance().dispatchEvent(new Event(RecentlyOpenedPlugin.RECENT_PROJECT_LIST_UPDATED));
					}

					model.flexCore.deleteProject(e.wrapper, e.treeViewCompletionHandler);
				}
			}
		}
		
		private function onFileDeleted(event:Event):void
		{
			for each (var tab:IContentWindow in IDEModel.getInstance().editors)
			{
				var ed:BasicTextEditor = tab as BasicTextEditor;
				if (ed 
					&& ed.currentFile
					&& ed.currentFile.fileBridge.nativePath == file.fileBridge.nativePath)
				{
					GlobalEventDispatcher.getInstance().dispatchEvent(
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