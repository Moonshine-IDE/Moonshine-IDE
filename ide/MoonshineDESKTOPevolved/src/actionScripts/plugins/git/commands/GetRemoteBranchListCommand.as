////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
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
	import actionScripts.valueObjects.ConstantsCoreVO;

	import mx.collections.ArrayCollection;
	
	import actionScripts.events.StatusBarEvent;
	import actionScripts.events.WorkerEvent;
	import actionScripts.plugins.git.model.ConstructorDescriptor;
	import actionScripts.plugins.git.model.GitProjectVO;
	import actionScripts.valueObjects.GenericSelectableObject;
	import actionScripts.valueObjects.NativeProcessQueueVO;

	import mx.utils.StringUtil;

	public class GetRemoteBranchListCommand extends GitCommandBase
	{
		public static const GIT_REMOTE_BRANCH_LIST:String = "getGitRemoteBranchList";

		public function GetRemoteBranchListCommand()
		{
			super();
			
			queue = new Vector.<Object>();

			var tmpModel:GitProjectVO = plugin.modelAgainstProject[model.activeProject];
			var calculatedURL:String;
			if (tmpModel && tmpModel.sessionUser)
			{
				calculatedURL = GitUtils.getCalculatedRemotePathWithAuth(tmpModel.remoteURL, tmpModel.sessionUser);
			}

			var gitFetchCommand:String = getPlatformMessage(' fetch'+ (calculatedURL ? ' '+ calculatedURL : ''));
			if (ConstantsCoreVO.IS_MACOS && calculatedURL && tmpModel.sessionUser)
			{
				var tmpExpFilePath:String = GitUtils.writeExpOnMacAuthentication(gitFetchCommand);
				addToQueue(new NativeProcessQueueVO('expect -f "'+ tmpExpFilePath +'"', true, null));
			}
			else
			{
				addToQueue(new NativeProcessQueueVO(gitFetchCommand, false, null));
			}

			addToQueue(new NativeProcessQueueVO(getPlatformMessage(' branch -r'), false, GIT_REMOTE_BRANCH_LIST));
			pendingProcess.push(new ConstructorDescriptor(GetCurrentBranchCommand)); // next method we need to fire when above done
			
			warning("Fetching branch details...");
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Requested", "Branch Details ", false));
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
				default:
				{
					if (!isFatal && value.output.match(/Checking for any authentication...*/))
					{
						var tmpModel:GitProjectVO = plugin.modelAgainstProject[model.activeProject];
						worker.sendToWorker(WorkerEvent.PROCESS_STDINPUT_WRITEUTF, {value:tmpModel.sessionPassword +"\n"}, subscribeIdToWorker);
					}
				}
			}
			
			// call super - it might have some essential
			// commands to run
			super.shellData(value);
		}

		override protected function shellError(value:Object):void
		{
			// call super - it might have some essential
			// commands to run.
			super.shellError(value);

			if (testMessageIfNeedsAuthentication(value.output))
			{
				if (ConstantsCoreVO.IS_APP_STORE_VERSION)
				{
					showPrivateRepositorySandboxError();
				}
				else
				{
					openAuthentication(null);
				}
			}
		}

		override protected function onAuthenticationSuccess(username:String, password:String):void
		{
			if (username && password)
			{
				super.onAuthenticationSuccess(username, password);
				new GetRemoteBranchListCommand();
			}
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
						element = StringUtil.trim(element);
						tmpModel.branchList.addItem(new GenericSelectableObject(false, element));
					}
				});
			}
		}
	}
}