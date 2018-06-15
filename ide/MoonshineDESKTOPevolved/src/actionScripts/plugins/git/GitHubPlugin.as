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
	import flash.filesystem.File;
	
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	
	import components.popup.SourceControlCheckout;

    public class GitHubPlugin extends PluginBase implements IPlugin
	{
		public static const CLONE_REQUEST:String = "cloneRequest";
		public static const CHECKOUT_REQUEST:String = "checkoutRequestEvent";
		public static const COMMIT_REQUEST:String = "commitRequest";
		public static const PULL_REQUEST:String = "pullRequest";
		public static const PUSH_REQUEST: String = "pushRequest";
		public static const REFRESH_STATUS_REQUEST:String = "refreshStatusRequest";
		public static const NEW_BRANCH_REQUEST:String = "newBranchRequest";
		public static const CHANGE_BRANCH_REQUEST:String = "changeBranchRequest";
		
		override public function get name():String			{ return "GitHub"; }
		override public function get author():String		{ return "Moonshine Project Team"; }
		override public function get description():String	{ return "GitHub Plugin. Esc exits."; }
		
		public var gitBinaryPath:String;
		
		private var checkoutWindow:SourceControlCheckout;
		
		private var _processManager:GitProcessManager;
		protected function get processManager():GitProcessManager
		{
			if (!_processManager) 
			{
				_processManager = new GitProcessManager();
				_processManager.setGitAvailable = setGitAvailable;
				if (gitBinaryPath) _processManager.gitPath = new File(gitBinaryPath);
			}
			return _processManager;
		}
		
		override public function activate():void
		{
			super.activate();
			
			dispatcher.addEventListener(CLONE_REQUEST, onCloneRequest, false, 0, true);
			dispatcher.addEventListener(CHECKOUT_REQUEST, onCheckoutRequest, false, 0, true);
			dispatcher.addEventListener(COMMIT_REQUEST, onCommitRequest, false, 0, true);
			dispatcher.addEventListener(PULL_REQUEST, onPullRequest, false, 0, true);
			dispatcher.addEventListener(PUSH_REQUEST, onPushRequest, false, 0, true);
			dispatcher.addEventListener(REFRESH_STATUS_REQUEST, onRefreshRequest, false, 0, true);
			dispatcher.addEventListener(NEW_BRANCH_REQUEST, onNewBranchRequest, false, 0, true);
			dispatcher.addEventListener(CHANGE_BRANCH_REQUEST, onChangeBranchRequest, false, 0, true);
		}
		
		override public function deactivate():void 
		{
			super.deactivate();
			
			dispatcher.removeEventListener(CLONE_REQUEST, onCloneRequest);
			dispatcher.removeEventListener(CHECKOUT_REQUEST, onCheckoutRequest);
			dispatcher.removeEventListener(COMMIT_REQUEST, onCommitRequest);
			dispatcher.removeEventListener(PULL_REQUEST, onPullRequest);
			dispatcher.removeEventListener(PUSH_REQUEST, onPushRequest);
			dispatcher.removeEventListener(REFRESH_STATUS_REQUEST, onRefreshRequest);
			dispatcher.removeEventListener(NEW_BRANCH_REQUEST, onNewBranchRequest);
			dispatcher.removeEventListener(CHANGE_BRANCH_REQUEST, onChangeBranchRequest);
		}
		
		override public function resetSettings():void
		{
			gitBinaryPath = null;
		}
		
		protected function setGitAvailable(value:Boolean):void
		{
			if (checkoutWindow) checkoutWindow.isGitAvailable = value;
		}
		
		private function onCloneRequest(event:Event):void
		{
			if (!checkoutWindow)
			{
				processManager.checkGitAvailability();
				
				checkoutWindow = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, SourceControlCheckout, false) as SourceControlCheckout;
				checkoutWindow.title = "Clone Repository";
				checkoutWindow.type = SourceControlCheckout.TYPE_GIT;
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
			var submitObject:Object = checkoutWindow.submitObject;
			
			checkoutWindow.removeEventListener(CloseEvent.CLOSE, onCheckoutWindowClosed);
			PopUpManager.removePopUp(checkoutWindow);
			checkoutWindow = null;
			
			if (submitObject) processManager.clone(submitObject.url, submitObject.target);
		}
		
		private function onCheckoutRequest(event:Event):void
		{
			
		}
		
		private function onCommitRequest(event:Event):void
		{
			
		}
		
		private function onPullRequest(event:Event):void
		{
			
		}
		
		private function onPushRequest(event:Event):void
		{
			
		}
		
		private function onRefreshRequest(event:Event):void
		{
			
		}
		
		private function onNewBranchRequest(event:Event):void
		{
			
		}
		
		private function onChangeBranchRequest(event:Event):void
		{
			
		}
	}
}
