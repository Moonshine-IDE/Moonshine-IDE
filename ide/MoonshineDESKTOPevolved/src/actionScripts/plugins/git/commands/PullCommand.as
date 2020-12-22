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
	import actionScripts.events.StatusBarEvent;
	import actionScripts.events.WorkerEvent;
	import actionScripts.plugins.git.model.GitProjectVO;
	import actionScripts.plugins.git.utils.GitUtils;
	import actionScripts.plugins.versionControl.VersionControlUtils;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.RepositoryItemVO;
	import actionScripts.vo.NativeProcessQueueVO;

	public class PullCommand extends GitCommandBase
	{
		public static const PULL_REQUEST:String = "gitPullRequest";
		
		public function PullCommand()
		{
			super();
			
			if (!model.activeProject) return;
			
			var tmpModel:GitProjectVO = plugin.modelAgainstProject[model.activeProject];
			queue = new Vector.<Object>();
			
			var calculatedURL:String;
			if (tmpModel && tmpModel.sessionUser)
			{
				calculatedURL = GitUtils.getCalculatedRemotePathWithAuth(tmpModel.remoteURL, tmpModel.sessionUser, tmpModel.sessionPassword);
			}
			
			var command:String;
			if (ConstantsCoreVO.IS_MACOS)
			{
				command = gitBinaryPathOSX +" pull ";
				if (calculatedURL) command += calculatedURL;
				command += " --progress -v --no-rebase";
			}
			else
			{
				command = gitBinaryPathOSX +'&&pull';
				if (calculatedURL) command += '&&'+ calculatedURL;
				command += '&&--progress&&-v&&--no-rebase';
			}
			
			addToQueue(new NativeProcessQueueVO(command, false, PULL_REQUEST));
			
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Requested", "Pull ", false));
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:model.activeProject.folderLocation.fileBridge.nativePath}, subscribeIdToWorker);
		}
		
		override protected function shellData(value:Object):void
		{
			var tmpQueue:Object = value.queue; /** type of NativeProcessQueueVO **/
			var tmpProject:ProjectVO;
			
			switch(tmpQueue.processType)
			{
				case PULL_REQUEST:
				{
					if (testMessageIfNeedsAuthentication(value.output))
					{
						var userName:String;
						var tmpModel:GitProjectVO = plugin.modelAgainstProject[model.activeProject];
						if (tmpModel && tmpModel.sessionUser) userName = tmpModel.sessionUser;
						else if (tmpModel)
						{
							VersionControlUtils.REPOSITORIES.source.some(function(element:RepositoryItemVO, index:int, arr:Array):Boolean {
								if (element.url == tmpModel.remoteURL)
								{
									userName = element.userName;
									return true;
								}
								return false;
							});
						}
						
						openAuthentication(userName);
					}
					break;
				}
			}
			
			// call super - it might have some essential
			// commands to run
			super.shellData(value);
		}
		
		override protected function onAuthenticationSuccess(username:String, password:String):void
		{
			if (username && password)
			{
				super.onAuthenticationSuccess(username, password);
				new PullCommand();
			}
		}
		
		override protected function listOfProcessEnded():void
		{
			switch (processType)
			{
				case PULL_REQUEST:
					refreshProjectTree(); // important
					success("...process completed");
					checkCurrentEditorForModification();
					break;
			}
		}
	}
}