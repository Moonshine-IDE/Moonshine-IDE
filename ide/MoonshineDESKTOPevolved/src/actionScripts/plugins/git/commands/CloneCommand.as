////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.git.commands
{
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.plugins.git.utils.GitUtils;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;

	import flash.filesystem.File;
	
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.events.WorkerEvent;
	import actionScripts.plugins.git.GitHubPlugin;
	import actionScripts.plugins.versionControl.VersionControlUtils;
	import actionScripts.plugins.versionControl.event.VersionControlEvent;
	import actionScripts.valueObjects.RepositoryItemVO;
	import actionScripts.valueObjects.NativeProcessQueueVO;

	import mx.controls.Alert;

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
			if (ConstantsCoreVO.IS_MACOS && repositoryUnderCursor.isRequireAuthentication && !ConstantsCoreVO.IS_APP_STORE_VERSION)
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
						if (ConstantsCoreVO.IS_APP_STORE_VERSION)
						{
							dispatcher.dispatchEvent(
									new VersionControlEvent(VersionControlEvent.CLONE_CHECKOUT_COMPLETED,
									{hasError:true, message:PRIVATE_REPO_SANDBOX_ERROR_MESSAGE})
							);
						}
						else
						{
							openAuthentication(repositoryUnderCursor ? repositoryUnderCursor.userName : null);
						}
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
						worker.sendToWorker(
								WorkerEvent.PROCESS_STDINPUT_WRITEUTF,
								{value:repositoryUnderCursor.userPassword +"\n"},
								subscribeIdToWorker
						);
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