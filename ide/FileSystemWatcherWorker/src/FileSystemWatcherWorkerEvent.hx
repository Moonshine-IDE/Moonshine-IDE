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
class FileSystemWatcherWorkerEvent {
	public static final WATCH_DIRECTORY:String = "watchDirectory";
	public static final UNWATCH:String = "unwatch";

	public static final WORKER_READY:String = "workerReady";
	public static final WORKER_FAULT:String = "workerFault";
	public static final WATCH_RESULT:String = "watchResult";
	public static final WATCH_FAULT:String = "watchFault";
	public static final UNWATCH_RESULT:String = "unwatchResult";
	public static final UNWATCH_FAULT:String = "unwatchFault";

	public static final FILE_CREATED:String = "fileCreated";
	public static final FILE_DELETED:String = "fileDeleted";
	public static final FILE_MODIFIED:String = "fileModified";
}
