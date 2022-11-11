////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.svn
{
	import actionScripts.plugins.versionControl.VersionControlUtils;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.filesystem.File;

	import mx.collections.ArrayCollection;

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
	import moonshine.haxeScripts.valueObjects.ComponentTypes;
	import moonshine.haxeScripts.valueObjects.ComponentVO;
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

			var repositoryItem:RepositoryItemVO = VersionControlUtils.getRepositoryItemByLocalPath(model.activeProject.projectFolder.nativePath);
			var provider:SubversionProvider = new SubversionProvider();
			provider.executable = new File(svnBinaryPath);
			trace(model.activeProject.projectRemotePath);
			provider.commit(model.activeProject.folderLocation, null, user, password, commitInfo, model.activeProject.isTrustServerCertificateSVN, repositoryItem);
		}
		
		protected function handleUpdateRequest(event:Event, user:String=null, password:String=null):void
		{
			if (!model.activeProject) return;

			var repositoryItem:RepositoryItemVO = VersionControlUtils.getRepositoryItemByLocalPath(model.activeProject.projectFolder.nativePath);
			var provider:SubversionProvider = new SubversionProvider();
			provider.executable = new File(svnBinaryPath);
			provider.update(model.activeProject.folderLocation.fileBridge.getFile as File, user, password, model.activeProject.isTrustServerCertificateSVN, repositoryItem);
		}
		
		protected function isVersioned(folder:FileLocation):Boolean
		{
			return folder.fileBridge.resolvePath(".svn/wc.db").fileBridge.exists;
		}
	}
}