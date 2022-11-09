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
	import com.adobe.utils.StringUtil;
	
	import mx.collections.ArrayCollection;
	
	import actionScripts.events.GeneralEvent;
	import actionScripts.events.WorkerEvent;
	import actionScripts.valueObjects.GenericSelectableObject;
	import actionScripts.valueObjects.NativeProcessQueueVO;

	public class CheckDifferenceCommand extends GitCommandBase
	{
		public static const GIT_DIFF_CHECKED:String = "gitDiffProcessCompleted";
		public static const GIT_STATUS_FILE_MODIFIED:String = "gitStatusFileModified";
		public static const GIT_STATUS_FILE_DELETED:String = "gitStatusFileDeleted";
		public static const GIT_STATUS_FILE_NEW:String = "gitStatusFileNew";
		
		private static const GIT_DIFF_CHECK:String = "checkGitDiff";
		
		private var diffResults:String = "";
		
		public function CheckDifferenceCommand()
		{
			super();
			
			queue = new Vector.<Object>();
			
			addToQueue(new NativeProcessQueueVO(getPlatformMessage(' status --porcelain'),
				false, 
				GIT_DIFF_CHECK));
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:model.activeProject.folderLocation.fileBridge.nativePath}, subscribeIdToWorker);
		}
		
		override protected function listOfProcessEnded():void
		{
			switch (processType)
			{
				case GIT_DIFF_CHECK:
					checkDiffFileExistence();
					break;
			}
		}
		
		override protected function shellData(value:Object):void
		{
			var match:Array;
			var tmpQueue:Object = value.queue; /** type of NativeProcessQueueVO **/
			
			switch(tmpQueue.processType)
			{
				case GIT_DIFF_CHECK:
				{
					diffResults += value.output;
					return;
				}
			}
			
			// call super - it might have some essential
			// commands to run
			super.shellData(value);
		}
		
		private function checkDiffFileExistence():void
		{
			var tmpPositions:ArrayCollection = new ArrayCollection();
			if (StringUtil.trim(diffResults) != "")
			{
				var contentInLineBreaks:Array = diffResults.split("\n");
				var firstPart:String;
				var secondPart:String;
				contentInLineBreaks.forEach(function(element:String, index:int, arr:Array):void
				{
					if (element != "")
					{
						element = StringUtil.trim(element);
						firstPart = element.substring(0, element.indexOf(" "));
						secondPart = element.substr(element.indexOf(" ")+1, element.length);
						
						// in some cases the output comes surrounding with double-quote
						// we need to remove them before a commit
						secondPart = secondPart.replace(/\"/g, "");
						secondPart = StringUtil.trim(secondPart);
						
						tmpPositions.addItem(new GenericSelectableObject(false, {path: secondPart, status:getFileStatus(firstPart)}));
					}
				});
				
				diffResults = "";
				dispatcher.dispatchEvent(new GeneralEvent(GIT_DIFF_CHECKED, tmpPositions));
			}
			else
			{
				dispatcher.dispatchEvent(new GeneralEvent(GIT_DIFF_CHECKED, tmpPositions));
			}
			
			/*
			 * @local
			 */
			function getFileStatus(value:String):String
			{
				if (value == "D") return GIT_STATUS_FILE_DELETED;
				else if (value == "??" || value == "A") return GIT_STATUS_FILE_NEW;
				return GIT_STATUS_FILE_MODIFIED;
			}
		}
	}
}