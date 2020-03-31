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
	
	import actionScripts.events.GeneralEvent;
	import actionScripts.events.WorkerEvent;
	import actionScripts.plugins.git.model.GitFileVO;
	import actionScripts.plugins.git.model.GitTypesVO;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.vo.NativeProcessQueueVO;

	public class MergeCommand extends GitCommandBase
	{
		public static const GIT_CONFLICT_FILES_LIST:String = "gitConflitFilesList";
		
		private static const GIT_MERGE_BRANCH:String = "gitMergeBranch";
		
		public function MergeCommand(targetBranch:String)
		{
			super();
			
			if (!model.activeProject) return;
			
			queue = new Vector.<Object>();
			
			addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +" merge $'"+ UtilsCore.getEncodedForShell('origin/'+ targetBranch) +"'" : 
				gitBinaryPathOSX +'&&merge&&'+ UtilsCore.getEncodedForShell('origin/'+ targetBranch), false, GIT_MERGE_BRANCH));
			
			notice("Initiating the merge process...");
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:model.activeProject.folderLocation.fileBridge.nativePath}, subscribeIdToWorker);
		}
		
		override protected function listOfProcessEnded():void
		{
			switch (processType)
			{
				case GIT_MERGE_BRANCH:
					dispatcher.addEventListener(CheckDifferenceCommand.GIT_DIFF_CHECKED, onGitDiffChecked);
					new CheckDifferenceCommand(GitTypesVO.TYPE_CONFLICT);
					break;
			}
		}
		
		private function onGitDiffChecked(event:GeneralEvent):void
		{
			dispatcher.removeEventListener(CheckDifferenceCommand.GIT_DIFF_CHECKED, onGitDiffChecked);
			
			var tmpCollection:ArrayCollection = event.value as ArrayCollection;
			tmpCollection.filterFunction = function(value:Object):Object {
				if (value.status == GitFileVO.GIT_STATUS_FILE_CONFLICT) return true;
				return false;
			};
			tmpCollection.refresh();
			
			dispatcher.dispatchEvent(new GeneralEvent(GIT_CONFLICT_FILES_LIST, tmpCollection));
		}
	}
}