/*
	Copyright 2021 Prominic.NET, Inc.

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License

	Author: Prominic.NET, Inc.
	No warranty of merchantability or fitness of any kind.
	Use this software at your own risk.
 */

import flash.system.MessageChannel;
import flash.system.Worker;
import moonshine.events.FileSystemWatcherEvent;
import moonshine.filesystem.FileSystemWatcher;
import moonshine.utils.GlobPatterns;
import openfl.events.Event;
import openfl.filesystem.File;

class FileSystemWatcherWorker {
	private var mainToWorker:MessageChannel;
	private var workerToMain:MessageChannel;
	private var nextWatcherID:Int = 1;
	private var watchers:Map<Int, WatcherData> = [];

	public function new() {
		// receive from main
		mainToWorker = Worker.current.getSharedProperty("mainToWorker");
		// send to main
		workerToMain = Worker.current.getSharedProperty("workerToMain");

		if (mainToWorker != null) {
			mainToWorker.addEventListener(Event.CHANNEL_MESSAGE, onMainToWorker);
		}

		workerToMain.send({event: FileSystemWatcherWorkerEvent.WORKER_READY});
	}

	private function onMainToWorker(event:Event):Void {
		var incomingObject:Any = mainToWorker.receive();
		switch (Reflect.field(incomingObject, "event")) {
			case FileSystemWatcherWorkerEvent.WATCH_DIRECTORY:
				var path = (Reflect.field(incomingObject, "path") : String);
				var recursive = Reflect.field(incomingObject, "recursive") == true;
				var exclusionGlobs:Array<String> = Std.downcast(Reflect.field(incomingObject, "exclusions"), Array);
				var directory = new File(path);
				if (!directory.exists) {
					workerToMain.send({event: FileSystemWatcherWorkerEvent.WATCH_FAULT, path: path, reason: "file doesn't exist"});
					return;
				}
				if (!directory.isDirectory) {
					workerToMain.send({event: FileSystemWatcherWorkerEvent.WATCH_FAULT, path: path, reason: "file not directory"});
					return;
				}

				try {
					var watcherID = nextWatcherID;
					nextWatcherID++;
					var watcher = new FileSystemWatcher(5000);
					watcher.addEventListener(FileSystemWatcherEvent.FILE_CREATED, onFileCreated);
					watcher.addEventListener(FileSystemWatcherEvent.FILE_DELETED, onFileDeleted);
					watcher.addEventListener(FileSystemWatcherEvent.FILE_MODIFIED, onFileModified);
					var watcherData = new WatcherData();
					watcherData.id = watcherID;
					watcherData.watcher = watcher;
					watcherData.recursive = recursive;
					watcherData.root = directory;
					if (exclusionGlobs != null) {
						watcherData.exclusions = exclusionGlobs.map(str -> GlobPatterns.toEReg(str));
					}
					watchers.set(watcherID, watcherData);
					if (watcherData.recursive) {
						watchDirectoryRecursive(directory, watcher, watcherData);
					} else {
						watcher.watch(directory);
					}
					workerToMain.send({event: FileSystemWatcherWorkerEvent.WATCH_RESULT, path: path, id: watcherID});
				} catch (e:Any) {
					workerToMain.send({event: FileSystemWatcherWorkerEvent.WATCH_FAULT, path: path, reason: "exception: " + e});
				}
			case FileSystemWatcherWorkerEvent.UNWATCH:
				var watcherID = (Reflect.field(incomingObject, "id") : Int);
				var watcherData = watchers.get(watcherID);
				if (watcherData == null) {
					workerToMain.send({event: FileSystemWatcherWorkerEvent.UNWATCH_FAULT, id: watcherID, reason: "id doesn't exist"});
					return;
				}
				try {
					watchers.remove(watcherID);
					var watcher = watcherData.watcher;
					watcher.removeEventListener(FileSystemWatcherEvent.FILE_CREATED, onFileCreated);
					watcher.removeEventListener(FileSystemWatcherEvent.FILE_DELETED, onFileDeleted);
					watcher.removeEventListener(FileSystemWatcherEvent.FILE_MODIFIED, onFileModified);
					watcher.unwatchAll();
					workerToMain.send({event: FileSystemWatcherWorkerEvent.UNWATCH_RESULT, path: watcherData.root.nativePath, id: watcherID});
				} catch (e:Any) {
					workerToMain.send({event: FileSystemWatcherWorkerEvent.UNWATCH_FAULT, id: watcherID, reason: "exception: " + e});
				}
			default:
				workerToMain.send({
					event: FileSystemWatcherWorkerEvent.WORKER_FAULT,
					reason: "unknown event: " + Reflect.field(incomingObject, "event")
				});
		}
	}

	private function watchDirectoryRecursive(directory:File, watcher:FileSystemWatcher, watcherData:WatcherData):Void {
		if (isExcluded(directory, watcherData)) {
			return;
		}
		watcher.watch(directory);
		for (file in directory.getDirectoryListing()) {
			if (file.isDirectory) {
				watchDirectoryRecursive(file, watcher, watcherData);
			}
		}
	}

	private function unwatchDirectoryRecursive(directory:File, watcher:FileSystemWatcher):Void {
		watcher.unwatch(directory);
		for (file in directory.getDirectoryListing()) {
			if (file.isDirectory) {
				unwatchDirectoryRecursive(file, watcher);
			}
		}
	}

	private function getWatcherData(watcher:FileSystemWatcher):WatcherData {
		for (id => watcherData in watchers) {
			if (watcherData.watcher == watcher) {
				return watcherData;
			}
		}
		return null;
	}

	private function isExcluded(file:File, watcherData:WatcherData):Bool {
		if (watcherData.exclusions == null || watcherData.exclusions.length == 0) {
			return false;
		}
		var relativePath:String = watcherData.root.getRelativePath(file);
		for (exclusion in watcherData.exclusions) {
			if (exclusion.match(relativePath)) {
				return true;
			}
		}
		return false;
	}

	private function onFileCreated(event:FileSystemWatcherEvent):Void {
		var watcher = cast(event.currentTarget, FileSystemWatcher);
		var watcherData = getWatcherData(watcher);
		var file = event.file;
		if (isExcluded(file, watcherData)) {
			return;
		}
		if (file.isDirectory && watcherData.recursive) {
			watchDirectoryRecursive(file, watcher, watcherData);
		}
		workerToMain.send({
			event: FileSystemWatcherWorkerEvent.FILE_CREATED,
			path: event.file.nativePath
		});
	}

	private function onFileDeleted(event:FileSystemWatcherEvent):Void {
		var watcher = cast(event.currentTarget, FileSystemWatcher);
		var watcherData = getWatcherData(watcher);
		var file = event.file;
		if (isExcluded(file, watcherData)) {
			return;
		}
		if (file.isDirectory && watcherData.recursive) {
			unwatchDirectoryRecursive(file, watcher);
		}
		workerToMain.send({
			event: FileSystemWatcherWorkerEvent.FILE_DELETED,
			path: event.file.nativePath
		});
	}

	private function onFileModified(event:FileSystemWatcherEvent):Void {
		var watcher = cast(event.currentTarget, FileSystemWatcher);
		var watcherData = getWatcherData(watcher);
		var file = event.file;
		if (isExcluded(file, watcherData)) {
			return;
		}
		workerToMain.send({
			event: FileSystemWatcherWorkerEvent.FILE_MODIFIED,
			path: file.nativePath
		});
	}
}

private class WatcherData {
	public function new() {}

	public var id:Int;
	public var watcher:FileSystemWatcher;
	public var recursive:Bool;
	public var root:File;
	public var exclusions:Array<EReg>;
}
