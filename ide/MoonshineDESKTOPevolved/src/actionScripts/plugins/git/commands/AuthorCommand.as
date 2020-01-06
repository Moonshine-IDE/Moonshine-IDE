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
	import actionScripts.events.WorkerEvent;
	import actionScripts.plugins.git.model.GitProjectVO;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.vo.NativeProcessQueueVO;

	public class AuthorCommand extends GitCommandBase
	{
		private static const GIT_QUERY_USER_NAME:String = "gitQueryUserName";
		private static const GIT_QUERY_USER_EMAIL:String = "gitQueryUserEmail";
		
		private var onCompletion:Function;
		private var isGitUserName:Boolean;
		private var isGitUserEmail:Boolean;
		
		public function AuthorCommand()
		{
			super();
		}
		
		public function getAuthor(onCompletion:Function):void
		{
			this.onCompletion = onCompletion;
			isGitUserEmail = isGitUserName = false;
			queue = new Vector.<Object>();
			
			addToQueue(new NativeProcessQueueVO(getPlatformMessage(' config user.name'), false, GIT_QUERY_USER_NAME, model.activeProject.folderLocation.fileBridge.nativePath));
			addToQueue(new NativeProcessQueueVO(getPlatformMessage(' config user.email'), false, GIT_QUERY_USER_EMAIL, model.activeProject.folderLocation.fileBridge.nativePath));
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:model.activeProject.folderLocation.fileBridge.nativePath}, subscribeIdToWorker);
		}
		
		public function setAuthor(userObject:Object):void
		{
			if (!model.activeProject) return;
			
			isGitUserEmail = isGitUserName = false;
			queue = new Vector.<Object>();
			
			addToQueue(new NativeProcessQueueVO(
				ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +" config user.name $'"+ userObject.userName +"'" : 
				gitBinaryPathOSX +'&&config&&user.name&&'+ userObject.userName, 
				false, GIT_QUERY_USER_NAME, model.activeProject.folderLocation.fileBridge.nativePath));
			addToQueue(new NativeProcessQueueVO(
				ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +" config user.email $'"+ userObject.email +"'" : 
				gitBinaryPathOSX +'&&config&&user.email&&'+ userObject.email, 
				false, GIT_QUERY_USER_EMAIL, model.activeProject.folderLocation.fileBridge.nativePath));
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:model.activeProject.folderLocation.fileBridge.nativePath}, subscribeIdToWorker);
		}
		
		override protected function unsubscribeFromWorker():void
		{
			super.unsubscribeFromWorker();
			onCompletion = null;
		}
		
		override protected function shellData(value:Object):void
		{
			var match:Array;
			var tmpQueue:Object = value.queue; /** type of NativeProcessQueueVO **/
			var tmpProject:ProjectVO;
			
			switch(tmpQueue.processType)
			{
				case GIT_QUERY_USER_NAME:
				{
					tmpProject = UtilsCore.getProjectByPath(tmpQueue.extraArguments[0]);
					plugin.modelAgainstProject[tmpProject].sessionUserName = value.output.replace("\n", "");
					isGitUserName = true;
					return;
				}
				case GIT_QUERY_USER_EMAIL:
				{
					tmpProject = UtilsCore.getProjectByPath(tmpQueue.extraArguments[0]);
					plugin.modelAgainstProject[tmpProject].sessionUserEmail = value.output.replace("\n", "");
					isGitUserEmail = true;
					return;
				}
			}
			
			// call super - it might have some essential
			// commands to run
			super.shellData(value);
		}
		
		override protected function listOfProcessEnded():void
		{
			switch (processType)
			{
				case GIT_QUERY_USER_EMAIL:
					var tmpVO:GitProjectVO = model.activeProject ? plugin.modelAgainstProject[model.activeProject] : null;
					if (tmpVO && !isGitUserEmail) tmpVO.sessionUserEmail = null;
					if (tmpVO && !isGitUserName) tmpVO.sessionUserName = null;
					this.onCompletion(tmpVO);
					this.onCompletion = null;
					break;
			}
		}
	}
}