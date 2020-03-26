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
	import com.adobe.utils.StringUtil;
	
	import mx.collections.ArrayCollection;
	
	import actionScripts.events.GeneralEvent;
	import actionScripts.events.WorkerEvent;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.GenericSelectableObject;
	import actionScripts.vo.NativeProcessQueueVO;

	public class MergeCommand extends GitCommandBase
	{
		public static const GIT_CONFLICT_FILES_LIST:String = "gitConflitFilesList";
		
		private static const GIT_MERGE_BRANCH:String = "gitMergeBranch";
		private static const GIT_CONFLICT_FILE_LIST:String = "getConflictFileNames";
		
		private var diffResults:String = "";
		
		public function MergeCommand(targetBranch:String)
		{
			super();
			
			if (!model.activeProject) return;
			
			queue = new Vector.<Object>();
			
			addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +" merge $'"+ UtilsCore.getEncodedForShell('origin/'+ targetBranch) +"'" : 
				gitBinaryPathOSX +'&&merge&&'+ UtilsCore.getEncodedForShell('origin/'+ targetBranch), false, GIT_MERGE_BRANCH));
			addToQueue(new NativeProcessQueueVO(getPlatformMessage(' diff --name-only --diff-filter=U'), false, GIT_CONFLICT_FILE_LIST));
			
			notice("Initiating the merge process...");
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:model.activeProject.folderLocation.fileBridge.nativePath}, subscribeIdToWorker);
		}
		
		override protected function shellData(value:Object):void
		{
			var match:Array;
			var tmpQueue:Object = value.queue; /** type of NativeProcessQueueVO **/
			
			switch(tmpQueue.processType)
			{
				case GIT_CONFLICT_FILE_LIST:
				{
					diffResults += value.output;
					return;
				}
			}
			
			// call super - it might have some essential
			// commands to run
			super.shellData(value);
		}
		
		override protected function listOfProcessEnded():void
		{
			switch (processType)
			{
				case GIT_CONFLICT_FILE_LIST:
					refreshProjectTree(); // important
					success("...process completed");
					parseConflictFilesList();
					break;
			}
		}
		
		protected function parseConflictFilesList():void
		{
			var tmpPositions:ArrayCollection = new ArrayCollection();
			if (StringUtil.trim(diffResults) != "")
			{
				var contentInLineBreaks:Array = diffResults.split("\n");
				contentInLineBreaks.forEach(function(element:String, index:int, arr:Array):void
				{
					if (element != "")
					{
						element = StringUtil.trim(element);
						tmpPositions.addItem(new GenericSelectableObject(false, element));
					}
				});
				
				diffResults = "";
			}
			
			dispatcher.dispatchEvent(new GeneralEvent(GIT_CONFLICT_FILES_LIST, tmpPositions));
		}
	}
}