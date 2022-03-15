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

package actionScripts.plugins.fswatcher
{
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.events.GlobalEventDispatcher;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.Dictionary;
	import actionScripts.factory.FileLocation;
	import actionScripts.events.WatchedFileChangeEvent;
	import flash.events.Event;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.events.ProjectEvent;
	import actionScripts.locator.IDEModel;
	import flash.utils.ByteArray;
	import flash.system.WorkerDomain;
	import actionScripts.events.ApplicationEvent;

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

			if(worker)
			{
				worker.terminate();
				worker = null;
			}

			dispatcher.removeEventListener(ProjectEvent.ADD_PROJECT, onAddProject);
			dispatcher.removeEventListener(ProjectEvent.REMOVE_PROJECT, onRemoveProject);
			dispatcher.removeEventListener(ApplicationEvent.APPLICATION_EXIT, onApplicationExit);
		}

		private function onApplicationExit(event:ApplicationEvent):void
		{
			if(worker)
			{
				worker.terminate();
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
					requestAllPaths(project);
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
					var project:ProjectVO = getProjectByKey(incomingData.id);
					var paths:Array = incomingData.paths;
					var fileListUpdateEvent:WatchedFileChangeEvent = new WatchedFileChangeEvent(WatchedFileChangeEvent.PROJECT_FILES_LIST_UPDATED, null);
					fileListUpdateEvent.project = project;
					fileListUpdateEvent.paths = paths;
					dispatcher.dispatchEvent(fileListUpdateEvent);

					// trace("requestAllPaths: " + incomingData.id, "paths:" + incomingData.paths);
					// TODO: dispatch an event or something
					// ^/Users/devsena/[^/]+$
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

		private function getProjectByKey(value:int):ProjectVO
		{
			for(var key:Object in projectToWatcher)
			{
				if (projectToWatcher[key] == value)
				{
					return (key as ProjectVO);
				}
			}

			return null;
		}
	}
}