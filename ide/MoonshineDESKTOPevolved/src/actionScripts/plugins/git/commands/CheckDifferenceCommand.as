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
	import actionScripts.valueObjects.GenericSelectableObject;
	import actionScripts.vo.NativeProcessQueueVO;

	public class CheckDifferenceCommand extends GitCommandBase
	{
		public static const GIT_DIFF_CHECKED:String = "gitDiffProcessCompleted";
		public static const GIT_STATUS_FILE_MODIFIED:String = "gitStatusFileModified";
		public static const GIT_STATUS_FILE_DELETED:String = "gitStatusFileDeleted";
		public static const GIT_STATUS_FILE_NEW:String = "gitStatusFileNew";
		
		private static const GIT_DIFF_CHECK:String = "checkGitDiff";
		
		private var diffResults:String = "";
		
		public function CheckDifferenceCommand()
		{
			super();
			
			queue = new Vector.<Object>();
			
			addToQueue(new NativeProcessQueueVO(getPlatformMessage(' status --porcelain'),
				false, 
				GIT_DIFF_CHECK));
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:model.activeProject.folderLocation.fileBridge.nativePath}, subscribeIdToWorker);
		}
		
		override protected function listOfProcessEnded():void
		{
			switch (processType)
			{
				case GIT_DIFF_CHECK:
					checkDiffFileExistence();
					break;
			}
		}
		
		override protected function shellData(value:Object):void
		{
			var match:Array;
			var tmpQueue:Object = value.queue; /** type of NativeProcessQueueVO **/
			
			switch(tmpQueue.processType)
			{
				case GIT_DIFF_CHECK:
				{
					diffResults += value.output;
					return;
				}
			}
			
			// call super - it might have some essential
			// commands to run
			super.shellData(value);
		}
		
		private function checkDiffFileExistence():void
		{
			if (StringUtil.trim(diffResults) != "")
			{
				var tmpPositions:ArrayCollection = new ArrayCollection();
				var contentInLineBreaks:Array = diffResults.split("\n");
				var firstPart:String;
				var secondPart:String;
				contentInLineBreaks.forEach(function(element:String, index:int, arr:Array):void
				{
					if (element != "")
					{
						element = StringUtil.trim(element);
						firstPart = element.substring(0, element.indexOf(" "));
						secondPart = element.substr(element.indexOf(" ")+1, element.length);
						
						// in some cases the output comes surrounding with double-quote
						// we need to remove them before a commit
						secondPart = secondPart.replace(/\"/g, "");
						secondPart = StringUtil.trim(secondPart);
						
						tmpPositions.addItem(new GenericSelectableObject(false, {path: secondPart, status:getFileStatus(firstPart)}));
					}
				});
				
				diffResults = "";
				dispatcher.dispatchEvent(new GeneralEvent(GIT_DIFF_CHECKED, tmpPositions));
			}
			
			/*
			 * @local
			 */
			function getFileStatus(value:String):String
			{
				if (value == "D") return GIT_STATUS_FILE_DELETED;
				else if (value == "??" || value == "A") return GIT_STATUS_FILE_NEW;
				return GIT_STATUS_FILE_MODIFIED;
			}
		}
	}
}