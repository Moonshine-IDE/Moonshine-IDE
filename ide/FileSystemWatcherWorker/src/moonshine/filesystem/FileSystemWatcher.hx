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

package moonshine.filesystem;

import moonshine.events.FileSystemWatcherEvent;
import openfl.errors.ArgumentError;
import openfl.events.EventDispatcher;
import openfl.events.TimerEvent;
import openfl.utils.Timer;
#if (openfl >= "9.2.0")
import openfl.filesystem.File;
#else
import flash.filesystem.File;
#end

class FileSystemWatcher extends EventDispatcher {
	public function new(pollingMilliseconds:Int = 1000) {
		super();
		_pollingMS = pollingMilliseconds;
	}

	#if lime
	private var _fileWatcher:lime.system.FileWatcher;
	#end
	private var _watchedDirectories:Map<File, Map<String, FileInfo>> = [];
	private var _timer:Timer;
	private var _pollingMS:Int;

	public function getAllKnownFilePaths():Array<String> {
		var roots:Array<String> = [];
		for (directory in _watchedDirectories.keys()) {
			roots.push(directory.nativePath);
		}
		var result:Array<String> = [];
		for (directory in _watchedDirectories.keys()) {
			result.push(directory.nativePath);
			var fileInfoMap = _watchedDirectories.get(directory);
			for (nativePath in fileInfoMap.keys()) {
				// some of the root directories may exist as files inside
				// other root directories, so skip duplicates
				if (roots.indexOf(nativePath) == -1) {
					result.push(nativePath);
				}
			}
		}
		return result;
	}

	public function getWatched():Array<File> {
		var result:Array<File> = [];
		for (directory in _watchedDirectories.keys()) {
			result.push(directory);
		}
		return result;
	}

	public function isWatching(directory:File):Bool {
		for (otherDirectory in _watchedDirectories.keys()) {
			if (directory.nativePath == otherDirectory.nativePath) {
				return true;
			}
		}
		return false;
	}

	public function watch(directory:File):Void {
		if (directory == null || !directory.isDirectory) {
			throw new ArgumentError("FileWatcher.watch() requires a directory");
		}
		// create a copy so that it can't be modified externally
		directory = new File(directory.nativePath);
		directory.canonicalize();
		#if lime_cffi
		if (_fileWatcher == null) {
			_fileWatcher = new lime.system.FileWatcher();
			_fileWatcher.onAdd.add(fileWatcher_onAdd);
			_fileWatcher.onDelete.add(fileWatcher_onDelete);
			_fileWatcher.onModify.add(fileWatcher_onModify);
			_fileWatcher.onMove.add(fileWatcher_onMove);
		}
		_fileWatcher.addDirectory(directory.nativePath, false);
		return;
		#end
		for (otherDirectory in _watchedDirectories.keys()) {
			if (directory.nativePath == otherDirectory.nativePath) {
				throw new ArgumentError("Cannot watch directory more than once: " + directory.nativePath);
			}
		}
		var hasDirs = _watchedDirectories.keys().hasNext();
		var fileInfoForDir:Map<String, FileInfo> = [];
		var files = directory.getDirectoryListing();
		for (file in files) {
			var nativePath = file.nativePath;
			if (!fileInfoForDir.exists(nativePath)) {
				var fileInfo = new FileInfo(nativePath);
				fileInfo.modificationDate = file.modificationDate.getTime();
				fileInfoForDir.set(nativePath, fileInfo);
			}
		}
		_watchedDirectories.set(directory, fileInfoForDir);
		if (!hasDirs) {
			_timer = new Timer(_pollingMS);
			_timer.addEventListener(TimerEvent.TIMER, fileWatcher_timer_timerHandler);
			_timer.start();
		}
	}

	public function unwatch(directory:File):Void {
		directory.canonicalize();
		#if lime_cffi
		if (_fileWatcher == null) {
			return;
		}
		_fileWatcher.removeDirectory(directory.nativePath);
		return;
		#end
		for (otherDirectory in _watchedDirectories.keys()) {
			if (directory.nativePath == otherDirectory.nativePath) {
				_watchedDirectories.remove(otherDirectory);
				break;
			}
		}
		if (_timer != null && !_watchedDirectories.keys().hasNext()) {
			_timer.removeEventListener(TimerEvent.TIMER, fileWatcher_timer_timerHandler);
			_timer.reset();
			_timer = null;
		}
	}

	public function unwatchAll():Void {
		var directories = [for (directory in _watchedDirectories.keys()) directory];
		for (directory in directories) {
			unwatch(directory);
		}
	}

	private function fileWatcher_timer_timerHandler(event:TimerEvent):Void {
		for (rootDirectory in _watchedDirectories.keys()) {
			if (!rootDirectory.exists) {
				// the directory has been deleted, but not unwatched yet
				continue;
			}
			var fileInfoForDir = _watchedDirectories.get(rootDirectory);
			var files = rootDirectory.getDirectoryListing();
			for (existingNativePath in fileInfoForDir.keys()) {
				var found = false;
				var i = files.length - 1;
				while (i >= 0) {
					var file = files[i];
					if (file.nativePath == existingNativePath) {
						found = true;
						files.splice(i, 1);
						if (file.isDirectory) {
							break;
						}
						var fileInfo = fileInfoForDir.get(existingNativePath);
						var modificationDate = fileInfo.modificationDate;
						try {
							modificationDate = file.modificationDate.getTime();
						} catch(e:Dynamic) {
							// may have been deleted since calling getDirectoryListing()
							// in that case, we won't send a FILE_MODIFIED event, and we'll
							// switch to FILE_DELETED instead
							found = false;
							break;
						}
						if (modificationDate != fileInfo.modificationDate) {
							fileInfo.modificationDate = modificationDate;
							dispatchEvent(new FileSystemWatcherEvent(FileSystemWatcherEvent.FILE_MODIFIED, file));
						}
						break;
					}
					i--;
				}
				if (!found) {
					fileInfoForDir.remove(existingNativePath);
					dispatchEvent(new FileSystemWatcherEvent(FileSystemWatcherEvent.FILE_DELETED, new File(existingNativePath)));
				}
			}
			for (file in files) {
				var modificationDate = 0.0;
				try {
					modificationDate = file.modificationDate.getTime();
				} catch(e:Dynamic) {
					// the file may have been deleted since calling getDirectoryListing()
					// in that case, just skip it
					continue;
				}
				var nativePath = file.nativePath;
				var fileInfo = new FileInfo(nativePath);
				fileInfo.modificationDate = modificationDate;
				fileInfoForDir.set(nativePath, fileInfo);
				dispatchEvent(new FileSystemWatcherEvent(FileSystemWatcherEvent.FILE_CREATED, file));
			}
		}
	}

	#if lime_cffi
	private function fileWatcher_onAdd(nativePath:String):Void {
		dispatchEvent(new FileSystemWatcherEvent(FileSystemWatcherEvent.FILE_CREATED, new File(nativePath)));
	}

	private function fileWatcher_onDelete(nativePath:String):Void {
		dispatchEvent(new FileSystemWatcherEvent(FileSystemWatcherEvent.FILE_DELETED, new File(nativePath)));
	}

	private function fileWatcher_onModify(nativePath:String):Void {
		dispatchEvent(new FileSystemWatcherEvent(FileSystemWatcherEvent.FILE_MODIFIED, new File(nativePath)));
	}

	private function fileWatcher_onMove(oldNativePath:String, newNativePath:String):Void {
		dispatchEvent(new FileSystemWatcherEvent(FileSystemWatcherEvent.FILE_DELETED, new File(oldNativePath)));
		dispatchEvent(new FileSystemWatcherEvent(FileSystemWatcherEvent.FILE_CREATED, new File(newNativePath)));
	}
	#end
}

private class FileInfo {
	public function new(nativePath:String) {
		this.nativePath = nativePath;
	}

	public var nativePath:String;
	public var modificationDate:Float;
}
