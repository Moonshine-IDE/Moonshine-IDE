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
	import actionScripts.valueObjects.NativeProcessQueueVO;

	public class CheckBranchNameAvailabilityCommand extends GitCommandBase
	{
		private static const GIT_GET_REMOTE_ORIGINS:String = "gitGetRemoteOrigins";
		private static const GIT_REMOTE_BRANCH_NAME_VALIDATION:String = "gitRemoteValidateProposedBranchName";
		private static const GIT_LOCAL_BRANCH_NAME_VALIDATION:String = "gitLocalValidateProposedBranchName";
		
		private var onCompletion:Function;
		private var targetBranchName:String;
		private var localBranchFoundData:String;
		private var remoteBranchFoundData:String;
		private var remoteOriginWhereBranchFound:String;
		private var isRemoteBranchParsed:Boolean;
		private var isMultipleOrigin:Boolean;
		
		public function CheckBranchNameAvailabilityCommand(name:String, completion:Function)
		{
			super();

			targetBranchName = name;
			onCompletion = completion;
			queue = new Vector.<Object>();

			addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +" show-ref --heads $'"+ UtilsCore.getEncodedForShell(name) +"'" : gitBinaryPathOSX +'&&show-ref&&--heads&&'+ UtilsCore.getEncodedForShell(name), false, GIT_LOCAL_BRANCH_NAME_VALIDATION));
			addToQueue(new NativeProcessQueueVO(getPlatformMessage(' remote'), false, GIT_GET_REMOTE_ORIGINS));
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
				case GIT_GET_REMOTE_ORIGINS:
				{
					var tmpOrigins:Array = value.output.split(ConstantsCoreVO.IS_MACOS ? "\n" : "\r\n");
					isMultipleOrigin = tmpOrigins.length > 1;
					tmpOrigins.forEach(function (origin:String, index:int, arr:Array):void {
						if (origin != "")
							addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +" ls-remote "+ origin +" --heads $'"+ UtilsCore.getEncodedForShell(targetBranchName) +"'" : gitBinaryPathOSX +'&&ls-remote&&'+ origin +'&&--heads&&'+ UtilsCore.getEncodedForShell(targetBranchName), false, GIT_REMOTE_BRANCH_NAME_VALIDATION, origin));
					});
					worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:model.activeProject.folderLocation.fileBridge.nativePath}, subscribeIdToWorker);
					break;
				}
				case GIT_LOCAL_BRANCH_NAME_VALIDATION:
				{
					localBranchFoundData = value.output;
					break;
				}
				case GIT_REMOTE_BRANCH_NAME_VALIDATION:
				{
					isRemoteBranchParsed = true;
					if (!remoteBranchFoundData)
					{
						remoteBranchFoundData = value.output;
						remoteOriginWhereBranchFound = tmpQueue.extraArguments[0];
					}

					break;
				}
			}
		}

		override public function onWorkerValueIncoming(value:Object):void
		{
			var tmpValue:Object = value.value;

			// we do not want to call listOfProcessEnded or
			// unsubscribe until we completes more process from line#69
			if (value.event != WorkerEvent.RUN_LIST_OF_NATIVEPROCESS_ENDED ||
					(value.event == WorkerEvent.RUN_LIST_OF_NATIVEPROCESS_ENDED && isRemoteBranchParsed))
			{
				super.onWorkerValueIncoming(value);
			}

			if (tmpValue.queue.processType == GIT_LOCAL_BRANCH_NAME_VALIDATION && !localBranchFoundData)
			{
				localBranchFoundData = tmpValue.output;
			}

			if (tmpValue.queue.processType == GIT_REMOTE_BRANCH_NAME_VALIDATION && !remoteBranchFoundData)
			{
				isRemoteBranchParsed = true;
				remoteBranchFoundData = tmpValue.output;
				remoteOriginWhereBranchFound = tmpValue.queue.extraArguments[0];
			}
		}

		override protected function listOfProcessEnded():void
		{
			super.listOfProcessEnded();

			if (onCompletion != null)
			{
				onCompletion(localBranchFoundData, remoteBranchFoundData, isMultipleOrigin, remoteOriginWhereBranchFound);
				onCompletion = null;
			}
		}
	}
}