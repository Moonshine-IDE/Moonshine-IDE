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
package actionScripts.plugins.git.commands
{
	import actionScripts.plugins.git.utils.GitUtils;
	import actionScripts.valueObjects.ConstantsCoreVO;

	import mx.collections.ArrayCollection;
	
	import actionScripts.events.StatusBarEvent;
	import actionScripts.events.WorkerEvent;
	import actionScripts.plugins.git.model.ConstructorDescriptor;
	import actionScripts.plugins.git.model.GitProjectVO;
	import actionScripts.valueObjects.GenericSelectableObject;
	import actionScripts.vo.NativeProcessQueueVO;

import mx.utils.StringUtil;

public class GitSwitchBranchCommand extends GitCommandBase
	{
		public static const BRANCH_TYPE_REMOTE:String = "branchTypeRemote";
		public static const BRANCH_TYPE_LOCAL:String = "branchTypeLocal";

		private static const GIT_REMOTE_BRANCH_LIST:String = "getGitRemoteBranchList";

		public function GitSwitchBranchCommand(listingType:String=BRANCH_TYPE_LOCAL)
		{
			super();
			
			if (!model.activeProject) return;
			
			queue = new Vector.<Object>();

			var tmpModel:GitProjectVO = plugin.modelAgainstProject[model.activeProject];
			var calculatedURL:String;
			if (tmpModel && tmpModel.sessionUser)
			{
				calculatedURL = GitUtils.getCalculatedRemotePathWithAuth(tmpModel.remoteURL, tmpModel.sessionUser);
			}

			var gitFetchCommand:String = getPlatformMessage(' fetch'+ (calculatedURL ? ' '+ calculatedURL : ''));
			if (ConstantsCoreVO.IS_MACOS && calculatedURL)
			{
				var tmpExpFilePath:String = GitUtils.writeExpOnMacAuthentication(gitFetchCommand);
				addToQueue(new NativeProcessQueueVO('expect -f "'+ tmpExpFilePath +'" "'+ tmpModel.sessionPassword +'"', true, null));
			}
			else
			{
				addToQueue(new NativeProcessQueueVO(gitFetchCommand, false, null));
			}

			switch (listingType) {
				case BRANCH_TYPE_LOCAL:
					addToQueue(new NativeProcessQueueVO(getPlatformMessage(' branch'), false, GIT_REMOTE_BRANCH_LIST));
					break;
				case BRANCH_TYPE_REMOTE:
					addToQueue(new NativeProcessQueueVO(getPlatformMessage(' branch -r'), false, GIT_REMOTE_BRANCH_LIST));
					break;
				default:
					addToQueue(new NativeProcessQueueVO(getPlatformMessage(' branch --all'), false, GIT_REMOTE_BRANCH_LIST));
			}

			pendingProcess.push(new ConstructorDescriptor(GetCurrentBranchCommand)); // next method we need to fire when above done
			
			warning("Fetching branch details...");
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Requested", "Branch Details ", false));
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:model.activeProject.folderLocation.fileBridge.nativePath}, subscribeIdToWorker);
		}
		
		override protected function shellData(value:Object):void
		{
			var tmpQueue:Object = value.queue; /** type of NativeProcessQueueVO **/
			var isFatal:Boolean;

			if (value.output.match(/fatal: .*/)) isFatal = true;
			
			switch(tmpQueue.processType)
			{
				case GIT_REMOTE_BRANCH_LIST:
				{
					if (!isFatal) parseRemoteBranchList(value.output);
					return;
				}
			}
			
			// call super - it might have some essential
			// commands to run
			super.shellData(value);
		}

		override protected function shellError(value:Object):void
		{
			// call super - it might have some essential
			// commands to run.
			super.shellError(value);

			if (testMessageIfNeedsAuthentication(value.output))
			{
				openAuthentication(null);
			}
		}

		override protected function onAuthenticationSuccess(username:String, password:String):void
		{
			if (username && password)
			{
				super.onAuthenticationSuccess(username, password);
				new GitSwitchBranchCommand();
			}
		}
		
		private function parseRemoteBranchList(value:String):void
		{
			if (model.activeProject && plugin.modelAgainstProject[model.activeProject] != undefined)
			{
				var tmpModel:GitProjectVO = plugin.modelAgainstProject[model.activeProject];
				
				tmpModel.branchList = new ArrayCollection();
				var contentInLineBreaks:Array = value.split("\n");
				contentInLineBreaks.forEach(function(element:String, index:int, arr:Array):void
				{
					if (element != "" && element.indexOf("->") == -1)
					{
						if (element.indexOf("origin/") != -1)
						{
							tmpModel.branchList.addItem(new GenericSelectableObject(false, element.substr(element.indexOf("origin/")+7, element.length)));
						}
						else
						{
							if (element.indexOf("* ") != -1) element = element.replace(/\*\s+/, '');
							tmpModel.branchList.addItem(new GenericSelectableObject(false, StringUtil.trim(element)));
						}
					}
				});
			}
		}
	}
}