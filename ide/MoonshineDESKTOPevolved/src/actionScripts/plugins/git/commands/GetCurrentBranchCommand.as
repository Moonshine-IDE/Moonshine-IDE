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
	import actionScripts.plugins.git.model.GitProjectVO;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.GenericSelectableObject;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.NativeProcessQueueVO;

	public class GetCurrentBranchCommand extends GitCommandBase
	{
		public static const GIT_REMOTE_BRANCH_LIST_RECEIVED:String = "getGitRemoteBranchListReceived";
		
		private static const GIT_CURRENT_BRANCH_NAME:String = "getGitCurrentBranchName";
		
		private var onXCodePathDetection:Function;
		private var xCodePathDetectionType:String;
		
		public function GetCurrentBranchCommand(project:ProjectVO=null)
		{
			super();
			
			if (!project && !model.activeProject) return;
			
			project ||= model.activeProject;
			queue = new Vector.<Object>();
			
			addToQueue(new NativeProcessQueueVO(getPlatformMessage(' branch'), false, GIT_CURRENT_BRANCH_NAME, project.folderLocation.fileBridge.nativePath));
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:project.folderLocation.fileBridge.nativePath}, subscribeIdToWorker);
		}
		
		override protected function shellData(value:Object):void
		{
			var match:Array;
			var tmpQueue:Object = value.queue; /** type of NativeProcessQueueVO **/
			var tmpModel:GitProjectVO;
			var tmpProject:ProjectVO;
			
			switch(tmpQueue.processType)
			{
				case GIT_CURRENT_BRANCH_NAME:
				{
					tmpProject = UtilsCore.getProjectByPath(tmpQueue.extraArguments[0]);
					tmpModel = plugin.modelAgainstProject[tmpProject];
					if (tmpModel) parseCurrentBranch(value.output, tmpModel);
					return;
				}
			}
			
			// call super - it might have some essential
			// commands to run
			super.shellData(value);
		}
		
		private function parseCurrentBranch(value:String, gitProject:GitProjectVO):void
		{
			var starredIndex:int = value.indexOf("* ") + 2;
			var selectedBranchName:String = value.substring(starredIndex, value.indexOf("\n", starredIndex));
			
			// store the project's selected branch to its model
			gitProject.currentBranch = selectedBranchName;
			
			for each (var i:GenericSelectableObject in gitProject.branchList)
			{
				if (i.data == selectedBranchName)
				{
					i.isSelected = true;
					break;
				}
			}
			
			// let open the selection popup
			dispatcher.dispatchEvent(new GeneralEvent(GIT_REMOTE_BRANCH_LIST_RECEIVED, gitProject.branchList));
		}
	}
}