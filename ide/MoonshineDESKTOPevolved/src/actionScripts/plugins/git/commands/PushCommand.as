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
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.NativeProcessQueueVO;

	public class PushCommand extends GitCommandBase
	{
		private const GIT_PUSH:String = "gitPush";
		
		public function PushCommand(userObject:Object=null)
		{
			super();
			
			if (!model.activeProject) return;
			
			var tmpModel:GitProjectVO = plugin.modelAgainstProject[model.activeProject];
			var userName:String;
			var password:String;
			
			userName = tmpModel.sessionUser ? tmpModel.sessionUser : (userObject ? userObject.userName : null);
			password = tmpModel.sessionPassword ? tmpModel.sessionPassword : (userObject ? userObject.password : null);
			
			queue = new Vector.<Object>();
			
			// we'll not hold from executing push command if we do not have
			// any immediate credential available but will execute with
			// following options -
			// 1. credential could be saved to the user's system (i.e. keychain) so we might not need to inject that separately
			// 2. executing the command may ask for credential - we shall detect and ask user to enter the same
			
			if (!userName && !password)
			{
				addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +" push -v origin $'"+ UtilsCore.getEncodedForShell(tmpModel.currentBranch) +"'" : gitBinaryPathOSX +'&&push&&-v&&origin&&'+ UtilsCore.getEncodedForShell(tmpModel.currentBranch), false, GIT_PUSH, model.activeProject.folderLocation.fileBridge.nativePath));
			}
			else
			{
				//git push https://user:pass@github.com/user/project.git
				addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +" push https://"+ userName +":"+ password +"@"+ tmpModel.remoteURL +".git $'"+ UtilsCore.getEncodedForShell(tmpModel.currentBranch) +"'" : gitBinaryPathOSX +'&&push&&https://'+ userName +':'+ password +'@'+ tmpModel.remoteURL +'.git&&'+ UtilsCore.getEncodedForShell(tmpModel.currentBranch), false, GIT_PUSH, model.activeProject.folderLocation.fileBridge.nativePath));
			}
			
			isErrorEncountered = false;
			warning("Git push requested...");
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Requested", "Push ", false));
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:model.activeProject.folderLocation.fileBridge.nativePath}, subscribeIdToWorker);
		}
		
		override protected function listOfProcessEnded():void
		{
			// terminate if error thrown 
			if (isErrorEncountered) return;
			
			switch (processType)
			{
				case GIT_PUSH:
					success("...process completed");
					break;
			}
		}
		
		override protected function shellData(value:Object):void
		{
			var match:Array;
			var tmpQueue:Object = value.queue; /** type of NativeProcessQueueVO **/
			var tmpProject:ProjectVO;
			
			switch(tmpQueue.processType)
			{
				case GIT_PUSH:
				{
					if (value.output.toLowerCase().match(/fatal.*username/) || 
						value.output.toLowerCase().match(/permission.*denied/))
					{
						// we'll need user to authenticate
						plugin.requestToAuthenticate();
						return;
					}
					
					match = value.output.toLowerCase().match(/invalid username/);
					if (match)
					{
						// reset model information if saved by the user
						tmpProject = UtilsCore.getProjectByPath(tmpQueue.extraArguments[0]);
						plugin.modelAgainstProject[tmpProject].sessionUser = null; 
						plugin.modelAgainstProject[tmpProject].sessionPassword = null;
					}
					break;
				}
			}
			
			// call super - it might have some essential
			// commands to run
			super.shellData(value);
		}
	}
}