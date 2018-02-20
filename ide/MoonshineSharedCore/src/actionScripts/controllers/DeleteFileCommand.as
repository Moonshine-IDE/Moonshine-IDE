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
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;

    import flash.events.Event;
	
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
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.FileWrapper;
	import actionScripts.valueObjects.ProjectReferenceVO;

	public class DeleteFileCommand implements ICommand
	{
		private var file: FileLocation;
		private var wrapper: FileWrapper;
		private var treeViewHandler: Function;
		
		public function execute(event:Event):void
		{
			var deleteEvent:DeleteFileEvent = DeleteFileEvent(event);
			var tab:IContentWindow;
			var ed:BasicTextEditor;
			
			if (!deleteEvent.file.fileBridge.exists) return;
			
			// project deletion
			if (deleteEvent.wrapper.isRoot && deleteEvent.showAlert)
			{
				Alert.show("Are you sure you want to delete project '"+ deleteEvent.wrapper.name +"'?", "Confirm", Alert.YES | Alert.NO, null, onProjectDeleteConfirm);
				return;
			}
			else if (deleteEvent.wrapper.isRoot)
			{
				onProjectDeleteConfirm(null);
				return;
			}
			
			// file/folder deletion for desktop
			if (ConstantsCoreVO.IS_AIR)
			{
				if (deleteEvent.file.fileBridge.isDirectory)
				{
					deleteEvent.file.fileBridge.deleteDirectory(true);
                }
				else
				{
					deleteEvent.file.fileBridge.deleteFile();

                    if (deleteEvent.projectAssociatedWithFile)
                    {
                        var as3ProjectVO:AS3ProjectVO = deleteEvent.projectAssociatedWithFile as AS3ProjectVO;
                        if (as3ProjectVO && as3ProjectVO.isVisualEditorProject)
                        {
                            var fileName:String = deleteEvent.file.name.replace(/.mxml$|.xhtml$/, ".xml");
                            var visualEditorFile:FileLocation = as3ProjectVO.visualEditorSourceFolder.resolvePath(fileName);
                            visualEditorFile.fileBridge.deleteFile();
                        }
                    }
                }

				if (deleteEvent.wrapper.sourceController)
				{
					deleteEvent.wrapper.sourceController.remove(deleteEvent.file);
                }
				
				for each (tab in IDEModel.getInstance().editors)
				{
					ed = tab as BasicTextEditor;
					if (ed 
						&& ed.currentFile
						&& ed.currentFile.fileBridge.nativePath == deleteEvent.file.fileBridge.nativePath)
					{
						GlobalEventDispatcher.getInstance().dispatchEvent(
							new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, ed, true)
						);
					}
				}
				
				// removing the wrapper in tree view
				deleteEvent.wrapper.isDeleting = true;
				deleteEvent.treeViewCompletionHandler(deleteEvent.wrapper);
			}
				// for web
			else
			{
				file = deleteEvent.file;
				treeViewHandler = deleteEvent.treeViewCompletionHandler;
				wrapper = deleteEvent.wrapper;
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

					var projectRef:ProjectReferenceVO = deleteEvent.wrapper.projectReference;
                    SharedObjectUtil.removeCookieByName("projectFiles" + projectRef.name);
                    SharedObjectUtil.removeProjectTreeItemFromOpenedItems(
                            {name: projectRef.name, path: projectRef.path}, "name", "path");
					
					// removal from the recently opened project in splash screen
					var toRemove:int = -1;
					for each (var file:Object in model.recentlyOpenedProjects)
					{
						if (file.path == deleteEvent.wrapper.file.fileBridge.nativePath)
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
					
					// removal from the recently opened files in splash screen
					// Find item & remove it if already present (path-based, since it's two different File objects)
					toRemove = -1;
					for (var i:int = 0; i < model.recentlyOpenedFiles.length; i++)
					{
						if (model.recentlyOpenedFiles[i].path.indexOf(deleteEvent.wrapper.file.fileBridge.nativePath + deleteEvent.wrapper.file.fileBridge.separator) != -1)
						{
							model.recentlyOpenedFiles.removeItemAt(i);
							toRemove = 0;
							i--;
						}
					}
					
					if (toRemove != -1) GlobalEventDispatcher.getInstance().dispatchEvent(new Event(RecentlyOpenedPlugin.RECENT_FILES_LIST_UPDATED));
					
					// finally
					model.flexCore.deleteProject(deleteEvent.wrapper, deleteEvent.treeViewCompletionHandler);
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