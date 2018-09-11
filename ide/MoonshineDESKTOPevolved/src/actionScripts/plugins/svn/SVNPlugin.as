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
package actionScripts.plugins.svn
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.filesystem.File;
	
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import mx.resources.ResourceManager;
	
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.SaveFileEvent;
	import actionScripts.events.SettingsEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.event.SetSettingsEvent;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugins.git.GitHubPlugin;
	import actionScripts.plugins.svn.event.SVNEvent;
	import actionScripts.plugins.svn.provider.SubversionProvider;
	import actionScripts.ui.menu.MenuPlugin;
	import actionScripts.ui.menu.vo.ProjectMenuTypes;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;
	
	import components.popup.GitAuthenticationPopup;
	import components.popup.SourceControlCheckout;

	public class SVNPlugin extends PluginBase implements ISettingsProvider
	{
		public static const CHECKOUT_REQUEST:String = "checkoutRequestEvent";
		public static const COMMIT_REQUEST:String = "svnCommitRequest";
		public static const UPDATE_REQUEST:String = "svnUpdateRequest";
		public static const SVN_TEST_COMPLETED:String = "svnTestCompleted";
		
		override public function get name():String			{ return "Subversion"; }
		override public function get author():String		{ return "Moonshine Project Team"; }
		override public function get description():String	{ return ResourceManager.getInstance().getString('resources','plugin.desc.subversion'); }
		
		public var svnBinaryPath:String;
		
		private var checkoutWindow:SourceControlCheckout;
		private var gitAuthWindow:GitAuthenticationPopup;
		private var failedMethodObjectBeforeAuth:Array;
		
		override public function activate():void
		{
			super.activate();
			
			dispatcher.addEventListener(SaveFileEvent.FILE_SAVED, handleFileSave);
			dispatcher.addEventListener(ProjectEvent.ADD_PROJECT, handleProjectOpen);
			dispatcher.addEventListener(CHECKOUT_REQUEST, handleCheckoutRequest);
			dispatcher.addEventListener(COMMIT_REQUEST, handleCommitRequest);
			dispatcher.addEventListener(UPDATE_REQUEST, handleUpdateRequest);
			dispatcher.addEventListener(ProjectEvent.CHECK_SVN_PROJECT, handleCheckSVNRepository);
			dispatcher.addEventListener(SVNEvent.OSX_XCODE_PERMISSION_GIVEN, onOSXodePermission);
			dispatcher.addEventListener(SVNEvent.SVN_AUTH_REQUIRED, onSVNAuthRequires);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			
			dispatcher.removeEventListener(SaveFileEvent.FILE_SAVED, handleFileSave);
			dispatcher.removeEventListener(ProjectEvent.ADD_PROJECT, handleProjectOpen);
			dispatcher.removeEventListener(CHECKOUT_REQUEST, handleCheckoutRequest);
			dispatcher.removeEventListener(COMMIT_REQUEST, handleCommitRequest);
			dispatcher.removeEventListener(UPDATE_REQUEST, handleUpdateRequest);
			dispatcher.removeEventListener(ProjectEvent.CHECK_SVN_PROJECT, handleCheckSVNRepository);
			dispatcher.removeEventListener(SVNEvent.OSX_XCODE_PERMISSION_GIVEN, onOSXodePermission);
			dispatcher.removeEventListener(SVNEvent.SVN_AUTH_REQUIRED, onSVNAuthRequires);
		}
		
		override public function resetSettings():void
		{
			svnBinaryPath = null;
			ConstantsCoreVO.IS_SVN_OSX_AVAILABLE = false;
			dispatcher.dispatchEvent(new Event(MenuPlugin.CHANGE_SVN_CHECKOUT_PERMISSION_LABEL));
			
			for each (var i:ProjectVO in model.projects)
			{
				(i as AS3ProjectVO).menuType = (i as AS3ProjectVO).menuType.replace(","+ ProjectMenuTypes.SVN_PROJECT, "");
			}
			
			// following will enable/disable Moonshine top menus based on project
			if (model.activeProject) dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.ACTIVE_PROJECT_CHANGED, model.activeProject));
		}
		
		public function getSettingsList():Vector.<ISetting>
		{
			var binaryPath:PathSetting = new PathSetting(this,'svnBinaryPath', 'SVN Binary', false);
			binaryPath.setMessage("SVN binary needs to be command-line compliant", PathSetting.MESSAGE_IMPORTANT);
			
			return Vector.<ISetting>([
				binaryPath
			]);
		}
		
		/*public function getMenu():MenuItem
		{
			var EditMenu:MenuItem = new MenuItem('Subversion');
			EditMenu.parents = ["Subversion"];
			EditMenu.items = new Vector.<MenuItem>();
			EditMenu.items.push(new MenuItem("Checkout", null, [], CHECKOUT_REQUEST));
			return EditMenu;
			
		}*/
		
		protected function handleFileSave(event:SaveFileEvent):void
		{
			
		}
		
		protected function onOSXodePermission(event:SVNEvent):void
		{
			svnBinaryPath = event.url;
			
			// save the settings
			var thisSettings: Vector.<ISetting> = getSettingsList();
			var pathSettingToDefaultSDK:PathSetting = thisSettings[0] as PathSetting;
			dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING, null, "actionScripts.plugins.svn::SVNPlugin", thisSettings));
			
			// if an opened project lets test it if Git repository
			if (model.activeProject) handleProjectOpen(new ProjectEvent(ProjectEvent.ADD_PROJECT, model.activeProject));
		}
		
		protected function handleProjectOpen(event:ProjectEvent):void
		{
			// Check if project is versioned with SVN
			if (isVersioned(event.project.folderLocation) == false) return;
			
			// Check if we have a SVN binary
			if (!svnBinaryPath || svnBinaryPath == "") return;
			
			// Create new provider
			var provider:SubversionProvider = new SubversionProvider();
			provider.executable = new File(svnBinaryPath);
			provider.root = event.project.folderLocation.fileBridge.getFile as File;
		}
		
		protected function handleCheckSVNRepository(event:ProjectEvent):void
		{
			// Check if we have a SVN binary
			if (!svnBinaryPath || svnBinaryPath == "") return;
			
			// don't go for a check if already decided as svn project
			if ((event.project as AS3ProjectVO).menuType.indexOf(ProjectMenuTypes.SVN_PROJECT) == -1) 
			{
				if (event.project.folderLocation.fileBridge.resolvePath(".svn/wc.db").fileBridge.exists)
				{
					(event.project as AS3ProjectVO).menuType += ","+ ProjectMenuTypes.SVN_PROJECT;
				}
			}
		}
		
		protected function handleCheckoutRequest(event:Event):void
		{
			// Check if we have a SVN binary
			// for Windows only
			// @note SK
			// Need to check OSX svn existence someway
			if (!svnBinaryPath || svnBinaryPath == "")
			{
				if (ConstantsCoreVO.IS_MACOS) dispatcher.dispatchEvent(new Event(GitHubPlugin.RELAY_SVN_XCODE_REQUEST));
				else dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, "actionScripts.plugins.svn::SVNPlugin"));
				return;
			}
			
			if (!checkoutWindow)
			{
				checkoutWindow = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, SourceControlCheckout, false) as SourceControlCheckout;
				checkoutWindow.title = "Checkout Repository";
				checkoutWindow.type = SourceControlCheckout.TYPE_SVN;
				checkoutWindow.addEventListener(CloseEvent.CLOSE, onCheckoutWindowClosed);
				checkoutWindow.addEventListener(SVNEvent.EVENT_CHECKOUT, onCheckoutWindowSubmitted);
				
				dispatcher.addEventListener(SVNEvent.SVN_ERROR, onCheckoutOutputEvent);
				dispatcher.addEventListener(SVNEvent.SVN_RESULT, onCheckoutOutputEvent);
				
				PopUpManager.centerPopUp(checkoutWindow);
			}
			else
			{
				PopUpManager.bringToFront(checkoutWindow);
			}
		}
		
		protected function onCheckoutWindowSubmitted(event:SVNEvent):void
		{
			var submitObject:Object = checkoutWindow.submitObject;
			if (submitObject)
			{
				//git: submitObject.url, submitObject.target
				//svn: submitObject.url, submitObject.target, submitObject.user, submitObject.password
				var provider:SubversionProvider = new SubversionProvider();
				provider.executable = new File(svnBinaryPath);
				provider.checkout(new SVNEvent(SVNEvent.EVENT_CHECKOUT, new File(submitObject.target), submitObject.url, null, submitObject.user ? {username:submitObject.user, password:submitObject.password} : null), submitObject.trustCertificate);
			}
		}
		
		protected function onCheckoutWindowClosed(event:CloseEvent):void
		{
			checkoutWindow.removeEventListener(CloseEvent.CLOSE, onCheckoutWindowClosed);
			checkoutWindow.removeEventListener(SVNEvent.EVENT_CHECKOUT, onCheckoutWindowSubmitted);
			dispatcher.removeEventListener(SVNEvent.SVN_ERROR, onCheckoutOutputEvent);
			dispatcher.removeEventListener(SVNEvent.SVN_RESULT, onCheckoutOutputEvent);
			
			PopUpManager.removePopUp(checkoutWindow);
			checkoutWindow = null;
		}
		
		protected function onCheckoutOutputEvent(event:SVNEvent):void
		{
			if (event.type == SVNEvent.SVN_ERROR) checkoutWindow.notifySVNCheckoutError();
			else checkoutWindow.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
		}
		
		protected function handleCommitRequest(event:Event, user:String=null, password:String=null, commitInfo:Object=null):void
		{
			if (!model.activeProject) return;
			
			var provider:SubversionProvider = new SubversionProvider();
			provider.executable = new File(svnBinaryPath);
			provider.commit(model.activeProject.folderLocation, null, user, password, commitInfo, (model.activeProject as AS3ProjectVO).isTrustServerCertificateSVN);
		}
		
		protected function handleUpdateRequest(event:Event, user:String=null, password:String=null):void
		{
			if (!model.activeProject) return;
			
			var provider:SubversionProvider = new SubversionProvider();
			provider.executable = new File(svnBinaryPath);
			provider.update(model.activeProject.folderLocation, user, password, (model.activeProject as AS3ProjectVO).isTrustServerCertificateSVN);
		}
		
		protected function isVersioned(folder:FileLocation):Boolean
		{
			if (!folder.fileBridge.exists) folder.fileBridge.createDirectory();
			
			var listing:Array = folder.fileBridge.getDirectoryListing();
			for each (var file:File in listing)
			{
				if (file.name == ".svn")
					return true;
			}
			return false;
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
				gitAuthWindow.type = GitAuthenticationPopup.TYPE_SVN;
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
						handleUpdateRequest(null, gitAuthWindow.userObject.userName, gitAuthWindow.userObject.password);
						break;
					case "commit":
						handleCommitRequest(null, gitAuthWindow.userObject.userName, gitAuthWindow.userObject.password, {files:failedMethodObjectBeforeAuth[1], message:failedMethodObjectBeforeAuth[2], runningForFile:failedMethodObjectBeforeAuth[3]});
						break;
				}
			}
		}
	}
}