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
	import actionScripts.valueObjects.NativeProcessQueueVO;

	public class CheckGitAvailabilityCommand extends GitCommandBase
	{
		private static const GIT_AVAIL_DECTECTION:String = "gitAvailableDectection";
		
		public function CheckGitAvailabilityCommand()
		{
			super();
			
			var versionMessage:String = getPlatformMessage(' --version');
			if(!versionMessage)
			{
				//when the git path isn't set at all, getPlatformMessage()
				//returns null because there's no command to run
				plugin.setGitAvailable(false);
				return;
			}
			
			queue = new Vector.<Object>();
			addToQueue(new NativeProcessQueueVO(versionMessage, false, GIT_AVAIL_DECTECTION));
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:null}, subscribeIdToWorker);
		}
		
		override protected function shellData(value:Object):void
		{
			var match:Array;
			var tmpQueue:Object = value.queue; /** type of NativeProcessQueueVO **/
			
			switch(tmpQueue.processType)
			{
				case GIT_AVAIL_DECTECTION:
				{
					match = value.output.toLowerCase().match(/git version/);
					if (match) 
					{
						plugin.setGitAvailable(true);
						return;
					}
					
					match = value.output.toLowerCase().match(/'git' is not recognized as an internal or external command/);
					if (match)
					{
						plugin.setGitAvailable(false);
						return;
					}
					break;
				}
			}
			
			// call super - it might have some essential
			// commands to run
			super.shellData(value);
		}
	}
}