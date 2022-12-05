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

package actionScripts.plugins.fswatcher
{
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	import actionScripts.events.ApplicationEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.WatchedFileChangeEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;

	public class FSWatcherPlugin extends PluginBase implements IPlugin
	{
		[Embed(source="/../../MoonshineSharedCore/src/elements/swf/FileSystemWatcherWorker.swf", mimeType="application/octet-stream")]
		private static const WORKER_SWF:Class;

		private static const DEFAULT_EXCLUSIONS:Array = [
			"**/.git",
			"**/.svn",
			"**/.hg",
			"**/CVS",
			"**/.DS_Store",
			"**/Thumbs.db"
		];

		override public function get name():String
		{
			return "File System Watcher Plugin";
		}

        override public function get author():String
        {
            return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team";
        }

		override public function get description():String
		{
			return "Watches for changes to the file system.";
		}
		
		private var workerReady:Boolean = false;
		private var mainToWorker:MessageChannel;
		private var workerToMain:MessageChannel;
		private var worker:Worker;
		private var projectToWatcher:Dictionary = new Dictionary();
		
		override public function activate():void
		{
			super.activate();

			var workerBytes:ByteArray = new WORKER_SWF() as ByteArray;
			worker = WorkerDomain.current.createWorker(workerBytes, true);
			
			// send to worker
			mainToWorker = Worker.current.createMessageChannel(worker);
			worker.setSharedProperty("mainToWorker", mainToWorker);
			
			// receive from worker
			workerToMain = worker.createMessageChannel(Worker.current);
			workerToMain.addEventListener(Event.CHANNEL_MESSAGE, onWorkerToMain);
			worker.setSharedProperty("workerToMain", workerToMain);
			worker.start();

			dispatcher.addEventListener(ProjectEvent.ADD_PROJECT, onAddProject, false, 0, true);
			dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, onRemoveProject, false, 0, true);
			dispatcher.addEventListener(ApplicationEvent.APPLICATION_EXIT, onApplicationExit, false, 0, true);
		}
		
		override public function deactivate():void
		{
			super.deactivate();

			if(workerToMain)
			{
				workerToMain.close();
				workerToMain = null;
			}
			if(mainToWorker)
			{
				mainToWorker.close();
				mainToWorker = null;
			}
			if(worker)
			{
				//worker.terminate();
				worker = null;
			}

			dispatcher.removeEventListener(ProjectEvent.ADD_PROJECT, onAddProject);
			dispatcher.removeEventListener(ProjectEvent.REMOVE_PROJECT, onRemoveProject);
			dispatcher.removeEventListener(ApplicationEvent.APPLICATION_EXIT, onApplicationExit);
		}

		private function onApplicationExit(event:ApplicationEvent):void
		{
			if(workerToMain)
			{
				workerToMain.close();
				workerToMain = null;
			}
			if(mainToWorker)
			{
				mainToWorker.close();
				mainToWorker = null;
			}
			if(worker)
			{
				//for some reason, terminating causes the AIR app to crash
				//before it can complete some other things
				//worker.terminate();
				worker = null;
			}
		}

		private function addProject(project:ProjectVO):void
		{
			projectToWatcher[project] = -1;
			mainToWorker.send({
				event: "watchDirectory",
				path: project.folderLocation.fileBridge.nativePath,
				recursive: true,
				exclusions: DEFAULT_EXCLUSIONS
			});
		}

		private function removeProject(project:ProjectVO):void
		{
			var id:int = projectToWatcher[project];
			delete projectToWatcher[project];
			mainToWorker.send({
				event: "unwatch",
				id: id
			});
		}

		private function requestAllPaths(project:ProjectVO):void
		{
			mainToWorker.send({
				event: "requestAllPaths",
				id: projectToWatcher[project]
			});
		}

		private function onAddProject(event:ProjectEvent):void
		{
			if(!workerReady)
			{
				return;
			}
			addProject(event.project);
		}

		private function onRemoveProject(event:ProjectEvent):void
		{
			if(!workerReady)
			{
				return;
			}
			removeProject(event.project);
		}

		private function onWorkerReady():void
		{
			workerReady = true;
			var projects:Array = IDEModel.getInstance().projects.toArray();
			for each(var project:Object in projects) {
				addProject(ProjectVO(project));
			}
		}

		private function onWatchResult(result:Object):void
		{
			var resultPath:String = result.path;
			for(var key:Object in projectToWatcher)
			{
				var project:ProjectVO = ProjectVO(key);
				if(resultPath == project.folderLocation.fileBridge.nativePath)
				{
					projectToWatcher[project] = result.id;
					break;
				}
			}
		}
		
		private function onWorkerToMain(event:Event): void
		{
			var incomingData:Object = workerToMain.receive();
			
			switch(incomingData.event)
			{
				case "workerReady":
					// trace("worker ready");
					onWorkerReady();
					break;
				case "watchResult":
					// trace("watch result: " + incomingData.path, incomingData.id);
					onWatchResult(incomingData);
					break;
				case "watchFault":
					trace("watch fault: " + incomingData.path, incomingData.reason);
					break;
				case "unwatchResult":
					// nothing to do here
					break;
				case "unwatchFault":
					trace("unwatch fault: " + incomingData.id, incomingData.reason);
					break;
				case "requestAllPathsResult":
					// trace("requestAllPaths: " + incomingData.id, "paths:" + incomingData.paths);
					// TODO: dispatch an event or something
					break;
				case "requestAllPathsFault":
					trace("requestAllPaths fault: " + incomingData.id, incomingData.reason);
					break;
				case "fileCreated":
					var createdFile:FileLocation = new FileLocation(incomingData.path);
					dispatcher.dispatchEvent(new WatchedFileChangeEvent(WatchedFileChangeEvent.FILE_CREATED, createdFile));
					break;
				case "fileDeleted":
					var deletedFile:FileLocation = new FileLocation(incomingData.path);
					dispatcher.dispatchEvent(new WatchedFileChangeEvent(WatchedFileChangeEvent.FILE_DELETED, deletedFile));
					break;
				case "fileModified":
					var modifiedFile:FileLocation = new FileLocation(incomingData.path);
					dispatcher.dispatchEvent(new WatchedFileChangeEvent(WatchedFileChangeEvent.FILE_MODIFIED, modifiedFile));
					break;
				default:
					trace("Unknown file system watcher message: " + JSON.stringify(incomingData));
			}
		}
	}
}