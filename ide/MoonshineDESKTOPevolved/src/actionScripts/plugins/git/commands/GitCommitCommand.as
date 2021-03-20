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
	import actionScripts.valueObjects.NativeProcessQueueVO;

	public class GitCommitCommand extends GitCommandBase
	{
		private static const GIT_COMMIT:String = "gitCommit";
		
		public function GitCommitCommand(files:ArrayCollection, withMessage:String)
		{
			super();
			
			queue = new Vector.<Object>();
			
			for each (var i:GenericSelectableObject in files)
			{
				if (i.isSelected) 
				{
					addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +" add $'"+ UtilsCore.getEncodedForShell(i.data.path) +"'" : gitBinaryPathOSX +'&&add&&'+ UtilsCore.getEncodedForShell(i.data.path), false, GIT_COMMIT));
				}
			}
			
			addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +" commit -m $'"+ UtilsCore.getEncodedForShell(withMessage) +"'" : gitBinaryPathOSX +'&&commit&&-m&&"'+ UtilsCore.getEncodedForShell(withMessage, true) +'"', false, GIT_COMMIT));
			
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Requested", "Commit ", false));
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:plugin.modelAgainstProject[model.activeProject].rootLocal.nativePath}, subscribeIdToWorker);
		}
	}
}