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
	import flash.filesystem.File;
	
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.events.WorkerEvent;
	import actionScripts.plugins.git.GitHubPlugin;
	import actionScripts.plugins.git.model.ConstructorDescriptor;
	import actionScripts.plugins.git.model.MethodDescriptor;
	import actionScripts.plugins.versionControl.VersionControlUtils;
	import actionScripts.plugins.versionControl.event.VersionControlEvent;
	import actionScripts.valueObjects.RepositoryItemVO;
	import actionScripts.vo.NativeProcessQueueVO;

	public class CloneCommand extends GitCommandBase
	{
		public static const CLONE_REQUEST:String = "gutCloneRequest";
		
		private var repositoryUnderCursor:RepositoryItemVO;
		private var lastCloneURL:String;
		private var lastCloneTarget:String;
		private var lastTargetFolder:String;
		private var authWindowTriggerCountWindows:int;
		
		private var _cloningProjectName:String;
		private function get cloningProjectName():String
		{
			return _cloningProjectName;
		}
		private function set cloningProjectName(value:String):void
		{
			var quoteIndex:int = value.indexOf("'");
			_cloningProjectName = value.substring(++quoteIndex, value.indexOf("'", quoteIndex));
		}
		
		public function CloneCommand(url:String, target:String, targetFolder:String, repository:RepositoryItemVO)
		{
			super();
			
			queue = new Vector.<Object>();
			
			authWindowTriggerCountWindows = 0;
			isErrorEncountered = false;
			repositoryUnderCursor = repository;
			lastCloneURL = url;
			lastCloneTarget = target;
			lastTargetFolder = targetFolder;
			
			addToQueue(new NativeProcessQueueVO(getPlatformMessage(' clone --progress -v '+ url +' '+ targetFolder), false, GitHubPlugin.CLONE_REQUEST));
			
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Requested", "Clone ", false));
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:target}, subscribeIdToWorker);
		}
		
		override protected function shellError(value:Object):void
		{
			// call super - it might have some essential 
			// commands to run
			super.shellError(value);
			
			var match:Array;
			switch (value.queue.processType)
			{
				case GitHubPlugin.CLONE_REQUEST:
				{
					match = value.output.toLowerCase().match(/fatal: .*username/);
					if (match)
					{
						plugin.requestToAuthenticate(
							new ConstructorDescriptor(CloneCommand, lastCloneURL, lastCloneTarget, lastTargetFolder, repositoryUnderCursor)
						);
					}
					else
					{
						dispatcher.dispatchEvent(new VersionControlEvent(VersionControlEvent.CLONE_CHECKOUT_COMPLETED, {hasError:true, message:value.output}));
					}
				}
			}
		}
		
		override protected function shellData(value:Object):void
		{
			var match:Array;
			var tmpQueue:Object = value.queue; /** type of NativeProcessQueueVO **/
			
			switch(tmpQueue.processType)
			{
				case GitHubPlugin.CLONE_REQUEST:
				{
					match = value.output.toLowerCase().match(/cloning into/);
					if (match)
					{
						// for some weird reason git clone always
						// turns to errordata first
						cloningProjectName = value.output;
						warning(value.output);
					}
					else
					{
						match = value.output.toLowerCase().match(/logon failed/);
						if (match)
						{
							authWindowTriggerCountWindows ++;
							if (authWindowTriggerCountWindows == 2)
							{
								// terminates the process as on Windows
								// git-native authentication window
								// pops only twice
								shellError(value);
								return;
							}
						}
					}
					break;
				}
			}
			
			// call super - it might have some essential
			// commands to run
			super.shellData(value);
		}
		
		override protected function listOfProcessEnded():void
		{
			// terminate if error thrown 
			if (isErrorEncountered) return;
			
			switch (processType)
			{
				case GitHubPlugin.CLONE_REQUEST:
					success("'"+ cloningProjectName +"'...downloaded successfully ("+ lastCloneURL +")");
					doPostCloneProcess(new File(lastCloneTarget).resolvePath(cloningProjectName));
					break;
			}
		}
		
		private function doPostCloneProcess(path:File):void
		{
			if (repositoryUnderCursor)
			{
				// following method is mainly applicable for git-meta type of repository
				VersionControlUtils.parseRepositoryDependencies(repositoryUnderCursor, path);
				
				// continue searching for possible
				// project exietence in its sub-directories
				dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.SEARCH_PROJECTS_IN_DIRECTORIES, path));
				dispatcher.dispatchEvent(new VersionControlEvent(VersionControlEvent.CLONE_CHECKOUT_COMPLETED, {hasError:false, message:null}));
			}
		}
	}
}