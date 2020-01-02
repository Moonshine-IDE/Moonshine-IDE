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
	import flash.events.Event;
	import flash.filesystem.File;
	
	import actionScripts.events.GeneralEvent;
	import actionScripts.events.WorkerEvent;
	import actionScripts.plugins.git.model.GitProjectVO;
	import actionScripts.plugins.git.model.MethodDescriptor;
	import actionScripts.ui.menu.MenuPlugin;
	import actionScripts.ui.menu.vo.ProjectMenuTypes;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.VersionControlTypes;
	import actionScripts.vo.NativeProcessQueueVO;

	public class CheckIsGitRepositoryCommand extends GitCommandBase
	{
		public static const GIT_REPOSITORY_TEST:String = "checkIfGitRepository";
		
		private var onXCodePathDetection:Function;
		private var xCodePathDetectionType:String;
		
		public function CheckIsGitRepositoryCommand(project:ProjectVO)
		{
			super();
			
			queue = new Vector.<Object>();
			
			addToQueue(new NativeProcessQueueVO(getPlatformMessage(' rev-parse --git-dir'), false, GIT_REPOSITORY_TEST, project.folderLocation.fileBridge.nativePath));
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:project.folderLocation.fileBridge.nativePath}, subscribeIdToWorker);
			var tmp:MethodDescriptor = new MethodDescriptor(new GetCurrentBranchCommand, 'execute', project);
			tmp.callMethod();
		}
		
		override protected function shellData(value:Object):void
		{
			var match:Array;
			var tmpQueue:Object = value.queue; /** type of NativeProcessQueueVO **/
			var tmpProject:ProjectVO;
			var isFatal:Boolean = value.output.match(/fatal: .*/) != null;
			
			switch(tmpQueue.processType)
			{
				case GIT_REPOSITORY_TEST:
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
								plugin.modelAgainstProject[tmpProject].pathToDownloaded = (value.output == ".git") ? (tmpProject.folderLocation.fileBridge.getFile as File).nativePath : 
									(new File(value.output)).parent.nativePath;
							}
							
							// continuing fetch
							pendingProcess.push(new MethodDescriptor(GetCurrentBranchCommand, 'GetCurrentBranchCommand', tmpProject)); // store the current branch
							pendingProcess.push(new MethodDescriptor(GetRemoteURLCommand, 'GetRemoteURLCommand', tmpProject)); // store the remote URL
							
							// following will enable/disable Moonshine top menus based on project
							dispatcher.dispatchEvent(new Event(MenuPlugin.REFRESH_MENU_STATE));
						}
						
						dispatchEvent(new GeneralEvent(GIT_REPOSITORY_TEST));
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
						dispatchEvent(new GeneralEvent(GIT_REPOSITORY_TEST));
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
					dispatchEvent(new GeneralEvent(GIT_REPOSITORY_TEST, {project:value, gitRootLocation:tmpFile}));
					break;
				}
				
			} while (tmpFile != null);
		}
	}
}