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
	import actionScripts.plugins.git.model.GitProjectVO;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.GenericSelectableObject;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.NativeProcessQueueVO;

	public class GetCurrentBranchCommand extends GitCommandBase
	{
		public static const GIT_REMOTE_BRANCH_LIST_RECEIVED:String = "getGitRemoteBranchListReceived";
		
		private static const GIT_CURRENT_BRANCH_NAME:String = "getGitCurrentBranchName";
		
		private var onXCodePathDetection:Function;
		private var xCodePathDetectionType:String;
		
		public function GetCurrentBranchCommand(project:ProjectVO=null)
		{
			super();
			
			if (!project && !model.activeProject) return;
			
			project ||= model.activeProject;
			queue = new Vector.<Object>();
			
			addToQueue(new NativeProcessQueueVO(getPlatformMessage(' branch'), false, GIT_CURRENT_BRANCH_NAME, project.folderLocation.fileBridge.nativePath));
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:project.folderLocation.fileBridge.nativePath}, subscribeIdToWorker);
		}
		
		override protected function shellData(value:Object):void
		{
			var match:Array;
			var tmpQueue:Object = value.queue; /** type of NativeProcessQueueVO **/
			var tmpModel:GitProjectVO;
			var tmpProject:ProjectVO;
			
			switch(tmpQueue.processType)
			{
				case GIT_CURRENT_BRANCH_NAME:
				{
					tmpProject = UtilsCore.getProjectByPath(tmpQueue.extraArguments[0]);
					tmpModel = plugin.modelAgainstProject[tmpProject];
					if (tmpModel) parseCurrentBranch(value.output, tmpModel);
					return;
				}
			}
			
			// call super - it might have some essential
			// commands to run
			super.shellData(value);
		}
		
		private function parseCurrentBranch(value:String, gitProject:GitProjectVO):void
		{
			var starredIndex:int = value.indexOf("* ") + 2;
			var selectedBranchName:String = value.substring(starredIndex, value.indexOf("\n", starredIndex));
			
			// store the project's selected branch to its model
			gitProject.currentBranch = selectedBranchName;
			
			for each (var i:GenericSelectableObject in gitProject.branchList)
			{
				if (i.data == selectedBranchName)
				{
					i.isSelected = true;
					break;
				}
			}
			
			// let open the selection popup
			dispatcher.dispatchEvent(new GeneralEvent(GIT_REMOTE_BRANCH_LIST_RECEIVED, gitProject.branchList));
		}
	}
}