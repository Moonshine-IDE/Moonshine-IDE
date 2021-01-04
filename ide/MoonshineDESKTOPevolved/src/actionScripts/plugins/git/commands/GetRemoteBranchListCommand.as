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
	import actionScripts.plugins.git.model.ConstructorDescriptor;
	import actionScripts.plugins.git.model.GitProjectVO;
	import actionScripts.plugins.git.model.MethodDescriptor;
	import actionScripts.valueObjects.GenericSelectableObject;
	import actionScripts.valueObjects.NativeProcessQueueVO;

	public class GetRemoteBranchListCommand extends GitCommandBase
	{
		public static const GIT_REMOTE_BRANCH_LIST:String = "getGitRemoteBranchList";
		
		private var onXCodePathDetection:Function;
		private var xCodePathDetectionType:String;
		
		public function GetRemoteBranchListCommand()
		{
			super();
			
			queue = new Vector.<Object>();
			
			addToQueue(new NativeProcessQueueVO(getPlatformMessage(' fetch'), false, null));
			addToQueue(new NativeProcessQueueVO(getPlatformMessage(' branch -r'), false, GIT_REMOTE_BRANCH_LIST));
			pendingProcess.push(new ConstructorDescriptor(GetCurrentBranchCommand)); // next method we need to fire when above done
			
			warning("Fetching branch details...");
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Requested", "Branch Details ", false));
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:model.activeProject.folderLocation.fileBridge.nativePath}, subscribeIdToWorker);
		}
		
		override protected function shellData(value:Object):void
		{
			var match:Array;
			var tmpQueue:Object = value.queue; /** type of NativeProcessQueueVO **/
			var isFatal:Boolean = value.output.match(/fatal: .*/) != null;
			
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
		
		private function parseRemoteBranchList(value:String):void
		{
			if (model.activeProject && plugin.modelAgainstProject[model.activeProject] != undefined)
			{
				var tmpModel:GitProjectVO = plugin.modelAgainstProject[model.activeProject];
				
				tmpModel.branchList = new ArrayCollection();
				var contentInLineBreaks:Array = value.split("\n");
				contentInLineBreaks.forEach(function(element:String, index:int, arr:Array):void
				{
					if (element != "" && element.indexOf("origin/") != -1 && element.indexOf("->") == -1)
					{
						tmpModel.branchList.addItem(new GenericSelectableObject(false, element.substr(element.indexOf("origin/")+7, element.length)));
					}
				});
			}
		}
	}
}