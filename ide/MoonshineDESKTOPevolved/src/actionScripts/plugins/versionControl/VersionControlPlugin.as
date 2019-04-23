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
package actionScripts.plugins.versionControl
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.filesystem.File;
	
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import actionScripts.events.GeneralEvent;
	import actionScripts.events.SettingsEvent;
	import actionScripts.events.WorkerEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEWorker;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugins.git.GitHubPlugin;
	import actionScripts.plugins.versionControl.event.VersionControlEvent;
	import actionScripts.utils.SharedObjectUtil;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.RepositoryItemVO;
	import actionScripts.valueObjects.VersionControlTypes;
	
	import components.popup.AddRepositoryPopup;
	import components.popup.ManageRepositoriesPopup;

	public class VersionControlPlugin extends PluginBase
	{
		override public function get name():String			{ return "Version Control"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String	{ return "Version Controls' Manager Plugin"; }
		
		private var worker:IDEWorker = IDEWorker.getInstance();
		private var addRepositoryWindow:AddRepositoryPopup;
		private var manageRepoWindow:ManageRepositoriesPopup;
		
		override public function activate():void
		{
			super.activate();
			
			dispatcher.addEventListener(VersionControlEvent.OPEN_MANAGE_REPOSITORIES, handleOpenManageRepositories, false, 0, true);
			dispatcher.addEventListener(VersionControlEvent.OPEN_ADD_REPOSITORY, handleOpenAddRepository, false, 0, true);
			dispatcher.addEventListener(VersionControlEvent.SEARCH_PROJECTS_IN_DIRECTORIES, handleSearchForProjectsInDirectories, false, 0, true);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			
			dispatcher.removeEventListener(VersionControlEvent.OPEN_MANAGE_REPOSITORIES, handleOpenManageRepositories);
			dispatcher.removeEventListener(VersionControlEvent.OPEN_ADD_REPOSITORY, handleOpenAddRepository);
			dispatcher.removeEventListener(VersionControlEvent.SEARCH_PROJECTS_IN_DIRECTORIES, handleSearchForProjectsInDirectories);
		}
		
		//--------------------------------------------------------------------------
		//
		//  MANAGE REPOSITORIES
		//
		//--------------------------------------------------------------------------
		
		protected function handleOpenManageRepositories(event:Event):void
		{
			if (!continueIfSVNSupported()) return;
			
			openManageRepoWindow();
		}
		
		protected function openManageRepoWindow():void
		{
			if (!manageRepoWindow)
			{
				manageRepoWindow = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, ManageRepositoriesPopup, false) as ManageRepositoriesPopup;
				manageRepoWindow.title = "Manage Repositories";
				manageRepoWindow.repositories = VersionControlUtils.REPOSITORIES;
				manageRepoWindow.width = FlexGlobals.topLevelApplication.stage.nativeWindow.width * .8;
				manageRepoWindow.height = FlexGlobals.topLevelApplication.stage.nativeWindow.height * .5;
				manageRepoWindow.addEventListener(CloseEvent.CLOSE, onManageRepoWindowClosed);
				PopUpManager.centerPopUp(manageRepoWindow);
			}
			else
			{
				PopUpManager.bringToFront(manageRepoWindow);
			}
		}
		
		protected function onManageRepoWindowClosed(event:CloseEvent):void
		{
			manageRepoWindow.removeEventListener(CloseEvent.CLOSE, onManageRepoWindowClosed);
			PopUpManager.removePopUp(manageRepoWindow);
			manageRepoWindow = null;
		}
		
		//--------------------------------------------------------------------------
		//
		//  CHECKOUT/CLONE WINDOW
		//
		//--------------------------------------------------------------------------
		
		protected function onWorkerValueIncoming(event:GeneralEvent):void
		{
			switch (event.value.event)
			{
				case WorkerEvent.FOUND_PROJECTS_IN_DIRECTORIES:
					trace(event.value.value);
					
					// remove the listener 
					// we'll re-add when again needed
					worker.removeEventListener(IDEWorker.WORKER_VALUE_INCOMING, onWorkerValueIncoming);
					break;
			}
		}
		
		protected function handleOpenAddRepository(event:Event):void
		{
			openAddEditRepositoryWindow(
				((event is VersionControlEvent) && (event as VersionControlEvent).value) ? 
				((event as VersionControlEvent).value as RepositoryItemVO) : 
				null
			);
		}
		
		protected function handleSearchForProjectsInDirectories(event:VersionControlEvent):void
		{
			if (!worker.hasEventListener(IDEWorker.WORKER_VALUE_INCOMING))
			{
				worker.addEventListener(IDEWorker.WORKER_VALUE_INCOMING, onWorkerValueIncoming, false, 0, true);
			}
			
			// send path instead of file as sending file is expensive
			worker.sendToWorker(WorkerEvent.SEARCH_PROJECTS_IN_DIRECTORIES, getObject());
			
			/*
			 * @local
			 */
			function getObject():Object
			{
				var tmpObj:Object = new Object();
				tmpObj.path = (event.value.path as File).nativePath;
				tmpObj.udid = (event.value.repository as RepositoryItemVO).udid;
				tmpObj.maxDepthCount = VersionControlUtils.MAX_DEPTH_COUNT_IN_PROJECT_SEARCH;
				return tmpObj;
			}
		}
		
		protected function openAddEditRepositoryWindow(editItem:RepositoryItemVO=null):void
		{
			if (!addRepositoryWindow)
			{
				addRepositoryWindow = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, AddRepositoryPopup, true) as AddRepositoryPopup;
				addRepositoryWindow.title = "Add Repository";
				addRepositoryWindow.type = VersionControlTypes.SVN;
				addRepositoryWindow.editingRepository = editItem;
				addRepositoryWindow.addEventListener(CloseEvent.CLOSE, onAddRepoWindowClosed);
				addRepositoryWindow.addEventListener(VersionControlEvent.ADD_EDIT_REPOSITORY, onAddEditRepository);
				
				PopUpManager.centerPopUp(addRepositoryWindow);
			}
			else
			{
				PopUpManager.bringToFront(addRepositoryWindow);
			}
		}
		
		protected function onAddEditRepository(event:VersionControlEvent):void
		{
			// check if new repository or old
			if (VersionControlUtils.REPOSITORIES.getItemIndex(event.value) == -1) VersionControlUtils.REPOSITORIES.addItem(event.value);
			SharedObjectUtil.saveRepositoriesToSO(VersionControlUtils.REPOSITORIES);
		}
		
		protected function onAddRepoWindowClosed(event:CloseEvent):void
		{
			addRepositoryWindow.removeEventListener(CloseEvent.CLOSE, onAddRepoWindowClosed);
			addRepositoryWindow.removeEventListener(VersionControlEvent.ADD_EDIT_REPOSITORY, onAddEditRepository);
			
			PopUpManager.removePopUp(addRepositoryWindow);
			addRepositoryWindow = null;
		}
		
		//--------------------------------------------------------------------------
		//
		//  PRIVATE API
		//
		//--------------------------------------------------------------------------
		
		private function continueIfSVNSupported():Boolean
		{
			// check if svn path exists
			if (!model.svnPath || model.svnPath == "")
			{
				if (ConstantsCoreVO.IS_MACOS) 
				{
					dispatcher.dispatchEvent(new Event(GitHubPlugin.RELAY_SVN_XCODE_REQUEST));
				}
				else 
				{
					dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, "actionScripts.plugins.svn::SVNPlugin"));
				}
				return false;
			}
			
			return true;
		}
		
		protected function isVersioned(folder:FileLocation):Boolean
		{
			return folder.fileBridge.resolvePath(".svn/wc.db").fileBridge.exists;
		}
	}
}