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
package actionScripts.plugins.git
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.managers.PopUpManager;
	
	import actionScripts.events.GeneralEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.SettingsEvent;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.PluginManager;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.event.SetSettingsEvent;
	import actionScripts.plugin.settings.renderers.PathRenderer;
	import actionScripts.plugin.settings.vo.AbstractSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugins.git.commands.AuthorCommand;
	import actionScripts.plugins.git.commands.CheckBranchNameAvailabilityCommand;
	import actionScripts.plugins.git.commands.CheckDifferenceCommand;
	import actionScripts.plugins.git.commands.CheckGitAvailabilityCommand;
	import actionScripts.plugins.git.commands.CheckIsGitRepositoryCommand;
	import actionScripts.plugins.git.commands.CloneCommand;
	import actionScripts.plugins.git.commands.CreateCheckoutNewBranchCommand;
	import actionScripts.plugins.git.commands.GetCurrentBranchCommand;
	import actionScripts.plugins.git.commands.GetXCodePathCommand;
	import actionScripts.plugins.git.commands.GitChangeBranchToCommand;
	import actionScripts.plugins.git.commands.GitCheckoutCommand;
	import actionScripts.plugins.git.commands.GitCommitCommand;
	import actionScripts.plugins.git.commands.GitSwitchBranchCommand;
	import actionScripts.plugins.git.commands.PullCommand;
	import actionScripts.plugins.git.commands.PushCommand;
	import actionScripts.plugins.git.commands.RevertCommand;
	import actionScripts.plugins.git.model.GitProjectVO;
	import actionScripts.plugins.versionControl.event.VersionControlEvent;
	import actionScripts.ui.menu.MenuPlugin;
	import actionScripts.ui.menu.vo.ProjectMenuTypes;
	import actionScripts.utils.HelperUtils;
	import actionScripts.utils.MethodDescriptor;
	import actionScripts.utils.PathSetupHelperUtil;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ComponentTypes;
	import actionScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.GenericSelectableObject;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.RepositoryItemVO;
	import actionScripts.valueObjects.VersionControlTypes;
	
	import components.popup.GitAuthenticationPopup;
	import components.popup.GitBranchSelectionPopup;
	import components.popup.GitCommitSelectionPopup;
	import components.popup.GitNewBranchPopup;
	import components.popup.GitRepositoryPermissionPopup;
	import components.popup.GitXCodePermissionPopup;
	import components.popup.SourceControlCheckout;
	
    public class GitHubPlugin extends PluginBase implements ISettingsProvider
	{
		public static const CLONE_REQUEST:String = "gutCloneRequest";
		public static const CHECKOUT_REQUEST:String = "gitCheckoutRequestEvent";
		public static const COMMIT_REQUEST:String = "gitCommitRequest";
		public static const PULL_REQUEST:String = "gitPullRequest";
		public static const PUSH_REQUEST: String = "gitPushRequest";
		public static const REVERT_REQUEST:String = "gitFilesRevertRequest";
		public static const NEW_BRANCH_REQUEST:String = "gitNewBranchRequest";
		public static const CHANGE_BRANCH_REQUEST:String = "gitChangeBranchRequest";
		public static const RELAY_SVN_XCODE_REQUEST:String = "svnXCodePermissionRequest";
		
		public static const NAMESPACE:String = "actionScripts.plugins.git::GitHubPlugin";
		
		override public function get name():String			{ return "Git"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String	{ return "Git Plugin."; }
		
		private var _gitBinaryPathOSX:String;
		public function get gitBinaryPathOSX():String
		{
			return _gitBinaryPathOSX;
		}
		public function set gitBinaryPathOSX(value:String):void
		{
			if (_gitBinaryPathOSX != value)
			{
				model.gitPath = _gitBinaryPathOSX = value;
			}
		}
		
		public var modelAgainstProject:Dictionary = new Dictionary();
		public var projectsNotAcceptedByUserToPermitAsGitOnMacOS:Dictionary = new Dictionary();
		
		private var isGitAvailable:Boolean;
		private var checkoutWindow:SourceControlCheckout;
		private var xCodePermissionWindow:GitXCodePermissionPopup;
		private var gitRepositoryPermissionWindow:GitRepositoryPermissionPopup;
		private var gitCommitWindow:GitCommitSelectionPopup;
		private var gitAuthWindow:GitAuthenticationPopup;
		private var gitBranchSelectionWindow:GitBranchSelectionPopup;
		private var gitNewBranchWindow:GitNewBranchPopup;
		private var isStartupTest:Boolean;
		private var pathSetting:PathSetting;
		
		public function GitHubPlugin()
		{
			PluginManager.getInstance().registerPlugin(this);
		}
		
		override public function activate():void
		{
			super.activate();
			
			dispatcher.addEventListener(CLONE_REQUEST, onCloneRequest, false, 0, true);
			dispatcher.addEventListener(CHECKOUT_REQUEST, onCheckoutRequest, false, 0, true);
			dispatcher.addEventListener(COMMIT_REQUEST, onCommitRequest, false, 0, true);
			dispatcher.addEventListener(PULL_REQUEST, onPullRequest, false, 0, true);
			dispatcher.addEventListener(PUSH_REQUEST, onPushRequest, false, 0, true);
			dispatcher.addEventListener(REVERT_REQUEST, onRevertRequest, false, 0, true);
			dispatcher.addEventListener(NEW_BRANCH_REQUEST, onNewBranchRequest, false, 0, true);
			dispatcher.addEventListener(CHANGE_BRANCH_REQUEST, onChangeBranchRequest, false, 0, true);
			dispatcher.addEventListener(ProjectEvent.CHECK_GIT_PROJECT, onMenuTypeUpdateAgainstGit, false, 0, true);
			dispatcher.addEventListener(RELAY_SVN_XCODE_REQUEST, onXCodeAccessRequestBySVN, false, 0, true);
			dispatcher.addEventListener(CheckIsGitRepositoryCommand.GIT_REPOSITORY_TESTED, onGitRepositoryTested, false, 0, true);
			dispatcher.addEventListener(VersionControlEvent.OSX_XCODE_PERMISSION_GIVEN, onOSXodePermission);
			
			model.projects.addEventListener(CollectionEvent.COLLECTION_CHANGE, onProjectsCollectionChanged, false, 0, true);
			dispatcher.addEventListener(SettingsEvent.EVENT_SETTINGS_SAVED, onSettingsSaved, false, 0, true);
			
			isStartupTest = true;
			if (checkOSXGitAccess()) 
			{
				checkGitAvailability();
			}
		}
		
		override public function deactivate():void 
		{
			super.deactivate();
			
			dispatcher.removeEventListener(CLONE_REQUEST, onCloneRequest);
			dispatcher.removeEventListener(CHECKOUT_REQUEST, onCheckoutRequest);
			dispatcher.removeEventListener(COMMIT_REQUEST, onCommitRequest);
			dispatcher.removeEventListener(PULL_REQUEST, onPullRequest);
			dispatcher.removeEventListener(PUSH_REQUEST, onPushRequest);
			dispatcher.removeEventListener(REVERT_REQUEST, onRevertRequest);
			dispatcher.removeEventListener(NEW_BRANCH_REQUEST, onNewBranchRequest);
			dispatcher.removeEventListener(CHANGE_BRANCH_REQUEST, onChangeBranchRequest);
			dispatcher.removeEventListener(ProjectEvent.CHECK_GIT_PROJECT, onMenuTypeUpdateAgainstGit);
			dispatcher.removeEventListener(RELAY_SVN_XCODE_REQUEST, onXCodeAccessRequestBySVN);
			dispatcher.removeEventListener(CheckIsGitRepositoryCommand.GIT_REPOSITORY_TESTED, onGitRepositoryTested);
			dispatcher.removeEventListener(VersionControlEvent.OSX_XCODE_PERMISSION_GIVEN, onOSXodePermission);
			
			model.projects.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onProjectsCollectionChanged);
			dispatcher.removeEventListener(SettingsEvent.EVENT_SETTINGS_SAVED, onSettingsSaved);
		}
		
		override public function resetSettings():void
		{
			gitBinaryPathOSX = null;
			ConstantsCoreVO.IS_GIT_OSX_AVAILABLE = false;
			setGitAvailable(false);
			dispatcher.dispatchEvent(new Event(MenuPlugin.CHANGE_GIT_CLONE_PERMISSION_LABEL));
			
			for each (var i:ProjectVO in model.projects)
			{
				i.menuType = i.menuType.replace(","+ ProjectMenuTypes.GIT_PROJECT, "");
			}
			
			// following will enable/disable Moonshine top menus based on project
			if (model.activeProject)
			{
				dispatcher.dispatchEvent(new Event(MenuPlugin.REFRESH_MENU_STATE));
			}
		}
		
		public function getSettingsList():Vector.<ISetting>
		{
			onSettingsClose();
			
			pathSetting = new PathSetting(this,'gitBinaryPathOSX', 'Git Binary', false, gitBinaryPathOSX, false);
			
			// able to edit on Windows only
			if (!ConstantsCoreVO.IS_MACOS)
			{
				pathSetting.addEventListener(AbstractSetting.PATH_SELECTED, onSDKPathSelected, false, 0, true);
			}
			else
			{
				pathSetting.editable = false;
			}
			
			return Vector.<ISetting>([
				pathSetting
			]);
		}
		
		override public function onSettingsClose():void
		{
			if (pathSetting)
			{
				pathSetting.removeEventListener(AbstractSetting.PATH_SELECTED, onSDKPathSelected);
				pathSetting = null;
			}
		}
		
		private function onSDKPathSelected(event:Event):void
		{
			if (!pathSetting.stringValue) return;
			var tmpComponent:ComponentVO = HelperUtils.getComponentByType(ComponentTypes.TYPE_GIT);
			if (tmpComponent)
			{
				var isValidSDKPath:Boolean = HelperUtils.isValidExecutableBy(ComponentTypes.TYPE_GIT, pathSetting.stringValue, tmpComponent.pathValidation);
				if (!isValidSDKPath)
				{
					pathSetting.setMessage("Invalid path: Path must contain "+ tmpComponent.pathValidation +".", AbstractSetting.MESSAGE_CRITICAL);
				}
			}
		}
		
		public function requestToAuthenticate(onComplete:MethodDescriptor=null):void
		{
			if (!modelAgainstProject[model.activeProject].sessionUser)
			{
				openAuthentication(onComplete);
			}
		}
		
		public function setGitAvailable(value:Boolean):void
		{
			isGitAvailable = value;
			if (checkoutWindow) checkoutWindow.isGitAvailable = isGitAvailable;
			if (gitAuthWindow) gitAuthWindow.isGitAvailable = isGitAvailable;
			if (gitBranchSelectionWindow) gitBranchSelectionWindow.isGitAvailable = isGitAvailable;
			if (gitNewBranchWindow) gitNewBranchWindow.isGitAvailable = isGitAvailable;
		}
		
		public function setPathMessage(value:String, type:String=AbstractSetting.MESSAGE_NORMAL):void
		{
			if (pathSetting) pathSetting.setMessage(value, type);
		}
		
		public function updatePathSetting():void
		{
			if (pathSetting)
			{
				// for some reason {stringValue} not updates automatically
				// to its binding label
				pathSetting.stringValue = (pathSetting.renderer as PathRenderer).lblValue.text = gitBinaryPathOSX;
			}
		}
		
		private function checkGitAvailability():void
		{
			new CheckGitAvailabilityCommand();
		}
		
		private function onProjectsCollectionChanged(event:CollectionEvent):void
		{
			if (event.kind == CollectionEventKind.REMOVE && modelAgainstProject[event.items[0]] != undefined) 
			{
				var deletedProjectPath:String = (event.items[0] as ProjectVO).folderLocation.fileBridge.nativePath;
				if (projectsNotAcceptedByUserToPermitAsGitOnMacOS[deletedProjectPath] != undefined) delete projectsNotAcceptedByUserToPermitAsGitOnMacOS[deletedProjectPath];
				delete modelAgainstProject[event.items[0]];
			}
		}
		
		private function onXCodeAccessRequestBySVN(event:Event):void
		{
			checkOSXGitAccess(ProjectMenuTypes.SVN_PROJECT);
		}
		
		private function onSettingsSaved(event:SettingsEvent):void
		{
			if (pathSetting)
			{
				dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING,
					null, NAMESPACE, Vector.<ISetting>([
						pathSetting
					])));
			}
		}
		
		protected function onOSXodePermission(event:VersionControlEvent):void
		{
			gitBinaryPathOSX = String(event.value) + "/usr/bin/git";
			
			var thisSettings: Vector.<ISetting> = getSettingsList();
			var pathSettingToDefaultSDK:PathSetting = thisSettings[0] as PathSetting;
			dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING, null, NAMESPACE, thisSettings));
		}
		
		private function checkOSXGitAccess(against:String=ProjectMenuTypes.GIT_PROJECT):Boolean
		{
			if (ConstantsCoreVO.IS_MACOS && !gitBinaryPathOSX) 
			{
				new GetXCodePathCommand(onXCodePathDetection);
				return false;
			}
			else if (ConstantsCoreVO.IS_MACOS && (against == ProjectMenuTypes.SVN_PROJECT) && !UtilsCore.isSVNPresent()) 
			{
				new GetXCodePathCommand(onXCodePathDetection);
				return false;
			}
			else if (ConstantsCoreVO.IS_MACOS && gitBinaryPathOSX && !ConstantsCoreVO.IS_GIT_OSX_AVAILABLE)
			{
				ConstantsCoreVO.IS_SVN_OSX_AVAILABLE = ConstantsCoreVO.IS_GIT_OSX_AVAILABLE = true;
			}
			
			isStartupTest = false;
			return true;
		}
		
		private function onXCodePathDetection(path:String, isXCodePath:Boolean, against:String):void
		{
			// if calls during startup 
			// do not open the prompt
			if (!isStartupTest && path && !xCodePermissionWindow)
			{
				xCodePermissionWindow = new GitXCodePermissionPopup;
				xCodePermissionWindow.isXCodePath = isXCodePath;
				xCodePermissionWindow.xCodePath = path;
				xCodePermissionWindow.xCodePathAgainst = against;
				xCodePermissionWindow.horizontalCenter = xCodePermissionWindow.verticalCenter = 0;
				xCodePermissionWindow.addEventListener(Event.CLOSE, onXCodePermissionClosed, false, 0, true);
				FlexGlobals.topLevelApplication.addElement(xCodePermissionWindow);
			}
			
			isStartupTest = false;
		}
		
		private function onXCodePermissionClosed(event:Event):void
		{
			var isDiscarded:Boolean = xCodePermissionWindow.isDiscarded;
			var isGranted:Boolean;
			if (!isDiscarded) 
			{
				isGranted = true;
				
				dispatcher.dispatchEvent(new VersionControlEvent(VersionControlEvent.OSX_XCODE_PERMISSION_GIVEN, xCodePermissionWindow.xCodePath));
				Alert.show("Permission accepted. You can now use Moonshine Git and SVN functionalities.", "Success!");
				
				// re-test
				checkGitAvailability();
				// if an opened project lets test it if Git repository
				if (model.activeProject) 
				{
					/*processManager.pendingProcess.push(
						new MethodDescriptor(CheckIsGitRepositoryCommand, 'CheckIsGitRepositoryCommand', model.activeProject)
					);*/
					new CheckIsGitRepositoryCommand(model.activeProject);
				}
				// save the xcode-only path for later use
				PathSetupHelperUtil.updateXCodePath(xCodePermissionWindow.xCodePath);
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
		
		private function onCloneRequest(event:Event):void
		{
			if (!checkoutWindow)
			{
				if (!checkOSXGitAccess()) return;
				
				checkGitAvailability();
				
				checkoutWindow = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, SourceControlCheckout, true) as SourceControlCheckout;
				checkoutWindow.title = "Clone Repository";
				checkoutWindow.type = VersionControlTypes.GIT;
				checkoutWindow.isGitAvailable = isGitAvailable;
				if (event is VersionControlEvent) checkoutWindow.editingRepository = (event as VersionControlEvent).value as RepositoryItemVO;
				checkoutWindow.addEventListener(VersionControlEvent.CLONE_CHECKOUT_REQUESTED, onCloneRequested);
				checkoutWindow.addEventListener(CloseEvent.CLOSE, onCheckoutWindowClosed);
				PopUpManager.centerPopUp(checkoutWindow);
			}
			else
			{
				PopUpManager.bringToFront(checkoutWindow);
			}
		}
		
		private function onCheckoutWindowClosed(event:CloseEvent):void
		{
			checkoutWindow.removeEventListener(VersionControlEvent.CLONE_CHECKOUT_REQUESTED, onCloneRequested);
			checkoutWindow.removeEventListener(CloseEvent.CLOSE, onCheckoutWindowClosed);
			PopUpManager.removePopUp(checkoutWindow);
			checkoutWindow = null;
		}
		
		private function onCloneRequested(event:VersionControlEvent):void
		{
			var submitObject:Object = checkoutWindow.submitObject;
			if (submitObject) 
			{
				var tmpCommand:CloneCommand = new CloneCommand(submitObject.url, submitObject.target, submitObject.targetFolder, submitObject.repository);
			}
		}
		
		private function onCheckoutRequest(event:Event):void
		{
			new GitCheckoutCommand();
		}
		
		private function onCommitRequest(event:Event):void
		{
			if (!gitCommitWindow)
			{
				if (!checkOSXGitAccess()) return;
				
				checkGitAvailability();
				
				gitCommitWindow = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, GitCommitSelectionPopup, false) as GitCommitSelectionPopup;
				gitCommitWindow.title = "Commit";
				gitCommitWindow.isGitAvailable = isGitAvailable;
				gitCommitWindow.addEventListener(CloseEvent.CLOSE, onGitCommitWindowClosed);
				PopUpManager.centerPopUp(gitCommitWindow);
				
				// we let the popup opened completely
				// then run the following process else
				// there could be a hold before appearing
				// the window until folling process is finished
				gitCommitWindow.callLater(function():void
				{
					if (!dispatcher.hasEventListener(CheckDifferenceCommand.GIT_DIFF_CHECKED))
						dispatcher.addEventListener(CheckDifferenceCommand.GIT_DIFF_CHECKED, onGitDiffChecked, false, 0, true);
					new CheckDifferenceCommand();
				});
			}
			else
			{
				PopUpManager.bringToFront(gitCommitWindow);
			}
		}
		
		private function onGitAuthorDetection(value:GitProjectVO):void
		{
			if (gitCommitWindow && value) gitCommitWindow.onGitAuthorDetection(value);
		}
		
		private function onGitCommitWindowClosed(event:CloseEvent):void
		{
			if (gitCommitWindow.isSubmit) 
			{
				new GitCommitCommand(gitCommitWindow.commitDiffCollection, gitCommitWindow.commitMessage);
			}
			
			gitCommitWindow.removeEventListener(CloseEvent.CLOSE, onGitCommitWindowClosed);
			PopUpManager.removePopUp(gitCommitWindow);
			gitCommitWindow = null;
		}
		
		private function onGitDiffChecked(event:GeneralEvent):void
		{
			dispatcher.removeEventListener(CheckDifferenceCommand.GIT_DIFF_CHECKED, onGitDiffChecked);
			if (gitCommitWindow) 
			{
				gitCommitWindow.isReadyToUse = true;
				gitCommitWindow.commitDiffCollection = event.value as ArrayCollection;
			}
			
			var tmpAuthorCommand:AuthorCommand = new AuthorCommand();
			tmpAuthorCommand.getAuthor(onGitAuthorDetection);
		}
		
		private function onPullRequest(event:Event):void
		{
			new PullCommand();
		}
		
		private function onPushRequest(event:Event):void
		{
			new PushCommand();
		}
		
		private function onAuthSuccessToPush(event:Event):void
		{
			if (gitAuthWindow.userObject) 
			{
				if (gitAuthWindow.userObject.save) 
				{
					modelAgainstProject[model.activeProject].sessionUser = gitAuthWindow.userObject.userName;
					modelAgainstProject[model.activeProject].sessionPassword = gitAuthWindow.userObject.password;
					
					new PushCommand();
				}
				else
				{
					new PushCommand(gitAuthWindow.userObject);
				}
			}
		}
		
		private function onRevertRequest(event:Event):void
		{
			if (!gitCommitWindow)
			{
				if (!checkOSXGitAccess()) return;
				
				checkGitAvailability();
				
				gitCommitWindow = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, GitCommitSelectionPopup, false) as GitCommitSelectionPopup;
				gitCommitWindow.title = "Modified File(s)";
				gitCommitWindow.type = GitCommitSelectionPopup.TYPE_REVERT;
				gitCommitWindow.isGitAvailable = isGitAvailable;
				gitCommitWindow.addEventListener(CloseEvent.CLOSE, onGitRevertWindowClosed);
				PopUpManager.centerPopUp(gitCommitWindow);
				
				// we let the popup opened completely
				// then run the following process else
				// there could be a hold before appearing
				// the window until folling process is finished
				gitCommitWindow.callLater(function():void
				{
					if (!dispatcher.hasEventListener(CheckDifferenceCommand.GIT_DIFF_CHECKED))
						dispatcher.addEventListener(CheckDifferenceCommand.GIT_DIFF_CHECKED, onGitDiffChecked, false, 0, true);
					new CheckDifferenceCommand();
				});
			}
			else
			{
				PopUpManager.bringToFront(gitCommitWindow);
			}
		}
		
		private function onGitRevertWindowClosed(event:CloseEvent):void
		{
			if (gitCommitWindow.isSubmit) 
			{
				new RevertCommand(gitCommitWindow.commitDiffCollection);
			}
			
			gitCommitWindow.removeEventListener(CloseEvent.CLOSE, onGitCommitWindowClosed);
			PopUpManager.removePopUp(gitCommitWindow);
			gitCommitWindow = null;
		}
		
		private function onNewBranchRequest(event:Event):void
		{
			if (!gitBranchSelectionWindow)
			{
				if (!checkOSXGitAccess()) return;
				
				checkGitAvailability();
				
				gitNewBranchWindow = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, GitNewBranchPopup, false) as GitNewBranchPopup;
				gitNewBranchWindow.title = "New Branch";
				gitNewBranchWindow.isGitAvailable = isGitAvailable;
				gitNewBranchWindow.addEventListener(CloseEvent.CLOSE, onGitNewBranchWindowClosed);
				gitNewBranchWindow.addEventListener(GitNewBranchPopup.VALIDATE_NAME, onNameValidationRequest);
				PopUpManager.centerPopUp(gitNewBranchWindow);
			}
			else
			{
				PopUpManager.bringToFront(gitNewBranchWindow);
			}
		}
		
		private function onGitNewBranchWindowClosed(event:CloseEvent):void
		{
			var newBranchDetails:Object = gitNewBranchWindow.submitObject;
			
			gitNewBranchWindow.removeEventListener(CloseEvent.CLOSE, onGitNewBranchWindowClosed);
			gitNewBranchWindow.removeEventListener(GitNewBranchPopup.VALIDATE_NAME, onNameValidationRequest);
			PopUpManager.removePopUp(gitNewBranchWindow);
			gitNewBranchWindow = null;
			
			if (newBranchDetails)
			{
				new CreateCheckoutNewBranchCommand(newBranchDetails.name, newBranchDetails.pushToRemote);
			}
		}
		
		private function onNameValidationRequest(event:GeneralEvent):void
		{
			new CheckBranchNameAvailabilityCommand(event.value as String, onNameValidatedByGit);
		}
		
		private function onNameValidatedByGit(value:String):void
		{
			gitNewBranchWindow.onNameValidatedByGit(value);
		}
		
		private function onChangeBranchRequest(event:Event):void
		{
			if (!dispatcher.hasEventListener(GetCurrentBranchCommand.GIT_REMOTE_BRANCH_LIST_RECEIVED))
				dispatcher.addEventListener(GetCurrentBranchCommand.GIT_REMOTE_BRANCH_LIST_RECEIVED, onGitRemoteBranchListReceived, false, 0, true);
			new GitSwitchBranchCommand();
		}
		
		private function onGitRemoteBranchListReceived(event:GeneralEvent):void
		{
			dispatcher.removeEventListener(GetCurrentBranchCommand.GIT_REMOTE_BRANCH_LIST_RECEIVED, onGitRemoteBranchListReceived);
			if (!gitBranchSelectionWindow)
			{
				if (!checkOSXGitAccess()) return;
				
				checkGitAvailability();
				
				gitBranchSelectionWindow = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, GitBranchSelectionPopup, false) as GitBranchSelectionPopup;
				gitBranchSelectionWindow.title = "Select Branch";
				gitBranchSelectionWindow.isGitAvailable = isGitAvailable;
				gitBranchSelectionWindow.branchCollection = event.value as ArrayCollection;
				gitBranchSelectionWindow.addEventListener(CloseEvent.CLOSE, onGitBranchSelectionWindowClosed);
				PopUpManager.centerPopUp(gitBranchSelectionWindow);
			}
			else
			{
				PopUpManager.bringToFront(gitBranchSelectionWindow);
			}
		}
		
		private function onGitBranchSelectionWindowClosed(event:CloseEvent):void
		{
			gitBranchSelectionWindow.removeEventListener(CloseEvent.CLOSE, onGitBranchSelectionWindowClosed);
			
			var selectedBranch:GenericSelectableObject = gitBranchSelectionWindow.isSubmit ? gitBranchSelectionWindow.lstBranches.selectedItem as GenericSelectableObject : null;
			
			PopUpManager.removePopUp(gitBranchSelectionWindow);
			gitBranchSelectionWindow = null;
			
			if (selectedBranch) 
			{
				new GitChangeBranchToCommand(selectedBranch);
			}
		}
		
		private function onMenuTypeUpdateAgainstGit(event:ProjectEvent):void
		{
			// don't go for a check if already decided as a git project
			// or a project is not permitted to access as a git repository on sandbox macos
			if (event.project.menuType.indexOf(ProjectMenuTypes.GIT_PROJECT) != -1 ||
				projectsNotAcceptedByUserToPermitAsGitOnMacOS[event.project.folderLocation.fileBridge.nativePath] != undefined ||
				!isGitAvailable) 
			{
				// following will enable/disable Moonshine top menus based on project
				dispatcher.dispatchEvent(new Event(MenuPlugin.REFRESH_MENU_STATE));
				return;
			}
			
			new CheckIsGitRepositoryCommand(event.project);
		}
		
		private function onGitRepositoryTested(event:GeneralEvent):void
		{
			if (event.value && !gitRepositoryPermissionWindow)
			{
				gitRepositoryPermissionWindow = new GitRepositoryPermissionPopup;
				gitRepositoryPermissionWindow.project = event.value.project;
				gitRepositoryPermissionWindow.gitRootLocation = event.value.gitRootLocation;
				gitRepositoryPermissionWindow.horizontalCenter = gitRepositoryPermissionWindow.verticalCenter = 0;
				gitRepositoryPermissionWindow.addEventListener(Event.CLOSE, onGitRepositoryPermissionClosed, false, 0, true);
				FlexGlobals.topLevelApplication.addElement(gitRepositoryPermissionWindow);
			}
		}
		
		private function onGitRepositoryPermissionClosed(event:Event):void
		{
			gitRepositoryPermissionWindow.removeEventListener(Event.CLOSE, onGitRepositoryPermissionClosed);
			
			var isAccepted:Boolean = gitRepositoryPermissionWindow.isAccepted;
			var tmpProject:ProjectVO = gitRepositoryPermissionWindow.project;
			
			FlexGlobals.topLevelApplication.removeElement(gitRepositoryPermissionWindow);
			gitRepositoryPermissionWindow = null;

			if (isAccepted) 
			{
				tmpProject.menuType += ","+ ProjectMenuTypes.GIT_PROJECT;
				
				checkOSXGitAccess();
				new CheckIsGitRepositoryCommand(tmpProject);
			}
			else
			{
				projectsNotAcceptedByUserToPermitAsGitOnMacOS[tmpProject.folderLocation.fileBridge.nativePath] = true;
			}
		}
		
		private function openAuthentication(onComplete:MethodDescriptor=null):void
		{
			if (!gitAuthWindow)
			{
				if (!checkOSXGitAccess()) return;
				
				checkGitAvailability();
				
				gitAuthWindow = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, GitAuthenticationPopup, true) as GitAuthenticationPopup;
				gitAuthWindow.title = "Git Needs Authentication";
				gitAuthWindow.isGitAvailable = isGitAvailable;
				gitAuthWindow.type = VersionControlTypes.GIT;
				gitAuthWindow.onComplete = onComplete;
				gitAuthWindow.addEventListener(CloseEvent.CLOSE, onGitAuthWindowClosed);
				gitAuthWindow.addEventListener(GitAuthenticationPopup.AUTH_SUBMITTED, onAuthSuccessToPush);
				PopUpManager.centerPopUp(gitAuthWindow);
			}
			
			/*
			 * @local
			 */
			function onGitAuthWindowClosed(event:CloseEvent):void
			{
				gitAuthWindow.removeEventListener(CloseEvent.CLOSE, onGitAuthWindowClosed);
				gitAuthWindow.removeEventListener(GitAuthenticationPopup.AUTH_SUBMITTED, onAuthSuccessToPush);
				PopUpManager.removePopUp(gitAuthWindow);
				gitAuthWindow = null;
			}
		}
	}
}