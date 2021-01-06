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
	import actionScripts.plugins.git.utils.GitUtils;
	import actionScripts.valueObjects.ConstantsCoreVO;

	import flash.filesystem.File;
	
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.events.WorkerEvent;
	import actionScripts.plugins.git.GitHubPlugin;
	import actionScripts.plugins.versionControl.VersionControlUtils;
	import actionScripts.plugins.versionControl.event.VersionControlEvent;
	import actionScripts.valueObjects.RepositoryItemVO;
	import actionScripts.vo.NativeProcessQueueVO;

	public class CloneCommand extends GitCommandBase
	{
		public static const CLONE_REQUEST:String = "gitCloneRequest";
		
		private var repositoryUnderCursor:RepositoryItemVO;
		private var lastCloneURL:String;
		private var lastCloneTarget:String;
		private var lastTargetFolder:String;
		private var authWindowTriggerCountWindows:int;
		private var isRequestWithAuth:Boolean;
		
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
			
			var calculatedURL:String = lastCloneURL;
			if (repositoryUnderCursor.isRequireAuthentication && repositoryUnderCursor.userName)
			{
				var protocol:String = lastCloneURL.substring(0, lastCloneURL.indexOf("://")+3);
				calculatedURL = lastCloneURL.replace(protocol, "");
				calculatedURL = protocol + repositoryUnderCursor.userName +"@"+ calculatedURL;
				isRequestWithAuth = true;
			}

			var gitCommand:String = getPlatformMessage(' clone --progress -v '+ calculatedURL +' '+ targetFolder);
			if (ConstantsCoreVO.IS_MACOS && repositoryUnderCursor.isRequireAuthentication)
			{
				// experimental async file creation as Joel experienced
				// exp file creation issue in his tests
				var tmpExpFilePath:String = GitUtils.writeExpOnMacAuthentication(gitCommand);
				addToQueue(new NativeProcessQueueVO('expect -f "'+ tmpExpFilePath +'"', true, GitHubPlugin.CLONE_REQUEST));
			}
			else
			{
				addToQueue(new NativeProcessQueueVO(gitCommand, false, GitHubPlugin.CLONE_REQUEST));
			}

			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Requested", "Clone ", false));
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:target}, subscribeIdToWorker);
		}

		override public function onWorkerValueIncoming(value:Object):void
		{
			// do not print enter password line
			if (ConstantsCoreVO.IS_MACOS && value.value && ("output" in value.value) &&
					value.value.output.match(/Enter password \(exp\):.*/))
			{
				value.value.output = value.value.output.replace(/Enter password \(exp\):.*/, "Checking for any authentication..");
			}

			super.onWorkerValueIncoming(value);
		}
		
		override protected function shellError(value:Object):void
		{
			// call super - it might have some essential 
			// commands to run.
			super.shellError(value);
			
			switch (value.queue.processType)
			{
				case GitHubPlugin.CLONE_REQUEST:
				{
					repositoryUnderCursor.userPassword = null;
					
					if (testMessageIfNeedsAuthentication(value.output))
					{
						openAuthentication(repositoryUnderCursor ? repositoryUnderCursor.userName : null);
					}
					else
					{
						dispatcher.dispatchEvent(new VersionControlEvent(VersionControlEvent.CLONE_CHECKOUT_COMPLETED, {hasError:true, message:value.output}));
					}
					
					if (value.output.toLowerCase().match(/fatal: .*not found/) && isRequestWithAuth)
					{
						error("Insufficient permission.");
					}
				}
			}
		}
		
		override protected function onAuthenticationSuccess(username:String, password:String):void
		{
			if (username && password)
			{
				repositoryUnderCursor.isRequireAuthentication = true;
				repositoryUnderCursor.userName = username;
				repositoryUnderCursor.userPassword = password;
				
				new CloneCommand(lastCloneURL, lastCloneTarget, lastTargetFolder, repositoryUnderCursor);
			}
		}
		
		override protected function shellData(value:Object):void
		{
			var tmpQueue:Object = value.queue; /** type of NativeProcessQueueVO **/
			
			switch(tmpQueue.processType)
			{
				case GitHubPlugin.CLONE_REQUEST:
				{
					if (value.output.match(/Checking for any authentication...*/))
					{
						worker.sendToWorker(WorkerEvent.PROCESS_STDINPUT_WRITEUTF, {value:repositoryUnderCursor.userPassword +"\n"}, subscribeIdToWorker);
					}
					else if (value.output.toLowerCase().match(/cloning into/))
					{
						// for some weird reason git clone always
						// turns to errordata first
						cloningProjectName = value.output;
						warning(value.output);
					}
					else if (value.output.toLowerCase().match(/logon failed/))
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