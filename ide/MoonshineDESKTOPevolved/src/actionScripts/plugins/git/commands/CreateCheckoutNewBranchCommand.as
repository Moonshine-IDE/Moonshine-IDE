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
	import actionScripts.events.GeneralEvent;
	import actionScripts.events.WorkerEvent;
	import actionScripts.plugins.git.model.ConstructorDescriptor;
	import actionScripts.plugins.git.model.GitProjectVO;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.NativeProcessQueueVO;

	public class CreateCheckoutNewBranchCommand extends GitCommandBase
	{
		private static const GIT_CHECKOUT_NEW_BRANCH:String = "gitCheckoutNewBranch";
		
		public function CreateCheckoutNewBranchCommand(name:String, pushToOrigin:Boolean)
		{
			super();
			
			if (!model.activeProject) return;
			
			var tmpModel:GitProjectVO = plugin.modelAgainstProject[model.activeProject];
			queue = new Vector.<Object>();
			
			// https://stackoverflow.com/questions/1519006/how-do-you-create-a-remote-git-branch
			addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +" checkout -b $'"+ UtilsCore.getEncodedForShell(name) +"'" : gitBinaryPathOSX +'&&checkout&&-b&&'+ UtilsCore.getEncodedForShell(name), false, GIT_CHECKOUT_NEW_BRANCH));
			
			pendingProcess.push(new ConstructorDescriptor(GetCurrentBranchCommand));
			if (pushToOrigin)
			{
				dispatcher.addEventListener(GetCurrentBranchCommand.GIT_REMOTE_BRANCH_LIST_RECEIVED, onCurrentBranchNameFetched);
			}
			
			notice("Trying to switch branch...");
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:model.activeProject.folderLocation.fileBridge.nativePath}, subscribeIdToWorker);
		}
		
		override protected function listOfProcessEnded():void
		{
			switch (processType)
			{
				case GIT_CHECKOUT_NEW_BRANCH:
					refreshProjectTree(); // important
					success("...process completed");
					checkCurrentEditorForModification();
					break;
			}
		}
		
		private function onCurrentBranchNameFetched(event:GeneralEvent):void
		{
			dispatcher.removeEventListener(GetCurrentBranchCommand.GIT_REMOTE_BRANCH_LIST_RECEIVED, onCurrentBranchNameFetched);
			new PushCommand();
		}
	}
}