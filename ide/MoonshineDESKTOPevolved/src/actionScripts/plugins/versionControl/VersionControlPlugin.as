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
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import actionScripts.events.SettingsEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugins.git.GitHubPlugin;
	import actionScripts.plugins.svn.event.SVNEvent;
	import actionScripts.plugins.versionControl.event.VersionControlEvent;
	import actionScripts.utils.SharedObjectUtil;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.RepositoryVO;
	import actionScripts.valueObjects.VersionControlTypes;
	
	import components.popup.AddRepositoryPopup;
	import components.popup.GitAuthenticationPopup;
	import components.popup.ManageRepositoriesPopup;

	public class VersionControlPlugin extends PluginBase
	{
		override public function get name():String			{ return "Version Control"; }
		override public function get author():String		{ return "Moonshine Project Team"; }
		override public function get description():String	{ return "Version Controls' Manager Plugin"; }
		
		private var addRepositoryWindow:AddRepositoryPopup;
		private var gitAuthWindow:GitAuthenticationPopup;
		private var manageRepoWindow:ManageRepositoriesPopup;
		private var failedMethodObjectBeforeAuth:Array;
		
		private var _repositories:ArrayCollection;
		public function get repositories():ArrayCollection
		{
			if (!_repositories) _repositories = SharedObjectUtil.getRepositoriesFromSO();
			return _repositories;
		}
		
		override public function activate():void
		{
			super.activate();
			
			dispatcher.addEventListener(VersionControlEvent.OPEN_MANAGE_REPOSITORIES, handleOpenManageRepositories, false, 0, true);
			dispatcher.addEventListener(VersionControlEvent.OPEN_ADD_REPOSITORY, handleOpenAddRepository, false, 0, true);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			
			dispatcher.removeEventListener(VersionControlEvent.OPEN_MANAGE_REPOSITORIES, handleOpenManageRepositories);
			dispatcher.removeEventListener(VersionControlEvent.OPEN_ADD_REPOSITORY, handleOpenAddRepository);
		}
		
		//--------------------------------------------------------------------------
		//
		//  MANAGE REPOSITORIES
		//
		//--------------------------------------------------------------------------
		
		protected function handleOpenManageRepositories(event:Event):void
		{
			openManageRepoWindow();
		}
		
		protected function openManageRepoWindow():void
		{
			if (!manageRepoWindow)
			{
				manageRepoWindow = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, ManageRepositoriesPopup, false) as ManageRepositoriesPopup;
				manageRepoWindow.title = "Manage Repositories";
				manageRepoWindow.repositories = repositories;
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
		
		protected function handleOpenAddRepository(event:Event):void
		{
			openAddEditRepositoryWindow(
				((event is VersionControlEvent) && (event as VersionControlEvent).value) ? 
				((event as VersionControlEvent).value as RepositoryVO) : 
				null
			);
		}
		
		protected function openAddEditRepositoryWindow(editItem:RepositoryVO=null):void
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
			if (repositories.getItemIndex(event.value) == -1) repositories.addItem(event.value);
			SharedObjectUtil.saveRepositoriesToSO(repositories);
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
				if (ConstantsCoreVO.IS_MACOS) dispatcher.dispatchEvent(new Event(GitHubPlugin.RELAY_SVN_XCODE_REQUEST));
				else dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, "actionScripts.plugins.svn::SVNPlugin"));
				return false;
			}
			
			return true;
		}
		
		protected function isVersioned(folder:FileLocation):Boolean
		{
			return folder.fileBridge.resolvePath(".svn/wc.db").fileBridge.exists;
		}
		
		private function onSVNAuthRequires(event:SVNEvent):void
		{
			failedMethodObjectBeforeAuth = event.extras;
			openAuthentication();
		}
		
		private function openAuthentication():void
		{
			if (!gitAuthWindow)
			{
				gitAuthWindow = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, GitAuthenticationPopup, true) as GitAuthenticationPopup;
				gitAuthWindow.title = "SVN Needs Authentication";
				gitAuthWindow.type = VersionControlTypes.SVN;
				gitAuthWindow.addEventListener(CloseEvent.CLOSE, onGitAuthWindowClosed);
				gitAuthWindow.addEventListener(GitAuthenticationPopup.GIT_AUTH_COMPLETED, onAuthSuccessToSVN);
				PopUpManager.centerPopUp(gitAuthWindow);
			}
			
			/*
			* @local
			*/
			function onGitAuthWindowClosed(event:CloseEvent):void
			{
				gitAuthWindow.removeEventListener(CloseEvent.CLOSE, onGitAuthWindowClosed);
				gitAuthWindow.removeEventListener(GitAuthenticationPopup.GIT_AUTH_COMPLETED, onAuthSuccessToSVN);
				PopUpManager.removePopUp(gitAuthWindow);
				gitAuthWindow = null;
			}
		}
		
		private function onAuthSuccessToSVN(event:Event):void
		{
			if (gitAuthWindow.userObject && failedMethodObjectBeforeAuth) 
			{
				switch (failedMethodObjectBeforeAuth[0])
				{
					case "update":
						//handleUpdateRequest(null, gitAuthWindow.userObject.userName, gitAuthWindow.userObject.password);
						break;
					case "commit":
						//handleCommitRequest(null, gitAuthWindow.userObject.userName, gitAuthWindow.userObject.password, {files:failedMethodObjectBeforeAuth[1], message:failedMethodObjectBeforeAuth[2], runningForFile:failedMethodObjectBeforeAuth[3]});
						break;
				}
			}
		}
	}
}