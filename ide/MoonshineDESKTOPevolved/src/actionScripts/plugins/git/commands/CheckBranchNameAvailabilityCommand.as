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
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.vo.NativeProcessQueueVO;

	public class CheckBranchNameAvailabilityCommand extends GitCommandBase
	{
		private static const GIT_REMOTE_ORIGINS_LISTING:String = "gitRemoteOriginsListing";
		private static const GIT_BRANCH_NAME_VALIDATION:String = "gitValidateProposedBranchName";
		
		private var onCompletion:Function;
		private var targetBranchName:String;
		private var localBranchFoundData:String;
		
		public function CheckBranchNameAvailabilityCommand(name:String, completion:Function)
		{
			super();
			
			targetBranchName = name;
			onCompletion = completion;
			queue = new Vector.<Object>();

			//addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +" show-ref --heads $'"+ UtilsCore.getEncodedForShell(name) +"'" : gitBinaryPathOSX +'&&show-ref&&--heads&&'+ UtilsCore.getEncodedForShell(name), false, GIT_BRANCH_NAME_VALIDATION));
			addToQueue(new NativeProcessQueueVO(getPlatformMessage(" remote -v"), false, GIT_REMOTE_ORIGINS_LISTING));
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:model.activeProject.folderLocation.fileBridge.nativePath}, subscribeIdToWorker);
		}
		
		override protected function shellData(value:Object):void
		{
			var match:Array;
			var tmpQueue:Object = value.queue; /** type of NativeProcessQueueVO **/

			if (value.output && value.output.match(/fatal: .*/))
			{
				super.shellError(value);
				return;
			}
			
			switch(tmpQueue.processType)
			{
				case GIT_BRANCH_NAME_VALIDATION:
				{
					localBranchFoundData = value.output;
					break;
				}
				case GIT_REMOTE_ORIGINS_LISTING:
				{
					var tmpOriginsValue:Array = value.output.split("\n");
					var eachLine:Array = tmpOriginsValue[0].split("\t")
					break;
				}
			}
		}
		
		override protected function unsubscribeFromWorker():void
		{
			if (onCompletion != null)
			{
				onCompletion(localBranchFoundData);
			}
			
			super.unsubscribeFromWorker();
			onCompletion = null;
		}
	}
}