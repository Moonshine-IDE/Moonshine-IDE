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

	public class GetXCodePathCommand extends GitCommandBase
	{
		private static const XCODE_PATH_DECTECTION:String = "xcodePathDectection";
		
		private var onXCodePathDetection:Function;
		private var xCodePathDetectionType:String;
		
		public function GetXCodePathCommand(completion:Function, against:String)
		{
			super();
			
			queue = new Vector.<Object>();
			onXCodePathDetection = completion;
			xCodePathDetectionType = against;
			
			addToQueue(new NativeProcessQueueVO('xcode-select -p', false, XCODE_PATH_DECTECTION));
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:null}, subscribeIdToWorker);
		}
		
		override protected function shellError(value:Object):void
		{
			switch (value.queue.processType)
			{
				case XCODE_PATH_DECTECTION:
				{
					if (onXCodePathDetection != null)
					{
						onXCodePathDetection(null, true, null);
					}
				}
			}
			
			// call super - it might have some essential 
			// commands to run
			super.shellError(value);
		}
		
		override protected function shellData(value:Object):void
		{
			var match:Array;
			var tmpQueue:Object = value.queue; /** type of NativeProcessQueueVO **/
			
			switch(tmpQueue.processType)
			{
				case XCODE_PATH_DECTECTION:
				{
					value.output = value.output.replace("\n", "");
					match = value.output.toLowerCase().match(/xcode.app\/contents\/developer/);
					if (match && (onXCodePathDetection != null))
					{
						onXCodePathDetection(value.output, true, xCodePathDetectionType);
						onXCodePathDetection = null;
						return;
					}
					
					match = value.output.toLowerCase().match(/commandlinetools/);
					if (match && (onXCodePathDetection != null))
					{
						onXCodePathDetection(value.output, false, xCodePathDetectionType);
						onXCodePathDetection = null;
						return;
					}
					
					onXCodePathDetection = null;
					break;
				}
			}
			
			// call super - it might have some essential
			// commands to run
			super.shellData(value);
		}
		
		override protected function unsubscribeFromWorker():void
		{
			super.unsubscribeFromWorker();
			onXCodePathDetection = null;
		}
	}
}