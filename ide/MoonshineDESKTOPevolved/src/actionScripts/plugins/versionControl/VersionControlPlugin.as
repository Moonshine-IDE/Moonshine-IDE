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
	
	import mx.collections.ArrayList;
	import mx.controls.Alert;
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
	import actionScripts.plugins.git.commands.CheckIsGitRepositoryCommand;
	import actionScripts.plugins.git.commands.GetXCodePathCommand;
	import actionScripts.plugins.svn.SVNPlugin;
	import actionScripts.plugins.versionControl.event.VersionControlEvent;
	import actionScripts.plugins.versionControl.utils.VersionControlUtils;
	import actionScripts.ui.menu.MenuPlugin;
	import actionScripts.utils.HelperUtils;
	import actionScripts.utils.OSXBookmarkerNotifiers;
	import actionScripts.utils.PathSetupHelperUtil;
	import actionScripts.utils.SharedObjectUtil;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ComponentTypes;
	import actionScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.RepositoryItemVO;
	import actionScripts.valueObjects.VersionControlTypes;
	
	import components.popup.AddRepositoryPopup;
	import components.popup.GitXCodePermissionPopup;
	import components.popup.ManageRepositoriesPopup;

	public class VersionControlPlugin extends PluginBase implements ISettingsProvider
	{
		override public function get name():String			{ return "Source Control"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String	{ return "Source Controls' Manager Plugin"; }
		
		public static const NAMESPACE:String = "actionScripts.plugins.versionControl::VersionControlPlugin";
		
		private var addRepositoryWindow:AddRepositoryPopup;
		private var manageRepoWindow:ManageRepositoriesPopup;
		private var xCodePermissionWindow:GitXCodePermissionPopup;
		private var xcodePathSetting:PathSetting;
		private var baseSettings:Vector.<ISetting>;
		private var isStartupCall:Boolean;
		
		protected var gitPlugin:GitHubPlugin;
		protected var svnPlugin:SVNPlugin;
		
		private var _xcodePath:String;
		public function get xcodePath():String
		{
			return _xcodePath;
		}
		public function set xcodePath(value:String):void
		{
			if (_xcodePath != value)
			{
				_xcodePath = value;
				VersionControlUtils.SANDBOX_XCODE_PERMITTED_PATH = xcodePath;
				updateOtherPaths();
			}
		}
		
		override public function activate():void
		{
			super.activate();
			
			gitPlugin = new GitHubPlugin();
			svnPlugin = new SVNPlugin();
			
			dispatcher.addEventListener(VersionControlEvent.OPEN_MANAGE_REPOSITORIES_SVN, handleOpenManageRepositories, false, 0, true);
			dispatcher.addEventListener(VersionControlEvent.OPEN_MANAGE_REPOSITORIES_GIT, handleOpenManageRepositories, false, 0, true);
			dispatcher.addEventListener(VersionControlEvent.OPEN_ADD_REPOSITORY, handleOpenAddRepository, false, 0, true);
			dispatcher.addEventListener(VersionControlEvent.RESTORE_DEFAULT_REPOSITORIES, restoreDefaultRepositories, false, 0, true);
			dispatcher.addEventListener(VersionControlEvent.REQUEST_ON_XCODE_PERMISSION, onXCodeAccessPermissionRequested, false, 0, true);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			
			dispatcher.removeEventListener(VersionControlEvent.OPEN_MANAGE_REPOSITORIES_SVN, handleOpenManageRepositories);
			dispatcher.removeEventListener(VersionControlEvent.OPEN_MANAGE_REPOSITORIES_GIT, handleOpenManageRepositories);
			dispatcher.removeEventListener(VersionControlEvent.OPEN_ADD_REPOSITORY, handleOpenAddRepository);
			dispatcher.removeEventListener(VersionControlEvent.RESTORE_DEFAULT_REPOSITORIES, restoreDefaultRepositories);
			dispatcher.removeEventListener(VersionControlEvent.REQUEST_ON_XCODE_PERMISSION, onXCodeAccessPermissionRequested);
		}
		
		override public function onSettingsClose():void
		{
			if (xcodePathSetting)
			{
				xcodePathSetting.removeEventListener(AbstractSetting.PATH_SELECTED, onXCodePathSelected);
				xcodePathSetting.removeEventListener(AbstractSetting.PATH_REMOVED, onXCodePathSelected);
				xcodePathSetting = null;
			}
			
			baseSettings = null;
		}
		
		public function getSettingsList():Vector.<ISetting>
		{
			onSettingsClose();
			
			baseSettings = new Vector.<ISetting>();
			if (ConstantsCoreVO.IS_MACOS)
			{
				xcodePathSetting = new PathSetting(this,'xcodePath', 'XCode/CommandLineTools', true, xcodePath, false);
				xcodePathSetting.setMessage("Git and Subversion paths shall be calculated on based this", AbstractSetting.MESSAGE_IMPORTANT);
				xcodePathSetting.addEventListener(AbstractSetting.PATH_SELECTED, onXCodePathSelected, false, 0, true);
				xcodePathSetting.addEventListener(AbstractSetting.PATH_REMOVED, onXCodePathSelected, false, 0, true);
				
				baseSettings = baseSettings.concat(Vector.<ISetting>([
					xcodePathSetting
				]));
			}
			
			if (gitPlugin) baseSettings = baseSettings.concat(gitPlugin.getSettingsList());
			if (svnPlugin) baseSettings = baseSettings.concat(svnPlugin.getSettingsList());
			
			return baseSettings
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
		
		protected function updateOtherPaths():void
		{
			if (!ConstantsCoreVO.IS_MACOS) return;
			
			if (!xcodePath)
			{
				if (gitPlugin) gitPlugin.gitBinaryPathOSX = null;
				if (svnPlugin) svnPlugin.svnBinaryPath = null;
				updateSettingsScreen();
				return;
			}
			
			var tmpComponent:ComponentVO;
			var isValidSDKPath:Boolean;
			var tmpPathSetting:AbstractSetting;
			if (gitPlugin) 
			{
				tmpComponent = HelperUtils.getComponentByType(ComponentTypes.TYPE_GIT);
				if (tmpComponent)
				{
					isValidSDKPath = HelperUtils.isValidExecutableBy(ComponentTypes.TYPE_GIT, xcodePath +"/"+ tmpComponent.pathValidation, tmpComponent.pathValidation);
					gitPlugin.gitBinaryPathOSX = xcodePath +"/"+ tmpComponent.pathValidation;
					if (!isValidSDKPath)
					{
						gitPlugin.setPathMessage("Invalid path: Path must contain "+ tmpComponent.pathValidation +".", AbstractSetting.MESSAGE_CRITICAL);
					}
					else
					{
						gitPlugin.setPathMessage(null);
					}
				}
			}
			if (svnPlugin) 
			{
				tmpComponent = HelperUtils.getComponentByType(ComponentTypes.TYPE_SVN);
				if (tmpComponent)
				{
					isValidSDKPath = HelperUtils.isValidExecutableBy(ComponentTypes.TYPE_SVN, xcodePath +"/"+ tmpComponent.pathValidation, tmpComponent.pathValidation);
					svnPlugin.svnBinaryPath = xcodePath +"/"+ tmpComponent.pathValidation;
					if (!isValidSDKPath)
					{
						svnPlugin.setPathMessage("Invalid path: Path must contain "+ tmpComponent.pathValidation +".", AbstractSetting.MESSAGE_CRITICAL);
					}
					else
					{
						svnPlugin.setPathMessage(null);
					}
				}
			}
			
			updateSettingsScreen();
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
		//  XCODE PERMISSION TEST
		//	AUTO-SETUP XCODE ON NON-SANDBOX
		//
		//--------------------------------------------------------------------------
		
		private function onXCodeAccessPermissionRequested(event:Event):void
		{
			if (!xcodePath)
			{
				testXCodeOnSandbox();
			}
			else
			{
				dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, VersionControlPlugin.NAMESPACE));
			}
		}
		
		private function continueIfVersionControlSupported(event:Event):Boolean
		{
			var isSVNPresent:Boolean = UtilsCore.isSVNPresent();
			var isGitPresent:Boolean = UtilsCore.isGitPresent();
			if (!isSVNPresent || !isGitPresent)
			{
				if (ConstantsCoreVO.IS_MACOS) 
				{
					if (!xcodePath)
					{
						testXCodeOnSandbox();
					}
					else if (xcodePath && ConstantsCoreVO.IS_APP_STORE_VERSION && !OSXBookmarkerNotifiers.isPathBookmarked(xcodePath))
					{
						onXCodePathDetected(xcodePath, true);
					}
					else
					{
						// re-update both Git and SVN with common 
						// XCode/Command-line path
						dispatcher.dispatchEvent(new VersionControlEvent(VersionControlEvent.OSX_XCODE_PERMISSION_GIVEN, xcodePath));
						
						ConstantsCoreVO.IS_SVN_OSX_AVAILABLE = ConstantsCoreVO.IS_GIT_OSX_AVAILABLE = true;
						dispatcher.dispatchEvent(new Event(MenuPlugin.CHANGE_GIT_CLONE_PERMISSION_LABEL));
						dispatcher.dispatchEvent(new Event(MenuPlugin.CHANGE_SVN_CHECKOUT_PERMISSION_LABEL));
						return true;
					}
				}
				else 
				{
					dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, VersionControlPlugin.NAMESPACE));
				}
				
				return false;
			}
			
			return true;
		}
		
		private function onXCodePathDetected(path:String, isXCodePath:Boolean):void
		{
			// if calls during startup 
			// do not open the prompt
			if (path && ConstantsCoreVO.IS_APP_STORE_VERSION && !xCodePermissionWindow && !isStartupCall)
			{
				xCodePermissionWindow = new GitXCodePermissionPopup;
				xCodePermissionWindow.isXCodePath = isXCodePath;
				xCodePermissionWindow.xCodePath = path;
				xCodePermissionWindow.horizontalCenter = xCodePermissionWindow.verticalCenter = 0;
				xCodePermissionWindow.addEventListener(Event.CLOSE, onXCodePermissionClosed, false, 0, true);
				FlexGlobals.topLevelApplication.addElement(xCodePermissionWindow);
			}
			else if (path && !ConstantsCoreVO.IS_APP_STORE_VERSION)
			{
				updateXCodePath(path);
			}
			
			isStartupCall = false;
		}
		
		private function onXCodePermissionClosed(event:Event):void
		{
			var isDiscarded:Boolean = xCodePermissionWindow.isDiscarded;
			var isGranted:Boolean;
			if (!isDiscarded) 
			{
				isGranted = true;
				Alert.show("Permission accepted. You can now use Moonshine Git and SVN functionalities.", "Success!");
				updateXCodePath(xCodePermissionWindow.xCodePath);
			}
			else
			{
				isGranted = false;
			}
			
			if (ConstantsCoreVO.IS_GIT_OSX_AVAILABLE != isGranted)
			{
				ConstantsCoreVO.IS_SVN_OSX_AVAILABLE = ConstantsCoreVO.IS_GIT_OSX_AVAILABLE = isGranted;
				dispatcher.dispatchEvent(new Event(MenuPlugin.CHANGE_GIT_CLONE_PERMISSION_LABEL));
				dispatcher.dispatchEvent(new Event(MenuPlugin.CHANGE_SVN_CHECKOUT_PERMISSION_LABEL));
			}
			
			xCodePermissionWindow.removeEventListener(Event.CLOSE, onXCodePermissionClosed);
			FlexGlobals.topLevelApplication.removeElement(xCodePermissionWindow);
			xCodePermissionWindow = null;
		}
		
		private function updateXCodePath(value:String):void
		{
			dispatcher.dispatchEvent(new VersionControlEvent(VersionControlEvent.OSX_XCODE_PERMISSION_GIVEN, value));
			
			// save the xcode-only path for later use
			PathSetupHelperUtil.updateXCodePath(value);
			
			// test if any already opened project is selected
			if (model.activeProject)
			{
				new CheckIsGitRepositoryCommand(model.activeProject);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  PRIVATE API
		//
		//--------------------------------------------------------------------------
		
		private function testXCodeOnSandbox():void
		{
			new GetXCodePathCommand(onXCodePathDetected);
		}
		
		private function updateSettingsScreen():void
		{
			if (gitPlugin && svnPlugin)
			{
				gitPlugin.updatePathSetting();
				svnPlugin.updatePathSetting();
				
				dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_REFRESH_CURRENT_SETTINGS));
			}
		}
		
		private function onXCodePathSelected(event:Event):void
		{
			xcodePath = xcodePathSetting.stringValue;
		}
		
		private function isVersioned(folder:FileLocation):Boolean
		{
			return folder.fileBridge.resolvePath(".svn/wc.db").fileBridge.exists;
		}
	}
}