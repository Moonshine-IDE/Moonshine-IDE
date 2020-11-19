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
	import actionScripts.events.GeneralEvent;
	import actionScripts.events.WorkerEvent;
	import actionScripts.plugins.git.model.ConstructorDescriptor;
	import actionScripts.plugins.git.model.GitProjectVO;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.vo.NativeProcessQueueVO;

	public class CreateCheckoutNewBranchCommand extends GitCommandBase
	{
		private static const GIT_CHECKOUT_NEW_BRANCH:String = "gitCheckoutNewBranch";
		
		public function CreateCheckoutNewBranchCommand(name:String, pushToOrigin:Boolean)
		{
			super();
			
			if (!model.activeProject) return;
			
			var tmpModel:GitProjectVO = plugin.modelAgainstProject[model.activeProject];
			queue = new Vector.<Object>();
			
			// https://stackoverflow.com/questions/1519006/how-do-you-create-a-remote-git-branch
			addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +" checkout -b $'"+ UtilsCore.getEncodedForShell(name) +"'" : gitBinaryPathOSX +'&&checkout&&-b&&'+ UtilsCore.getEncodedForShell(name), false, GIT_CHECKOUT_NEW_BRANCH));
			
			pendingProcess.push(new ConstructorDescriptor(GetCurrentBranchCommand));
			if (pushToOrigin)
			{
				dispatcher.addEventListener(GetCurrentBranchCommand.GIT_REMOTE_BRANCH_LIST_RECEIVED, onCurrentBranchNameFetched);
			}
			
			notice("Trying to switch branch...");
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:model.activeProject.folderLocation.fileBridge.nativePath}, subscribeIdToWorker);
		}
		
		override protected function listOfProcessEnded():void
		{
			switch (processType)
			{
				case GIT_CHECKOUT_NEW_BRANCH:
					refreshProjectTree(); // important
					success("...process completed");
					checkCurrentEditorForModification();
					break;
			}
		}
		
		private function onCurrentBranchNameFetched(event:GeneralEvent):void
		{
			dispatcher.removeEventListener(GetCurrentBranchCommand.GIT_REMOTE_BRANCH_LIST_RECEIVED, onCurrentBranchNameFetched);
			new PushCommand();
		}
	}
}