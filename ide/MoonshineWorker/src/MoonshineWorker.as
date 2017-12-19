////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import actionScripts.events.WorkerEvent;
	import actionScripts.valueObjects.WorkerFileWrapper;
	
	public class MoonshineWorker extends Sprite
	{
		public static var FILES_COUNT:int;
		public static var FILE_PROCESSED_COUNT:int;
		
		private var mainToWorker:MessageChannel;
		private var workerToMain:MessageChannel;
		private var projectSearchObject:Object;
		private var projects:Array;
		private var totalFoundCount:int;
		
		public function MoonshineWorker()
		{
			// receive from main
			mainToWorker = Worker.current.getSharedProperty("mainToWorker");
			if (mainToWorker) mainToWorker.addEventListener(Event.CHANNEL_MESSAGE, onMainToWorker);
			
			// Send to main
			workerToMain = Worker.current.getSharedProperty("workerToMain");
		}
		
		private function onMainToWorker(event:Event):void
		{
			projectSearchObject = mainToWorker.receive();
			switch (projectSearchObject.event)
			{
				case WorkerEvent.SEARCH_IN_PROJECTS:
					projects = projectSearchObject.value.projects;
					parseProjectsTree();
					break;
			}
		}
		
		private function parseProjectsTree():void
		{
			// probable termination
			if (projects.length == 0) 
			{
				workerToMain.send({event:WorkerEvent.PROCESS_ENDS, value:null});
				return;
			}
			
			FILES_COUNT = FILE_PROCESSED_COUNT = 0;
			totalFoundCount = 0;
			var tmpWrapper:WorkerFileWrapper = new WorkerFileWrapper(new File(projects[0]), true);
			workerToMain.send({event:WorkerEvent.TOTAL_FILE_COUNT, value:FILES_COUNT});
			parseChildrens(tmpWrapper);
		}
		
		private function parseChildrens(value:Object):void
		{
			if (!value) return;
			
			var extension: String = value.file.extension;
			var tmpReturnCount:int;
			
			if ((value.children is Array) && (value.children as Array).length > 0) 
			{
				var tmpTotalChildrenCount:int = value.children.length;
				for (var c:int=0; c < value.children.length; c++)
				{
					extension = value.children[c].file.extension;
					var isAcceptable:Boolean = (extension != null) ? isAcceptableResource(extension) : false;
					if (!value.children[c].file.isDirectory && isAcceptable)
					{
						tmpReturnCount = testFilesForValueExist(value.children[c].file.nativePath);
						if (tmpReturnCount == -1)
						{
							value.children.splice(c, 1);
							tmpTotalChildrenCount --;
							c--;
						}
						else
						{
							value.children[c].searchCount = tmpReturnCount;
							totalFoundCount += tmpReturnCount;
						}
					}
					else if (!value.children[c].file.isDirectory && !isAcceptable)
					{
						value.children.splice(c, 1);
						tmpTotalChildrenCount --;
						c--;
					}
					else if (value.children[c].file.isDirectory) 
					{
						//lastChildren = value.children;
						parseChildrens(value.children[c]);
						if (!value.children[c].children || (value.children[c].children && value.children[c].children.length == 0)) 
						{
							value.children.splice(c, 1);
							c--;
						}
					}
					
					notifyFileCountCompletionToMain();
				}
				
				
				// when recursive listing done
				if (value.isRoot)
				{
					notifyFileCountCompletionToMain();
					workerToMain.send({event:WorkerEvent.TOTAL_FOUND_COUNT, value:value.file.nativePath +":"+ totalFoundCount});
					workerToMain.send({event:WorkerEvent.FILTERED_FILE_COLLECTION, value:value});
					
					// restart with available next project (if any)
					projects.shift();
					var timeoutValue:uint = setTimeout(function():void
					{
						clearTimeout(timeoutValue);
						parseProjectsTree();
					}, 400);
				}
			}
			else 
			{
				notifyFileCountCompletionToMain();
			}
			
			/*
			 * @local
			 */
			function notifyFileCountCompletionToMain():void
			{
				workerToMain.send({event:WorkerEvent.FILE_PROCESSED_COUNT, value:++FILE_PROCESSED_COUNT});
			}
		}
		
		private function isAcceptableResource(extension:String):Boolean
		{
			return (extension == "as" || extension == "mxml" || 
				extension == "css" || extension == "xml" || extension == "bat" || extension == "txt"
				|| extension == "as3proj" || extension == "html" || extension == "js");
		}
		
		private function testFilesForValueExist(value:String):int
		{
			var r:FileStream = new FileStream();
			var f:File = new File(value); 
			r.open(f, FileMode.READ);
			var content:String = r.readUTFBytes(f.size);
			r.close();
			
			var flags:String = 'g';
			if (!projectSearchObject.value.isMatchCase) flags += 'i';
			var searchRegExp:RegExp = new RegExp(escapeRegex(projectSearchObject.value.valueToSearch), flags);
			var foundMatches:Array = content.match(searchRegExp);
			content = null;
			
			if (foundMatches.length > 0)
			{
				return foundMatches.length;
			}
			
			return -1;
		}
		
		private function escapeRegex(str:String):String 
		{
			return str.replace(/[\$\(\)\*\+\.\[\]\?\\\^\{\}\|]/g,"\\$&");
		}
	}
}