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
	import actionScripts.events.StatusBarEvent;
	import actionScripts.events.WorkerEvent;
	import actionScripts.plugins.git.model.GitProjectVO;
	import actionScripts.plugins.git.utils.GitUtils;
	import actionScripts.plugins.versionControl.VersionControlUtils;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.NativeProcessQueueVO;

	public class PullCommand extends GitCommandBase
	{
		public static const PULL_REQUEST:String = "gitPullRequest";
		
		public function PullCommand()
		{
			super();
			
			if (!model.activeProject) return;
			
			var tmpModel:GitProjectVO = plugin.modelAgainstProject[model.activeProject];
			queue = new Vector.<Object>();
			
			var calculatedURL:String;
			if (tmpModel && tmpModel.sessionUser)
			{
				calculatedURL = GitUtils.getCalculatedRemotePathWithAuth(tmpModel.remoteURL, tmpModel.sessionUser);
			}
			
			var command:String;
			if (ConstantsCoreVO.IS_MACOS)
			{
				command = gitBinaryPathOSX +" pull ";
				if (calculatedURL) command += calculatedURL;
				command += " --progress -v --no-rebase";
			}
			else
			{
				command = gitBinaryPathOSX +'&&pull';
				if (calculatedURL) command += '&&'+ calculatedURL;
				command += '&&--progress&&-v&&--no-rebase';
			}

			if (ConstantsCoreVO.IS_MACOS && tmpModel.sessionUser)
			{
				var tmpExpFilePath:String = GitUtils.writeExpOnMacAuthentication(command);
				addToQueue(new NativeProcessQueueVO('expect -f "'+ tmpExpFilePath +'"', true, PULL_REQUEST));
			}
			else
			{
				addToQueue(new NativeProcessQueueVO(command, false, PULL_REQUEST));
			}
			
			warning("Requesting Pull...");
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Requested", "Pull ", false));
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:model.activeProject.folderLocation.fileBridge.nativePath}, subscribeIdToWorker);
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
					var tmpModel:GitProjectVO = plugin.modelAgainstProject[model.activeProject];
					openAuthentication(tmpModel ? tmpModel.sessionUser : null);
				}
			}
		}

		override protected function shellData(value:Object):void
		{
			super.shellData(value);

			if (!value.output.match(/fatal: .*/) &&
					value.output.match(/Checking for any authentication...*/))
			{
				var tmpModel:GitProjectVO = plugin.modelAgainstProject[model.activeProject];
				worker.sendToWorker(WorkerEvent.PROCESS_STDINPUT_WRITEUTF, {value:tmpModel.sessionPassword +"\n"}, subscribeIdToWorker);
			}
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
		
		override protected function onAuthenticationSuccess(username:String, password:String):void
		{
			if (username && password)
			{
				super.onAuthenticationSuccess(username, password);
				new PullCommand();
			}
		}
		
		override protected function listOfProcessEnded():void
		{
			switch (processType)
			{
				case PULL_REQUEST:
					refreshProjectTree(); // important
					success("...process completed");
					checkCurrentEditorForModification();
					break;
			}
		}
	}
}