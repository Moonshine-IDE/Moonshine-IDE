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
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.Dictionary;
	
	import actionScripts.events.WorkerEvent;
	import actionScripts.utils.WorkerListOfNativeProcess;
	import actionScripts.utils.WorkerSearchForProjects;
	import actionScripts.utils.WorkerSearchInProjects;
	
	public class MoonshineWorker extends Sprite
	{
		public static var IS_MACOS:Boolean;
		
		public var mainToWorker:MessageChannel;
		public var workerToMain:MessageChannel;
		
		private var gitListProcessClasses:Dictionary = new Dictionary();
		private var searchInProjects:WorkerSearchInProjects = new WorkerSearchInProjects();
		private var searchForProjects:WorkerSearchForProjects = new WorkerSearchForProjects();
		
		public function MoonshineWorker()
		{
			// receive from main
			mainToWorker = Worker.current.getSharedProperty("mainToWorker");
			// Send to main
			workerToMain = Worker.current.getSharedProperty("workerToMain");
			
			if (mainToWorker) mainToWorker.addEventListener(Event.CHANNEL_MESSAGE, onMainToWorker);
			searchInProjects.worker = searchForProjects.worker = this;
		}
		
		private function onMainToWorker(event:Event):void
		{
			var incomingObject:Object = mainToWorker.receive();
			switch (incomingObject.event)
			{
				case WorkerEvent.SET_IS_MACOS:
					IS_MACOS = incomingObject.value;
					break;
				case WorkerEvent.SEARCH_IN_PROJECTS:
					searchInProjects.projectSearchObject = incomingObject;
					searchInProjects.initiateBeforeNewSearch();
					break;
				case WorkerEvent.REPLACE_FILE_WITH_VALUE:
					searchInProjects.projectSearchObject = incomingObject;
					searchInProjects.startReplacing();
					break;
				case WorkerEvent.GET_FILE_LIST:
					workerToMain.send({event:WorkerEvent.GET_FILE_LIST, value:searchInProjects.storedPathsForProbableReplace});
					break;
				case WorkerEvent.SET_FILE_LIST:
					searchInProjects.storedPathsForProbableReplace = incomingObject.value as Array;
					break;
				case WorkerEvent.RUN_LIST_OF_NATIVEPROCESS:
					// the list of np must have a non-null sub-id
					if (incomingObject.subscriberUdid) 
						getListProcessClass(incomingObject.subscriberUdid).runProcesses(incomingObject.value);
					break;
				case WorkerEvent.PROCESS_STDINPUT_WRITEUTF:
					// the list of np must have a non-null sub-id
					if (incomingObject.subscriberUdid &&
							gitListProcessClasses[incomingObject.subscriberUdid] != undefined)
						getListProcessClass(incomingObject.subscriberUdid).writeToProcesses(incomingObject.value);
					break;
				case WorkerEvent.SEARCH_PROJECTS_IN_DIRECTORIES:
					searchForProjects.projectSearchObject = incomingObject;
					searchForProjects.initiateNewSearch();
					break;
			}
		}
		
		private function getListProcessClass(udid:String):WorkerListOfNativeProcess
		{
			if (gitListProcessClasses[udid] != undefined) return gitListProcessClasses[udid];
			
			// in case of non-existence
			var gitProcess:WorkerListOfNativeProcess = new WorkerListOfNativeProcess();
			gitProcess.worker = this;
			gitProcess.subscriberUdid = udid;
			gitListProcessClasses[udid] = gitProcess;
			return gitProcess;
		}
	}
}