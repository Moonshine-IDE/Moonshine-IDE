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
		public static const READABLE_FILES_PATTERNS:Array = ["as", "mxml", "css", "xml", "bat", "txt", "as3proj", "actionScriptProperties", "html", "js", "veditorproj"];
		
		public static var FILES_COUNT:int;
		public static var FILE_PROCESSED_COUNT:int;
		public static var FILES_FOUND_IN_COUNT:int;
		
		private var mainToWorker:MessageChannel;
		private var workerToMain:MessageChannel;
		private var projectSearchObject:Object;
		private var projects:Array;
		private var totalFoundCount:int;
		private var customFilePatterns:Array = [];
		private var isCustomFilePatterns:Boolean;
		private var isStorePathsForProbableReplace:Boolean;
		private var storedPathsForProbableReplace:Array;
		
		public function MoonshineWorker()
		{
			// receive from main
			mainToWorker = Worker.current.getSharedProperty("mainToWorker");
			// Send to main
			workerToMain = Worker.current.getSharedProperty("workerToMain");
			
			if (mainToWorker) mainToWorker.addEventListener(Event.CHANNEL_MESSAGE, onMainToWorker);
		}
		
		private function onMainToWorker(event:Event):void
		{
			var incomingObject:Object = mainToWorker.receive();
			switch (incomingObject.event)
			{
				case WorkerEvent.SEARCH_IN_PROJECTS:
					projectSearchObject = incomingObject;
					projects = projectSearchObject.value.projects;
					isStorePathsForProbableReplace = projectSearchObject.value.isShowReplaceWhenDone;
					FILES_FOUND_IN_COUNT = 0;
					storedPathsForProbableReplace = null;
					storedPathsForProbableReplace = [];
					parseProjectsTree();
					break;
				case WorkerEvent.REPLACE_FILE_WITH_VALUE:
					projectSearchObject = incomingObject;
					startReplacing();
					break;
				case WorkerEvent.GET_FILE_LIST:
					workerToMain.send({event:WorkerEvent.GET_FILE_LIST, value:storedPathsForProbableReplace});
					break;
				case WorkerEvent.SET_FILE_LIST:
					storedPathsForProbableReplace = incomingObject as Array;
					break;
			}
		}
		
		private function parseProjectsTree():void
		{
			// probable termination
			if (projects.length == 0) 
			{
				workerToMain.send({event:WorkerEvent.PROCESS_ENDS, value:FILES_FOUND_IN_COUNT});
				return;
			}
			
			FILES_COUNT = FILE_PROCESSED_COUNT = 0;
			totalFoundCount = 0;
			isCustomFilePatterns = false;
			
			var tmpWrapper:WorkerFileWrapper = new WorkerFileWrapper(new File(projects[0]), true);
			workerToMain.send({event:WorkerEvent.TOTAL_FILE_COUNT, value:FILES_COUNT});
			
			if (projectSearchObject.value.patterns != "*")
			{
				var filtered:String = projectSearchObject.value.patterns.replace(/( )/g, "");
				customFilePatterns = filtered.split(",");
				
				var hasGloablSearchSign:Boolean = customFilePatterns.some(
					function isValidExtension(item:Object, index:int, arr:Array):Boolean {
						return item == "*";
					});
				
				isCustomFilePatterns = !hasGloablSearchSign;
			}
			
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
							FILES_FOUND_IN_COUNT++;
							if (isStorePathsForProbableReplace) storedPathsForProbableReplace.push({label:value.children[c].file.nativePath, isSelected:true});
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
					workerToMain.send({event:WorkerEvent.TOTAL_FOUND_COUNT, value:value.file.nativePath +"::"+ totalFoundCount});
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
			if (isCustomFilePatterns)
			{
				return customFilePatterns.some(
					function isValidExtension(item:Object, index:int, arr:Array):Boolean {
						return item == extension;
					});
			}
			
			return READABLE_FILES_PATTERNS.some(
				function isValidExtension(item:Object, index:int, arr:Array):Boolean {
					return item == extension;
				});
		}
		
		private function startReplacing():void
		{
			for each (var i:Object in storedPathsForProbableReplace)
			{
				testFilesForValueExist(i.label, projectSearchObject.value.valueToReplace);
				workerToMain.send({event:WorkerEvent.FILE_PROCESSED_COUNT, value:i.label}); // sending path value instead of completion count in case of replace 
			}
			
			// once done 
			workerToMain.send({event:WorkerEvent.PROCESS_ENDS, value:null});
		}
		
		private function testFilesForValueExist(value:String, replace:String=null):int
		{
			var r:FileStream = new FileStream();
			var f:File = new File(value); 
			r.open(f, FileMode.READ);
			var content:String = r.readUTFBytes(f.size);
			r.close();
			
			var searchString:String = projectSearchObject.value.isEscapeChars ? escapeRegex(projectSearchObject.value.valueToSearch) : projectSearchObject.value.valueToSearch;
			var flags:String = 'g';
			if (!projectSearchObject.value.isMatchCase) flags += 'i';
			var searchRegExp:RegExp = new RegExp(searchString, flags);
			
			var foundMatches:Array = content.match(searchRegExp);
			
			if (foundMatches.length > 0)
			{
				if (replace) replaceAndSaveFile();
				content = null;
				return foundMatches.length;
			}
			
			content = null;
			return -1;
			
			/*
			 * @local
			 */
			function replaceAndSaveFile():void
			{
				content = content.replace(searchRegExp, replace);
				
				r = new FileStream();
				r.open(f, FileMode.WRITE);
				r.writeUTFBytes(content);
				r.close();
			}
		}
		
		private function escapeRegex(str:String):String 
		{
			return str.replace(/[\$\(\)\*\+\.\[\]\?\\\^\{\}\|]/g,"\\$&");
		}
	}
}