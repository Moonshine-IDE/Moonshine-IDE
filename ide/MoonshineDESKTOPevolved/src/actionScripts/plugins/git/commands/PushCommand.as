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
	import actionScripts.events.StatusBarEvent;
	import actionScripts.events.WorkerEvent;
	import actionScripts.plugins.git.model.GitProjectVO;
	import actionScripts.plugins.git.utils.GitUtils;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.NativeProcessQueueVO;

	public class PushCommand extends GitCommandBase
	{
		private const GIT_PUSH:String = "gitPush";
		
		private var lastUserObject:Object;
		private var hasUserPassword:String;
		
		public function PushCommand(userObject:Object=null)
		{
			super();
			
			if (!model.activeProject) return;
			
			var tmpModel:GitProjectVO = plugin.modelAgainstProject[model.activeProject];
			var calculatedURL:String;
			var hasUserName:Boolean;

			if (userObject && userObject.userName && userObject.password)
			{
				calculatedURL = GitUtils.getCalculatedRemotePathWithAuth(tmpModel.remoteURL, userObject.userName);
				hasUserPassword = userObject.password;
				hasUserName = true;
			}
			else if (tmpModel && tmpModel.sessionUser)
			{
				calculatedURL = GitUtils.getCalculatedRemotePathWithAuth(tmpModel.remoteURL, tmpModel.sessionUser);
				hasUserPassword = tmpModel.sessionPassword;
				hasUserName = true;
			}
			else if (userObject && userObject.userName)
			{
				calculatedURL = GitUtils.getCalculatedRemotePathWithAuth(tmpModel.remoteURL, userObject.userName);
				hasUserName = true;
			}

			lastUserObject = userObject;
			queue = new Vector.<Object>();
			
			// we'll not hold from executing push command if we do not have
			// any immediate credential available but will execute with
			// following options -
			// 1. credential could be saved to the user's system (i.e. keychain) so we might not need to inject that separately
			// 2. executing the command may ask for credential - we shall detect and ask user to enter the same
			
			if (!hasUserName)
			{
				addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +" push origin $'"+ UtilsCore.getEncodedForShell(tmpModel.currentBranch) +"'" : gitBinaryPathOSX +'&&push&&origin&&'+ UtilsCore.getEncodedForShell(tmpModel.currentBranch), false, GIT_PUSH, model.activeProject.folderLocation.fileBridge.nativePath));
			}
			else
			{
				if (ConstantsCoreVO.IS_MACOS)
				{
					var tmpExpFilePath:String = GitUtils.writeExpOnMacAuthentication(gitBinaryPathOSX +" push "+ (calculatedURL ? calculatedURL : '') +' "'+ UtilsCore.getEncodedForShell(tmpModel.currentBranch) +'"');
					addToQueue(new NativeProcessQueueVO('expect -f "'+ tmpExpFilePath +'"', true, GIT_PUSH, model.activeProject.folderLocation.fileBridge.nativePath));
				}
				else
				{
					addToQueue(new NativeProcessQueueVO(gitBinaryPathOSX +'&&push'+ (calculatedURL ? '&&'+ calculatedURL : '') +'&&'+ UtilsCore.getEncodedForShell(tmpModel.currentBranch), false, GIT_PUSH, model.activeProject.folderLocation.fileBridge.nativePath));
				}
			}
			
			isErrorEncountered = false;
			warning("Git push requested...");
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Requested", "Push ", false));
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:model.activeProject.folderLocation.fileBridge.nativePath}, subscribeIdToWorker);
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
		
		override protected function listOfProcessEnded():void
		{
			// terminate if error thrown 
			if (isErrorEncountered) return;
			
			switch (processType)
			{
				case GIT_PUSH:
					success("...process completed");
					break;
			}
		}
		
		override protected function shellData(value:Object):void
		{
			var tmpQueue:Object = value.queue; /** type of NativeProcessQueueVO **/
			var tmpProject:ProjectVO;
			
			switch(tmpQueue.processType)
			{
				case GIT_PUSH:
				{
					if (!value.output.match(/fatal: .*/) &&
							value.output.match(/Checking for any authentication...*/))
					{
						worker.sendToWorker(WorkerEvent.PROCESS_STDINPUT_WRITEUTF, {value:hasUserPassword +"\n"}, subscribeIdToWorker);
					}
					else if (value.output.toLowerCase().match(/invalid username/))
					{
						tmpProject = UtilsCore.getProjectByPath(tmpQueue.extraArguments[0]);

						// reset model information if saved by the user
						plugin.modelAgainstProject[tmpProject].sessionUser = null; 
						plugin.modelAgainstProject[tmpProject].sessionPassword = null;
					}
					break;
				}
			}
			
			// call super - it might have some essential
			// commands to run
			super.shellData(value);
		}

		override protected function shellError(value:Object):void
		{
			super.shellError(value);

			if (testMessageIfNeedsAuthentication(value.output))
			{
				if (ConstantsCoreVO.IS_APP_STORE_VERSION)
				{
					showPrivateRepositorySandboxError();
				}
				else
				{
					var userName:String = lastUserObject ? lastUserObject.userName : "";
					var tmpProject:ProjectVO = UtilsCore.getProjectByPath(value.queue.extraArguments[0]);
					if (!userName && plugin.modelAgainstProject[tmpProject])
					{
						userName = plugin.modelAgainstProject[tmpProject].sessionUser;
					}
					openAuthentication(userName);
				}
			}
		}

		override protected function onAuthenticationSuccess(username:String, password:String):void
		{
			if (username && password)
			{
				if (lastUserObject)
				{
					lastUserObject.userName = username;
					lastUserObject.password = password;
				}
				else
				{
					super.onAuthenticationSuccess(username, password);
				}
				
				new PushCommand(lastUserObject);
			}
		}
	}
}