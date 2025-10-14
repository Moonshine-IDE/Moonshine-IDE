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
package moonshine.filesystem;

import moonshine.events.FileSystemWatcherEvent;
import openfl.errors.ArgumentError;
import openfl.errors.Error;
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
			// repeat only once. we'll reset and start fresh after checking for
			// file changes so that there's a long enough delay between checks.
			_timer = new Timer(_pollingMS, 1);
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
			var files:Array<File> = null;
			try {
				files = rootDirectory.getDirectoryListing();
			} catch (error:Error) {
				// this may fail sometimes. for instance, if the directory was
				// deleted after we checked the value of exists above
				continue;
			}
			for (existingNativePath in fileInfoForDir.keys()) {
				var found = false;
				var i = files.length - 1;
				while (i >= 0) {
					var file = files[i];
					if (file != null && file.nativePath == existingNativePath) {
						found = true;
						// it can be faster to check for null than to modify the
						// array by calling splice() because splice() can cause
						// a lot of garbage collection on some targets.
						files[i] = null;
						if (file.isDirectory) {
							break;
						}
						var fileInfo = fileInfoForDir.get(existingNativePath);
						var modificationDate = fileInfo.modificationDate;
						try {
							modificationDate = file.modificationDate.getTime();
						} catch (e:Dynamic) {
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
				if (file == null) {
					continue;
				}
				var modificationDate = 0.0;
				try {
					modificationDate = file.modificationDate.getTime();
				} catch (e:Dynamic) {
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
		// if checking for changes took an especially long time, the next timer
		// event could be almost immediately. let's wait the full polling time
		// before checking again so that CPU usage isn't constant.
		_timer.stop();
		_timer.reset();
		_timer.start();
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
