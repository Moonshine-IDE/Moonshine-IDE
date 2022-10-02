////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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
package actionScripts.plugins.vagrant.utils
{
	import actionScripts.controllers.DataAgent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ProjectEvent;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.utils.FileDownloader;
	import actionScripts.utils.UnzipUsingAS3CommonZip;

	import flash.events.ErrorEvent;

	import flash.events.Event;

	import flash.filesystem.File;

	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	public class ConvertDatabaseJob extends DatabaseJobBase
	{
		private var destinationProjectFolder:File;
		private var downloader:FileDownloader;

		public function ConvertDatabaseJob(server:String, destinationFolder:File)
		{
			destinationProjectFolder = destinationFolder;
			super(server);
		}

		override protected function runConversionCommandOnServer(withId:String=null):void
		{
			clearTimeout(conversioTestTimeout);
			loader = new DataAgent(
					serverURL +"/task"+ (withId ? "/"+ withId : ""),
					onConversionRunResponseLoaded,
					onConversionRunFault,
					withId ? null : {command: "/bin/bash /opt/nsf-converter-portal/scripts/nsf-odp-convert.sh '"+ uploadedNSFFilePath +"' 'result.zip'"},
					withId ? DataAgent.GETEVENT : DataAgent.POSTEVENT
			);
		}

		override protected function onTaskStatusCompleted(withJSONObject:Object):void
		{
			print("Checking conversion project from: "+ serverURL + withJSONObject.workingDir);
			downloader = new FileDownloader(
					serverURL +"/file/download?path="+ withJSONObject.workingDir +"/result.zip", File.cacheDirectory.resolvePath("moonshine/result.zip")
			);
			configureListenerOnFileDownloader(true);
			downloader.load();
		}

		private function configureListenerOnFileDownloader(listen:Boolean):void
		{
			if (listen)
			{
				downloader.addEventListener(FileDownloader.EVENT_FILE_DOWNLOADED, onFileDownloadeded, false, 0, true);
				downloader.addEventListener(FileDownloader.EVENT_FILE_DOWNLOAD_FAILED, onFileDownloadFailed, false, 0, true);
			}
			else
			{
				downloader.removeEventListener(FileDownloader.EVENT_FILE_DOWNLOADED, onFileDownloadeded);
				downloader.removeEventListener(FileDownloader.EVENT_FILE_DOWNLOAD_FAILED, onFileDownloadFailed);
				downloader = null;
			}
		}

		protected function onFileDownloadeded(event:Event):void
		{
			configureListenerOnFileDownloader(false);
			if (!destinationProjectFolder.exists)
				destinationProjectFolder.createDirectory();

			UnzipUsingAS3CommonZip.unzip(
					File.cacheDirectory.resolvePath("moonshine/result.zip"),
					destinationProjectFolder,
					onUnzipSuccess,
					onUnzipError
			);
		}

		protected function onFileDownloadFailed(event:Event):void
		{
			configureListenerOnFileDownloader(false);
			dispatchEvent(new Event(EVENT_CONVERSION_FAILED));
		}

		protected function onUnzipSuccess(event:Event):void
		{
			GlobalEventDispatcher.getInstance().dispatchEvent(
					new ProjectEvent(ProjectEvent.EVENT_IMPORT_PROJECT_NO_BROWSE_DIALOG, destinationProjectFolder)
			);

			dispatchEvent(new Event(EVENT_CONVERSION_COMPLETE));
		}

		protected function onUnzipError(event:ErrorEvent=null):void
		{
			if (event) error("Unzip error: ", event.toString());
			else error("Unzip terminated with unhandled error!");
			dispatchEvent(new Event(EVENT_CONVERSION_FAILED));
		}
	}
}
