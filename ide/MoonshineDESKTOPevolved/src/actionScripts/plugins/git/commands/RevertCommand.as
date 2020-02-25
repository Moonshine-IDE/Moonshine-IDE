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
	import mx.collections.ArrayCollection;
	
	import actionScripts.events.StatusBarEvent;
	import actionScripts.events.WorkerEvent;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.GenericSelectableObject;
	import actionScripts.vo.NativeProcessQueueVO;

	public class RevertCommand extends GitCommandBase
	{
		private static const GIT_CHECKOUT_BRANCH:String = "gitCheckoutToBranch";
		
		public function RevertCommand(files:ArrayCollection)
		{
			super();
			
			if (!model.activeProject) return;
			queue = new Vector.<Object>();
			
			for each (var i:GenericSelectableObject in files)
			{
				if (i.isSelected) 
				{
					switch(i.data.status)
					{
						case CheckDifferenceCommand.GIT_STATUS_FILE_DELETED:
						case CheckDifferenceCommand.GIT_STATUS_FILE_MODIFIED:
							addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +" checkout $'"+ UtilsCore.getEncodedForShell(i.data.path) +"'" : gitBinaryPathOSX +'&&checkout&&'+ UtilsCore.getEncodedForShell(i.data.path), false, GIT_CHECKOUT_BRANCH, i.data.path));
							break;
						
						case CheckDifferenceCommand.GIT_STATUS_FILE_NEW:
							addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +" reset $'"+ UtilsCore.getEncodedForShell(i.data.path) +"'" : gitBinaryPathOSX +'&&reset&&'+ UtilsCore.getEncodedForShell(i.data.path), false, GIT_CHECKOUT_BRANCH, i.data.path));
							break;
					}
				}
			}
			
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Requested", "File Revert ", false));
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:plugin.modelAgainstProject[model.activeProject].rootLocal.nativePath}, subscribeIdToWorker);
		}
		
		override protected function listOfProcessEnded():void
		{
			switch (processType)
			{
				case GIT_CHECKOUT_BRANCH:
					refreshProjectTree(); // important
					success("...process completed");
					break;
			}
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
	}
}