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
	import actionScripts.utils.FileUtils;

	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.collections.ArrayList;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import actionScripts.events.SettingsEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.AbstractSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugins.git.GitHubPlugin;
	import actionScripts.plugins.svn.SVNPlugin;
	import actionScripts.plugins.versionControl.event.VersionControlEvent;
	import actionScripts.ui.menu.MenuPlugin;
	import actionScripts.utils.OSXBookmarkerNotifiers;
	import actionScripts.utils.SharedObjectUtil;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.RepositoryItemVO;
	import actionScripts.valueObjects.VersionControlTypes;
	
	import components.popup.AddRepositoryPopup;
	import components.popup.ManageRepositoriesPopup;

	public class VersionControlPlugin extends PluginBase implements ISettingsProvider
	{
		override public function get name():String			{ return "Version Control"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String	{ return "Version Controls' Manager Plugin"; }
		
		private var addRepositoryWindow:AddRepositoryPopup;
		private var manageRepoWindow:ManageRepositoriesPopup;
		
		private var _xcodePath:String;
		public function get xcodePath():String
		{
			return _xcodePath;
		}
		public function set xcodePath(value:String):void
		{
			_xcodePath = value;
		}
		
		override public function activate():void
		{
			super.activate();
			
			dispatcher.addEventListener(VersionControlEvent.OPEN_MANAGE_REPOSITORIES_SVN, handleOpenManageRepositories, false, 0, true);
			dispatcher.addEventListener(VersionControlEvent.OPEN_MANAGE_REPOSITORIES_GIT, handleOpenManageRepositories, false, 0, true);
			dispatcher.addEventListener(VersionControlEvent.OPEN_ADD_REPOSITORY, handleOpenAddRepository, false, 0, true);
			dispatcher.addEventListener(VersionControlEvent.RESTORE_DEFAULT_REPOSITORIES, restoreDefaultRepositories, false, 0, true);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			
			dispatcher.removeEventListener(VersionControlEvent.OPEN_MANAGE_REPOSITORIES_SVN, handleOpenManageRepositories);
			dispatcher.removeEventListener(VersionControlEvent.OPEN_MANAGE_REPOSITORIES_GIT, handleOpenManageRepositories);
			dispatcher.removeEventListener(VersionControlEvent.OPEN_ADD_REPOSITORY, handleOpenAddRepository);
			dispatcher.removeEventListener(VersionControlEvent.RESTORE_DEFAULT_REPOSITORIES, restoreDefaultRepositories);
		}
		
		public function getSettingsList():Vector.<ISetting>
		{
			onSettingsClose();
			
			return Vector.<ISetting>([
				new PathSetting(this,'xcodePath', 'XCode-Command-line', true, xcodePath, false)
			]);
		}
		
		//--------------------------------------------------------------------------
		//
		//  MANAGE REPOSITORIES
		//
		//--------------------------------------------------------------------------
		
		protected function handleOpenManageRepositories(event:Event):void
		{
			if (!continueIfVersionControlSupported(event)) return;
			
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
				
				dispatcher.addEventListener(VersionControlEvent.CLOSE_MANAGE_REPOSITORIES, onCloseRepoWindowFromSomewhereElse);
			}
			else
			{
				PopUpManager.bringToFront(manageRepoWindow);
			}
		}
		
		protected function onManageRepoWindowClosed(event:CloseEvent):void
		{
			dispatcher.removeEventListener(VersionControlEvent.CLOSE_MANAGE_REPOSITORIES, onCloseRepoWindowFromSomewhereElse);
			manageRepoWindow.removeEventListener(CloseEvent.CLOSE, onManageRepoWindowClosed);
			PopUpManager.removePopUp(manageRepoWindow);
			manageRepoWindow = null;
		}
		
		protected function onCloseRepoWindowFromSomewhereElse(event:VersionControlEvent):void
		{
			onManageRepoWindowClosed(null);
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
				((event as VersionControlEvent).value as RepositoryItemVO) : 
				null
			);
		}
		
		protected function openAddEditRepositoryWindow(editItem:RepositoryItemVO=null):void
		{
			if (!addRepositoryWindow)
			{
				addRepositoryWindow = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, AddRepositoryPopup, true) as AddRepositoryPopup;
				addRepositoryWindow.title = editItem ? "Edit Repository" : "Add Repository";
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
		
		protected function restoreDefaultRepositories(event:Event):void
		{
			var tmpDefaults:ArrayList = VersionControlUtils.getDefaultRepositories();
			for (var i:int = 0; i < tmpDefaults.length; i++)
			{
				VersionControlUtils.REPOSITORIES.source.some(function(repoExisting:RepositoryItemVO, index:int, arr:Array):Boolean {
					if (repoExisting.url.toLowerCase() == tmpDefaults.getItemAt(i).url.toLowerCase())
					{
						tmpDefaults.removeItemAt(i);
						i--;
						return true;
					}
					return false;
				});
			};
			
			// add if items are found to be added
			if (tmpDefaults.length > 0)
			{
				VersionControlUtils.REPOSITORIES.addAllAt(tmpDefaults, 0);
				dispatcher.dispatchEvent(new ConsoleOutputEvent(
					ConsoleOutputEvent.CONSOLE_PRINT, 
					"The default repositories were restored in Manage Repositories.", 
					false, false, ConsoleOutputEvent.TYPE_SUCCESS));
			}
			else
			{
				dispatcher.dispatchEvent(new ConsoleOutputEvent(
					ConsoleOutputEvent.CONSOLE_PRINT, 
					"The default repositories are already present in Manage Repositories."));
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  PRIVATE API
		//
		//--------------------------------------------------------------------------
		
		private function continueIfVersionControlSupported(event:Event):Boolean
		{
			if (event.type == VersionControlEvent.OPEN_MANAGE_REPOSITORIES_GIT)
			{
				var isGitPresent:Boolean = UtilsCore.isGitPresent();
				if (!isGitPresent)
				{
					if (ConstantsCoreVO.IS_MACOS)
					{
						if ((!xcodePath && !isGitPresent) ||
								(xcodePath && !FileUtils.isPathExists(xcodePath) && !isGitPresent) ||
								(xcodePath && ConstantsCoreVO.IS_APP_STORE_VERSION && !OSXBookmarkerNotifiers.isPathBookmarked(xcodePath)))
						{
							dispatcher.dispatchEvent(new Event(GitHubPlugin.RELAY_SVN_XCODE_REQUEST));
						}
						else if (xcodePath && FileUtils.isPathExists(xcodePath))
						{
							// re-update both Git and SVN with common
							// XCode/Command-line path
							dispatcher.dispatchEvent(new VersionControlEvent(VersionControlEvent.OSX_XCODE_PERMISSION_GIVEN, xcodePath));

							ConstantsCoreVO.IS_GIT_OSX_AVAILABLE = true;
							dispatcher.dispatchEvent(new Event(MenuPlugin.CHANGE_GIT_CLONE_PERMISSION_LABEL));
							dispatcher.dispatchEvent(new Event(MenuPlugin.CHANGE_SVN_CHECKOUT_PERMISSION_LABEL));
							return true;
						}
					}
					else
					{
						if (!isGitPresent) dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, GitHubPlugin.NAMESPACE));
						else return true;
					}

					return false;
				}
			}
			
			return true;
		}
		
		protected function isVersioned(folder:FileLocation):Boolean
		{
			return folder.fileBridge.resolvePath(".svn/wc.db").fileBridge.exists;
		}
	}
}