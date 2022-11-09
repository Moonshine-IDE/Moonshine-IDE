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
	import flash.events.Event;
	import flash.filesystem.File;
	
	import actionScripts.events.GeneralEvent;
	import actionScripts.events.WorkerEvent;
	import actionScripts.plugins.git.model.ConstructorDescriptor;
	import actionScripts.plugins.git.model.GitProjectVO;
	import actionScripts.ui.menu.MenuPlugin;
	import actionScripts.ui.menu.vo.ProjectMenuTypes;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.VersionControlTypes;
	import actionScripts.valueObjects.NativeProcessQueueVO;

	public class CheckIsGitRepositoryCommand extends GitCommandBase
	{
		public static const GIT_REPOSITORY_TESTED:String = "gitRepositoryTested";
		
		private var onXCodePathDetection:Function;
		private var xCodePathDetectionType:String;
		
		public function CheckIsGitRepositoryCommand(project:ProjectVO)
		{
			super();
			
			queue = new Vector.<Object>();
			
			addToQueue(new NativeProcessQueueVO(getPlatformMessage(' rev-parse --git-dir'), false, GIT_REPOSITORY_TESTED, project.folderLocation.fileBridge.nativePath));
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:project.folderLocation.fileBridge.nativePath}, subscribeIdToWorker);
		}
		
		override protected function shellData(value:Object):void
		{
			var match:Array;
			var tmpQueue:Object = value.queue; /** type of NativeProcessQueueVO **/
			var tmpProject:ProjectVO;
			var isFatal:Boolean = value.output.match(/fatal: .*/) != null;
			
			switch(tmpQueue.processType)
			{
				case GIT_REPOSITORY_TESTED:
				{
					tmpProject = UtilsCore.getProjectByPath(tmpQueue.extraArguments[0]);
					if (!isFatal)
					{
						if (tmpProject)
						{
							tmpProject.menuType += ","+ ProjectMenuTypes.GIT_PROJECT;
							(tmpProject as ProjectVO).hasVersionControlType = VersionControlTypes.GIT;
							if (plugin.modelAgainstProject[tmpProject] == undefined) 
							{
								value.output = value.output.replace("\n", "");
								
								plugin.modelAgainstProject[tmpProject] = new GitProjectVO();
								plugin.modelAgainstProject[tmpProject].rootLocal = (value.output == ".git") ? tmpProject.folderLocation.fileBridge.getFile as File : 
									(new File(value.output)).parent;
							}
							
							// continuing fetch
							pendingProcess.push(new ConstructorDescriptor(GetCurrentBranchCommand, tmpProject)); // store the current branch
							pendingProcess.push(new ConstructorDescriptor(GetRemoteURLCommand, tmpProject)); // store the remote URL
							
							// following will enable/disable Moonshine top menus based on project
							dispatcher.dispatchEvent(new Event(MenuPlugin.REFRESH_MENU_STATE));
						}
						
						dispatcher.dispatchEvent(new GeneralEvent(GIT_REPOSITORY_TESTED));
					}
					else if (ConstantsCoreVO.IS_MACOS && tmpProject && 
						(plugin.projectsNotAcceptedByUserToPermitAsGitOnMacOS[tmpProject.folderLocation.fileBridge.nativePath] == undefined))
					{
						// in case of OSX sandbox if the project's parent folder
						// consists of '.git' and do not have bookmark access
						// the running command is tend to be fail, in that case
						// a brute check
						initiateSandboxGitRepositoryCheckBrute(tmpProject as ProjectVO);
					}
					else
					{
						dispatcher.dispatchEvent(new GeneralEvent(GIT_REPOSITORY_TESTED));
					}
					
					// following will enable/disable Moonshine top menus based on project
					if (tmpProject)
					{
						dispatcher.dispatchEvent(new Event(MenuPlugin.REFRESH_MENU_STATE));
					}
					return;
				}
			}
			
			// call super - it might have some essential
			// commands to run
			super.shellData(value);
		}
		
		private function initiateSandboxGitRepositoryCheckBrute(value:ProjectVO):void
		{
			var tmpFile:File = value.folderLocation.fileBridge.getFile as File;
			do
			{
				tmpFile = tmpFile.parent;
				if (tmpFile && tmpFile.resolvePath(".git").exists && tmpFile.resolvePath(".git/index").exists)
				{
					dispatcher.dispatchEvent(new GeneralEvent(GIT_REPOSITORY_TESTED, {project:value, gitRootLocation:tmpFile}));
					break;
				}
				
			} while (tmpFile != null);
		}
	}
}