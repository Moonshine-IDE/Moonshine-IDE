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
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.utils.FileDownloader;
	import actionScripts.utils.UnzipUsingAS3CommonZip;
	import actionScripts.utils.ZipUsingNP;

	import flash.events.ErrorEvent;

	import flash.events.Event;

	import flash.filesystem.File;

	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import mx.utils.UIDUtil;

	public class RunDatabaseOnVagrantJob extends DatabaseJobBase
	{
		public var deployedURL:String;

		protected var zip:ZipUsingNP;
		protected var zipUploadSource:File;

		public function RunDatabaseOnVagrantJob(server:String)
		{
			super(server);
		}

		public function zipProject(fileObject:Object):void
		{
			var path:File;
			if (fileObject is FileLocation) path = (fileObject as FileLocation).fileBridge.getFile as File;
			else if (fileObject is File) path = fileObject as File;
			if (!path)
			{
				dispatchEvent(new Event(EVENT_CONVERSION_FAILED));
				return;
			}

			zip = new ZipUsingNP();
			configureZipListeners(true);

			print("Zipping files from: " + path.nativePath);
			zipUploadSource = getZipPath();
			zip.zip(
					path,
					zipUploadSource
			);
		}

		override protected function runConversionCommandOnServer(withId:String = null):void
		{
			clearTimeout(conversioTestTimeout);
			loader = new DataAgent(
					serverURL + "/task" + (withId ? "/" + withId : ""),
					onConversionRunResponseLoaded,
					onConversionRunFault,
					withId ? null : {command: "/bin/bash /opt/domino/scripts/run_dxl_importer.sh '" + uploadedNSFFilePath + "'"},
					withId ? DataAgent.GETEVENT : DataAgent.POSTEVENT
			);
		}

		override protected function onTaskStatusCompleted(withJSONObject:Object):void
		{
			success(withJSONObject.output);
			dispatchEvent(new Event(EVENT_CONVERSION_COMPLETE));
		}

		private function getZipPath():File
		{
			var tempDirectory:File = File.cacheDirectory.resolvePath("moonshine/onDisk");
			if (!tempDirectory.exists)
			{
				tempDirectory.createDirectory();
			}

			var zipFile:File = tempDirectory.resolvePath(UIDUtil.createUID() +".zip");
			return zipFile;
		}

		private function configureZipListeners(listen:Boolean):void
		{
			if (listen)
			{
				zip.addEventListener(ZipUsingNP.EVENT_ZIP_COMPLETES, onZipCompletes, false, 0, true);
				zip.addEventListener(ZipUsingNP.EVENT_ZIP_FAILED, onZipFailed, false, 0, true);
			}
			else
			{
				zip.removeEventListener(ZipUsingNP.EVENT_ZIP_COMPLETES, onZipCompletes);
				zip.removeEventListener(ZipUsingNP.EVENT_ZIP_FAILED, onZipFailed);
				zip = null;
			}
		}

		private function onZipCompletes(event:Event):void
		{
			uploadAndRunCommandOnServer(zipUploadSource);
			configureZipListeners(false);
		}

		private function onZipFailed(event:Event):void
		{
			error(zip.errorText);
			configureZipListeners(false);
			dispatchEvent(new Event(EVENT_CONVERSION_FAILED));
		}
	}
}
