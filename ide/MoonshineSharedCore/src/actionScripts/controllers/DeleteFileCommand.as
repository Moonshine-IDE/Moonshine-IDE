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
		
		public function execute(event:Event):void
		{
			thisEvent = DeleteFileEvent(event);
			
			var tab:IContentWindow;
			var ed:BasicTextEditor;
			
			if (!thisEvent.file.fileBridge.exists) 
			{
				thisEvent.wrapper.isWorking = false;
				thisEvent.wrapper.isDeleting = true;
				thisEvent.treeViewCompletionHandler(thisEvent.wrapper);
				return;
			}
			
			// project deletion
			if (thisEvent.wrapper.isRoot && thisEvent.showAlert)
			{
				if (!projectDeletePopup)
				{
					projectDeletePopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, ProjectDeletionPopup, true) as ProjectDeletionPopup;
					projectDeletePopup.wrapperBelongToProject = thisEvent.wrapper;
					projectDeletePopup.addEventListener(DeleteFileEvent.EVENT_DELETE_FILE, onProjectDeletionConfirmed);
					projectDeletePopup.addEventListener(CloseEvent.CLOSE, onProjectDeletePopupClosed);
					PopUpManager.centerPopUp(projectDeletePopup);
				}
				return;
			}
			else if (thisEvent.wrapper.isRoot)
			{
				// this generally when deleting a template project
				// ideally, deleting a normal project without above prompting
				// not going to happen
				onProjectDeletionConfirmed(thisEvent, true);
				return;
			}
			
			// file/folder deletion for desktop
			if (ConstantsCoreVO.IS_AIR)
			{
                var veSourceFile:FileLocation = null;
				if (thisEvent.file.fileBridge.isDirectory)
				{
					thisEvent.file.fileBridge.deleteDirectory(true);

                    veSourceFile = getVisualEditorSourceFile();
                    if (veSourceFile && veSourceFile.fileBridge.exists)
                    {
                        veSourceFile.fileBridge.deleteDirectory(true);
                    }
                }
            	else
                {
                    thisEvent.file.fileBridge.deleteFile();

                    if (thisEvent.projectAssociatedWithFile)
                    {
                        veSourceFile = getVisualEditorSourceFile();
						if (veSourceFile && veSourceFile.fileBridge.exists)
						{
							veSourceFile.fileBridge.deleteFile();
						}
                    }
                }
				
				if (thisEvent.wrapper.sourceController)
				{
                    thisEvent.wrapper.sourceController.remove(thisEvent.file);
                }
				
				for each (tab in IDEModel.getInstance().editors)
				{
					ed = tab as BasicTextEditor;
					if (ed 
						&& ed.currentFile
						&& ed.currentFile.fileBridge.nativePath == thisEvent.file.fileBridge.nativePath)
					{
						dispatcher.dispatchEvent(
							new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, ed, true)
						);
					}
				}
				
				// removing the wrapper in tree view
				thisEvent.wrapper.isDeleting = true;
				thisEvent.treeViewCompletionHandler(thisEvent.wrapper);
			}
			// for web
			else
			{
				file = thisEvent.file;
				treeViewHandler = thisEvent.treeViewCompletionHandler;
				wrapper = thisEvent.wrapper;
				wrapper.isWorking = true;
				wrapper.isDeleting = true;
				
				file.addEventListener(Event.COMPLETE, onFileDeleted);
				file.addEventListener(Event.CLOSE, onDeleteFault);
				file.deleteFileOrDirectory();
			}
		}

		private function onProjectDeletionConfirmed(event:DeleteFileEvent, isDeleteRoot:Boolean=false):void
		{
			var model: IDEModel = IDEModel.getInstance();
			var project:ProjectVO = UtilsCore.getProjectFromProjectFolder(event.wrapper);
			// sends delete call to factory classes
			
			var projectRef:ProjectReferenceVO = event.wrapper.projectReference;
			SharedObjectUtil.removeCookieByName("projectFiles" + projectRef.name);
			SharedObjectUtil.removeProjectTreeItemFromOpenedItems(
				{name: projectRef.name, path: projectRef.path}, "name", "path");
			
			// removal from the recently opened project in splash screen
			var toRemove:int = -1;
			for each (var file:Object in model.recentlyOpenedProjects)
			{
				if (file.path == event.wrapper.file.fileBridge.nativePath)
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
				if (model.recentlyOpenedFiles[i].path.indexOf(event.wrapper.file.fileBridge.nativePath + event.wrapper.file.fileBridge.separator) != -1)
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
			if (model.isLanguageServerPresent && !(project as AS3ProjectVO).isVisualEditorProject)
			{
				// keep the files collection in a dictionary so we can select between multiple
				// project deletion calls - as language server shutdown event returns after some delay
				pendingDeletionProjectsDict[event.wrapper.projectReference] = event.wrapper;
				
				dispatcher.addEventListener(ProjectEvent.LANGUAGE_SERVER_CLOSED, onProjectLanguageServerClosed, false, 0, true);
				dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.REMOVE_PROJECT, project));
			}
			else
			{
				// when no language server present or not setup
				dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.REMOVE_PROJECT, project));
				IDEModel.getInstance().flexCore.deleteProject(event.wrapper, thisEvent.treeViewCompletionHandler, false);
			}
		}
		
		private function onProjectLanguageServerClosed(event:ProjectEvent):void
		{
			if (pendingDeletionProjectsDict[event.project.projectFolder.projectReference] != undefined)
			{
				dispatcher.removeEventListener(ProjectEvent.LANGUAGE_SERVER_CLOSED, onProjectLanguageServerClosed);
				IDEModel.getInstance().flexCore.deleteProject(pendingDeletionProjectsDict[event.project.projectFolder.projectReference], thisEvent.treeViewCompletionHandler, false);
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
			for each (var tab:IContentWindow in IDEModel.getInstance().editors)
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

        private function getVisualEditorSourceFile():FileLocation
        {
            var as3ProjectVO:AS3ProjectVO = thisEvent.projectAssociatedWithFile as AS3ProjectVO;
            if (as3ProjectVO && as3ProjectVO.isVisualEditorProject)
            {
                var veSourcePathFile:String = thisEvent.file.fileBridge.nativePath
                        .replace(as3ProjectVO.sourceFolder.fileBridge.nativePath,
                                as3ProjectVO.visualEditorSourceFolder.fileBridge.nativePath)
                        .replace(/.mxml$|.xhtml$/, ".xml");
                return new FileLocation(veSourcePathFile);
            }

			return null;
        }
	}
}