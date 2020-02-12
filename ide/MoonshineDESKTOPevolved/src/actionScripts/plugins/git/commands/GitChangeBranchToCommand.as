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
	import actionScripts.events.WorkerEvent;
	import actionScripts.plugins.git.model.ConstructorDescriptor;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.GenericSelectableObject;
	import actionScripts.vo.NativeProcessQueueVO;

	public class GitChangeBranchToCommand extends GitCommandBase
	{
		private static const GIT_CHECKOUT_BRANCH:String = "gitCheckoutToBranch";
		
		public function GitChangeBranchToCommand(value:GenericSelectableObject)
		{
			super();
			
			if (!model.activeProject) return;
			
			queue = new Vector.<Object>();
			
			addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +" checkout $'"+ UtilsCore.getEncodedForShell(value.data as String) +"'" : gitBinaryPathOSX +'&&checkout&&'+ UtilsCore.getEncodedForShell(value.data as String), false, GIT_CHECKOUT_BRANCH));
			pendingProcess.push(new ConstructorDescriptor(GetCurrentBranchCommand));
			
			notice("Trying to switch branch...");
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:model.activeProject.folderLocation.fileBridge.nativePath}, subscribeIdToWorker);
		}
		
		override protected function shellTick(value:Object /** type of NativeProcessQueueVO **/):void
		{
			switch (value.processType)
			{
				case GIT_CHECKOUT_BRANCH:
					if (value.extraArguments && value.extraArguments.length != 0) notice(value.extraArguments[0] +" :Finished");
					break;
			}
		}
		
		override protected function listOfProcessEnded():void
		{
			switch (processType)
			{
				case GIT_CHECKOUT_BRANCH:
					refreshProjectTree(); // important
					success("...process completed");
					checkCurrentEditorForModification();
					break;
			}
		}
	}
}