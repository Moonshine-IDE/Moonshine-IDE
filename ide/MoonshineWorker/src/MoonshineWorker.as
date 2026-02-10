////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
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
		public static var IS_WINDOWS:Boolean;
		
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
				case WorkerEvent.SET_IS_WINDOWS:
					IS_WINDOWS = incomingObject.value;
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