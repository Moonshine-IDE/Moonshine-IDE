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
	import actionScripts.events.SettingsEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.event.SetSettingsEvent;
	import actionScripts.plugin.settings.vo.AbstractSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugins.git.GitHubPlugin;
	import actionScripts.plugins.svn.event.SVNEvent;
	import actionScripts.plugins.svn.provider.SubversionProvider;
	import actionScripts.plugins.versionControl.event.VersionControlEvent;
	import actionScripts.ui.menu.MenuPlugin;
	import actionScripts.ui.menu.vo.ProjectMenuTypes;
	import actionScripts.utils.HelperUtils;
	import actionScripts.utils.PathSetupHelperUtil;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ComponentTypes;
	import actionScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.RepositoryItemVO;
	import actionScripts.valueObjects.VersionControlTypes;
	
	import components.popup.SourceControlCheckout;

	public class SVNPlugin extends PluginBase implements ISettingsProvider
	{
		public static const CHECKOUT_REQUEST:String = "checkoutRequestEvent";
		public static const COMMIT_REQUEST:String = "svnCommitRequest";
		public static const UPDATE_REQUEST:String = "svnUpdateRequest";
		public static const SVN_TEST_COMPLETED:String = "svnTestCompleted";
		
		public static const NAMESPACE:String = "actionScripts.plugins.svn::SVNPlugin";
		
		override public function get name():String			{ return "Subversion"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String	{ return ResourceManager.getInstance().getString('resources','plugin.desc.subversion'); }
		
		private var _svnBinaryPath:String;
		public function get svnBinaryPath():String
		{
			return _svnBinaryPath;
		}
		public function set svnBinaryPath(value:String):void
		{
			if (_svnBinaryPath != value)
			{
				model.svnPath = _svnBinaryPath = value;
				dispatcher.dispatchEvent(new Event(MenuPlugin.CHANGE_SVN_CHECKOUT_PERMISSION_LABEL));
				if (value != "") 
				{
					checkOpenedProjectsIfVersioned();
				}
				else 
				{
					removeIfAlreadyVersioned();
					PathSetupHelperUtil.updateSVNPath(null);
				}
			}
		}
		
		private var checkoutWindow:SourceControlCheckout;
		private var failedMethodObjectBeforeAuth:Array;
		private var pathSetting:PathSetting;
		
		override public function activate():void
		{
			super.activate();
			
			dispatcher.addEventListener(ProjectEvent.ADD_PROJECT, handleProjectOpen);
			dispatcher.addEventListener(CHECKOUT_REQUEST, handleCheckoutRequest);
			dispatcher.addEventListener(COMMIT_REQUEST, handleCommitRequest);
			dispatcher.addEventListener(UPDATE_REQUEST, handleUpdateRequest);
			dispatcher.addEventListener(ProjectEvent.CHECK_SVN_PROJECT, handleCheckSVNRepository);
			dispatcher.addEventListener(VersionControlEvent.LOAD_REMOTE_SVN_LIST, onLoadRemoteSVNList);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			
			dispatcher.removeEventListener(ProjectEvent.ADD_PROJECT, handleProjectOpen);
			dispatcher.removeEventListener(CHECKOUT_REQUEST, handleCheckoutRequest);
			dispatcher.removeEventListener(COMMIT_REQUEST, handleCommitRequest);
			dispatcher.removeEventListener(UPDATE_REQUEST, handleUpdateRequest);
			dispatcher.removeEventListener(ProjectEvent.CHECK_SVN_PROJECT, handleCheckSVNRepository);
			dispatcher.removeEventListener(VersionControlEvent.LOAD_REMOTE_SVN_LIST, onLoadRemoteSVNList);
		}
		
		override public function resetSettings():void
		{
			svnBinaryPath = null;
			dispatcher.dispatchEvent(new Event(MenuPlugin.CHANGE_SVN_CHECKOUT_PERMISSION_LABEL));
			
			removeIfAlreadyVersioned();
		}
		
		public function getSettingsList():Vector.<ISetting>
		{
			onSettingsClose();
			pathSetting = new PathSetting(this,'svnBinaryPath', 'SVN Binary', false, svnBinaryPath);
			pathSetting.addEventListener(AbstractSetting.PATH_SELECTED, onSDKPathSelected, false, 0, true);
			setUsualMessage();
			
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
			var tmpComponent:ComponentVO = HelperUtils.getComponentByType(ComponentTypes.TYPE_SVN);
			if (tmpComponent)
			{
				var isValidSDKPath:Boolean = HelperUtils.isValidExecutableBy(ComponentTypes.TYPE_SVN, pathSetting.stringValue, tmpComponent.pathValidation);
				if (!isValidSDKPath)
				{
					pathSetting.setMessage("Invalid path: Path must contain "+ tmpComponent.pathValidation +".", AbstractSetting.MESSAGE_CRITICAL);
				}
				else
				{
					setUsualMessage();
				}
			}
		}
		
		private function setUsualMessage():void
		{
			var svnMessage:String = "SVN binary needs to be command-line compliant";
			//if (ConstantsCoreVO.IS_MACOS) svnMessage += "\nFor most users, it will be easier to set this with \"Subversion > Grant Permission\"";
			
			pathSetting.setMessage(svnMessage, AbstractSetting.MESSAGE_IMPORTANT);
		}
		
		protected function checkOpenedProjectsIfVersioned():void
		{
			for each (var project:ProjectVO in model.projects)
			{
				handleCheckSVNRepository(new ProjectEvent(ProjectEvent.CHECK_SVN_PROJECT, project));
			}
		}
		
		protected function removeIfAlreadyVersioned():void
		{
			for each (var i:ProjectVO in model.projects)
			{
				i.menuType = i.menuType.replace(","+ ProjectMenuTypes.SVN_PROJECT, "");
			}
			
			// following will enable/disable Moonshine top menus based on project
			if (model.activeProject)
			{
				dispatcher.dispatchEvent(new Event(MenuPlugin.REFRESH_MENU_STATE));
			}
		}
		
		protected function handleProjectOpen(event:ProjectEvent):void
		{
			handleCheckSVNRepository(event);
		}
		
		protected function handleCheckSVNRepository(event:ProjectEvent):void
		{
			// Check if we have a SVN binary
			if (!UtilsCore.isSVNPresent()) return;
			
			// don't go for a check if already decided as svn project
			if (event.project.menuType.indexOf(ProjectMenuTypes.SVN_PROJECT) == -1) 
			{
				var provider:SubversionProvider = new SubversionProvider();
				provider.executable = new File(svnBinaryPath);
				provider.checkIfSVNRepository(event.project);
			}
		}
		
		protected function onLoadRemoteSVNList(event:VersionControlEvent):void
		{
			var provider:SubversionProvider = new SubversionProvider();
			provider.executable = new File(svnBinaryPath);
			provider.loadRemoteList(event.value.repository, event.value.onCompletion);
		}
		
		protected function handleCheckoutRequest(event:Event):void
		{
			// Check if we have a SVN binary
			// for Windows only
			// @note SK
			// Need to check OSX svn existence someway
			if (!UtilsCore.isSVNPresent())
			{
				error("Error: Subversion path has not been set.");
				dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, NAMESPACE));
				return;
			}
			
			if (!checkoutWindow)
			{
				checkoutWindow = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, SourceControlCheckout, true) as SourceControlCheckout;
				checkoutWindow.title = "Checkout Repository";
				checkoutWindow.type = VersionControlTypes.SVN;
				if (event is VersionControlEvent) checkoutWindow.editingRepository = (event as VersionControlEvent).value as RepositoryItemVO;
				checkoutWindow.addEventListener(CloseEvent.CLOSE, onCheckoutWindowClosed);
				checkoutWindow.addEventListener(VersionControlEvent.CLONE_CHECKOUT_REQUESTED, onCheckoutWindowSubmitted);
				
				PopUpManager.centerPopUp(checkoutWindow);
			}
			else
			{
				PopUpManager.bringToFront(checkoutWindow);
			}
		}
		
		protected function onCheckoutWindowSubmitted(event:VersionControlEvent):void
		{
			var submitObject:Object = checkoutWindow.submitObject;
			if (submitObject)
			{
				var provider:SubversionProvider = new SubversionProvider();
				provider.executable = new File(svnBinaryPath);
				provider.checkout(
					submitObject.url, 
					new File(submitObject.target), 
					submitObject.targetFolder, 
					(submitObject.repository as RepositoryItemVO).isTrustCertificate, 
					submitObject.repository, 
					submitObject.user ? submitObject.user : null, 
					submitObject.user ? submitObject.password : null);
			}
		}
		
		protected function onCheckoutWindowClosed(event:CloseEvent):void
		{
			checkoutWindow.removeEventListener(CloseEvent.CLOSE, onCheckoutWindowClosed);
			checkoutWindow.removeEventListener(VersionControlEvent.CLONE_CHECKOUT_REQUESTED, onCheckoutWindowSubmitted);
			
			PopUpManager.removePopUp(checkoutWindow);
			checkoutWindow = null;
		}
		
		protected function handleCommitRequest(event:Event, user:String=null, password:String=null, commitInfo:Object=null):void
		{
			if (!model.activeProject) return;
			
			var provider:SubversionProvider = new SubversionProvider();
			provider.executable = new File(svnBinaryPath);
			provider.commit(model.activeProject.folderLocation, null, user, password, commitInfo, model.activeProject.isTrustServerCertificateSVN);
		}
		
		protected function handleUpdateRequest(event:Event, user:String=null, password:String=null):void
		{
			if (!model.activeProject) return;
			
			var provider:SubversionProvider = new SubversionProvider();
			provider.executable = new File(svnBinaryPath);
			provider.update(model.activeProject.folderLocation.fileBridge.getFile as File, user, password, model.activeProject.isTrustServerCertificateSVN);
		}
		
		protected function isVersioned(folder:FileLocation):Boolean
		{
			return folder.fileBridge.resolvePath(".svn/wc.db").fileBridge.exists;
		}
	}
}