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
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.NativeProcessQueueVO;

	public class GetRemoteURLCommand extends GitCommandBase
	{
		private static const GIT_REMOTE_ORIGIN_URL:String = "getGitRemoteURL";
		
		private var onXCodePathDetection:Function;
		private var xCodePathDetectionType:String;
		
		public function GetRemoteURLCommand(project:ProjectVO)
		{
			super();
			
			queue = new Vector.<Object>();
			project !== model.activeProject;
			
			addToQueue(new NativeProcessQueueVO(getPlatformMessage(' config --get remote.origin.url'), false, GIT_REMOTE_ORIGIN_URL, project.folderLocation.fileBridge.nativePath));
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:project.folderLocation.fileBridge.nativePath}, subscribeIdToWorker);
		}
		
		override protected function shellData(value:Object):void
		{
			var match:Array;
			var tmpQueue:Object = value.queue; /** type of NativeProcessQueueVO **/
			var tmpProject:ProjectVO;
			
			switch(tmpQueue.processType)
			{
				case GIT_REMOTE_ORIGIN_URL:
				{
					match = value.output.match(/.*.$/);
					if (match)
					{
						tmpProject = UtilsCore.getProjectByPath(tmpQueue.extraArguments[0]);
						var tmpResult:Array = new RegExp("http.*\://", "i").exec(value.output);
						if (tmpResult != null && tmpProject)
						{
							// extracting remote origin URL as 'github/[author]/[project]
							if (plugin.modelAgainstProject[tmpProject] != undefined) plugin.modelAgainstProject[tmpProject].remoteURL = value.output.substr(tmpResult[0].length, value.output.length).replace("\n", "");
						}
						return;
					}
					break;
				}
			}
			
			// call super - it might have some essential
			// commands to run
			super.shellData(value);
		}
	}
}