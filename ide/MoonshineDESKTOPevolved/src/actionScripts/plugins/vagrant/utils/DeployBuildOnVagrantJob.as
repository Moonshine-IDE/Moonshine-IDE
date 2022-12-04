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
package actionScripts.plugins.vagrant.utils
{
	import actionScripts.controllers.DataAgent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.utils.FileDownloader;
	import actionScripts.utils.UnzipUsingAS3CommonZip;
	import actionScripts.utils.ZipUsingNP;

	import flash.events.ErrorEvent;

	import flash.events.Event;

	import flash.filesystem.File;

	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import mx.utils.StringUtil;

	import mx.utils.UIDUtil;

	public class DeployBuildOnVagrantJob extends RunDatabaseOnVagrantJob
	{
		private var downloader:FileDownloader;

		public function DeployBuildOnVagrantJob(server:String)
		{
			super(server);
		}

		override protected function runConversionCommandOnServer(withId:String = null):void
		{
			clearTimeout(conversioTestTimeout);
			loader = new DataAgent(
					serverURL + "/task" + (withId ? "/" + withId : ""),
					onConversionRunResponseLoaded,
					onConversionRunFault,
					withId ? null : {command: "/bin/bash /opt/nsfodp/run_nsfodp.sh '" + uploadedNSFFilePath +"'"},
					withId ? DataAgent.GETEVENT : DataAgent.POSTEVENT
			);
		}

		override protected function onTaskStatusCompleted(withJSONObject:Object):void
		{
			var searchString:String = "Generated Database:";
			var possibleGeneratedPath:String;
			if (("output" in withJSONObject) && (withJSONObject.output.indexOf(searchString) != -1))
			{
				var stringSplit:Array = withJSONObject.output.split("\n");
				for each (var line:String in stringSplit)
				{
					if (line.indexOf(searchString) != -1)
					{
						possibleGeneratedPath = line.substr(line.indexOf(searchString) + searchString.length, line.length);
						possibleGeneratedPath = possibleGeneratedPath.replace(/(\'|\")/g, "");
						possibleGeneratedPath = StringUtil.trim(possibleGeneratedPath);
						break;
					}
				}
			}
			else
			{
				print(withJSONObject.output);
				error(withJSONObject.errorMessage);
				configureListenerOnFileDownloader(true);
				return;
			}

			// target directory should exist or create the directory
			var targetDirectory:FileLocation = IDEModel.getInstance().activeProject.folderLocation.fileBridge.resolvePath("nsfs/nsf-moonshine/target");
			if (!targetDirectory.fileBridge.exists)
			{
				targetDirectory.fileBridge.createDirectory();
			}

			print("Downloading database file from: "+ serverURL +"/file/download?path="+ possibleGeneratedPath);
			downloader = new FileDownloader(
					serverURL +"/file/download?path="+ possibleGeneratedPath,
					targetDirectory.fileBridge.resolvePath("nsf-moonshine-domino-1.0.0.nsf").fileBridge.getFile as File
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
			dispatchEvent(new Event(EVENT_CONVERSION_COMPLETE));
		}

		protected function onFileDownloadFailed(event:Event):void
		{
			configureListenerOnFileDownloader(false);
			dispatchEvent(new Event(EVENT_CONVERSION_FAILED));
		}
	}
}
