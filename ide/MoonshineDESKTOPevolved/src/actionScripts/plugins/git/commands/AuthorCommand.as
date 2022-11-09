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
	import actionScripts.events.WorkerEvent;
	import actionScripts.plugins.git.model.GitProjectVO;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.NativeProcessQueueVO;

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