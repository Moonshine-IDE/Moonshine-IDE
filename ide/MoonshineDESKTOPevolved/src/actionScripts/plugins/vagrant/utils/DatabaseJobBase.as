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
	import actionScripts.events.FileUploaderEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.utils.uploadUsingURLLoader.FileUploaderUsingURLLoader;

	import flash.events.ErrorEvent;

	import flash.events.Event;

	import flash.filesystem.File;

	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	public class DatabaseJobBase extends ConsoleOutputter
	{
		public static const EVENT_CONVERSION_COMPLETE:String = "eventDBConversionCompletes";
		public static const EVENT_CONVERSION_FAILED:String = "eventDBConversionFailed";
		public static const EVENT_VAGRANT_UPLOAD_COMPLETES:String = "eventFileUploadOnVagrantCompletes";
		public static const EVENT_VAGRANT_UPLOAD_FAILED:String = "eventFileUploadOnVagrantFailed";

		private static const CONVERSION_TEST_INTERVAL:int = 5000; // 5 seconds

		protected var loader:DataAgent;
		protected var conversioTestTimeout:uint;
		protected var serverURL:String;
		protected var uploadedNSFFilePath:String;

		private var uploadedNSFFileSize:Number;
		private var retryCount:int;
		private var isTerminate:Boolean;
		private var fileUploader:FileUploaderUsingURLLoader;

		public function DatabaseJobBase(server:String)
		{
			serverURL = server;
		}

		public function uploadAndRunCommandOnServer(file:File):void
		{
			fileUploader = new FileUploaderUsingURLLoader();
			configureFileUploadListeners(true);

			warning("Trying to upload request to: " + serverURL + "/file/upload. This may take some time..");
			fileUploader.upload(
					new FileLocation(file.nativePath),
					serverURL + "/file/upload?rand="+ Math.random(),
					"file"
			);
		}

		public function stop():void
		{
			clearTimeout(conversioTestTimeout);
			isTerminate = true;
			warning("Conversion job terminates. Note: Some process may still runs on server.");
		}

		protected function runConversionCommandOnServer(withId:String=null):void
		{
			clearTimeout(conversioTestTimeout);

			// server call needs to be designed by the implementing class
			// eg.
			//loader = new DataAgent(
			//		serverURL +"/task"+ (withId ? "/"+ withId : ""),
			//		onConversionRunResponseLoaded,
			//		onConversionRunFault,
			//		withId ? null : {command: "/bin/bash /opt/nsf-converter-portal/scripts/some-server-script.sh"},
			//		withId ? DataAgent.GETEVENT : DataAgent.POSTEVENT
			//);
		}

		protected function onConversionRunResponseLoaded(value:Object, message:String=null):void
		{
			// probable termination
			if (isTerminate)
				return;

			var infoObject:Object = JSON.parse(value as String);
			loader = null;

			if (infoObject)
			{
				if ("error" in infoObject)
				{
					if (infoObject.output)
					{
						print("%s", "Output: "+ infoObject.output);
					}
					error("%s", "Conversion failed with exit code:"+ infoObject.error +"\n"+ infoObject.message);
					dispatchEvent(new Event(EVENT_CONVERSION_FAILED));
				}
				else
				{
					if ("taskStatus" in infoObject)
					{
						switch ((infoObject.taskStatus as String).toLowerCase())
						{
							case "executing":
								if (infoObject.output)
								{
									print("%s", "Output: "+ infoObject.output);
								}
								print("%s", "Re-try conversion(#"+ infoObject.id +") check: "+ (++retryCount));
								conversioTestTimeout = setTimeout(
										runConversionCommandOnServer,
										CONVERSION_TEST_INTERVAL,
										infoObject.id
								);
								break;
							case "completed":
								if (infoObject.exitStatus != "0" && ("errorMessage" in infoObject))
								{
									if (infoObject.output) print("%s", "Output: "+ infoObject.output);
									error("%s", "Conversion failed with exit code: "+ infoObject.exitStatus +"\n"+ infoObject.errorMessage);
									dispatchEvent(new Event(EVENT_CONVERSION_FAILED));
								}
								else
								{
									onTaskStatusCompleted(infoObject);
								}
								break;
							case "created":
								trace(">>>>>> ", infoObject.taskStatus);
								break;
							case "failed":
								if (infoObject.exitStatus != "0" && ("errorMessage" in infoObject))
								{
									if (infoObject.output) print("%s", "Output: "+ infoObject.output);
									error("%s", "Conversion failed with exit code: "+ infoObject.exitStatus +"\n"+ infoObject.errorMessage);
									dispatchEvent(new Event(EVENT_CONVERSION_FAILED));
								}
								break;
						}
					}
				}
			}
		}

		protected function onTaskStatusCompleted(withJSONObject:Object):void
		{
			dispatchEvent(new Event(EVENT_CONVERSION_COMPLETE));
		}

		protected function onConversionRunFault(message:String):void
		{
			loader = null;
			error("%s", "Conversion request failed: "+ message);
			dispatchEvent(new Event(EVENT_CONVERSION_FAILED));
		}

		private function configureFileUploadListeners(listen:Boolean):void
		{
			if (listen)
			{
				fileUploader.addEventListener(FileUploaderEvent.EVENT_UPLOAD_COMPLETE, onFileUploadedData, false, 0, true);
				fileUploader.addEventListener(FileUploaderEvent.EVENT_UPLOAD_ERROR, onFileUploadError, false, 0, true);
			}
			else
			{
				fileUploader.removeEventListener(FileUploaderEvent.EVENT_UPLOAD_COMPLETE, onFileUploadedData);
				fileUploader.removeEventListener(FileUploaderEvent.EVENT_UPLOAD_ERROR, onFileUploadError);
				fileUploader = null;
			}
		}

		private function onFileUploadedData(event:FileUploaderEvent):void
		{
			if (event.value && ((event.value as String) != ""))
			{
				var nsfUploadCompletionData:Object = JSON.parse(event.value as String);
				if ("error" in nsfUploadCompletionData)
				{
					error("%s", "Failed to upload file with exit code:"+ nsfUploadCompletionData.error +"\n"+ nsfUploadCompletionData.message);
					fileUploadFailRelease();
				}
				else
				{
					uploadedNSFFilePath = nsfUploadCompletionData.path;
					uploadedNSFFileSize = Number(nsfUploadCompletionData.size);

					print("%s", "Requesting conversion job to: "+ serverURL +"/task");
					dispatchEvent(new Event(EVENT_VAGRANT_UPLOAD_COMPLETES));
					runConversionCommandOnServer();
				}
			}
		}

		private function onFileUploadError(event:FileUploaderEvent):void
		{
			error("%s", "Failed to upload file on server:\n" + (event.value as String));
			fileUploadFailRelease();
		}

		private function fileUploadFailRelease():void
		{
			configureFileUploadListeners(false);
			dispatchEvent(new Event(EVENT_VAGRANT_UPLOAD_FAILED));
			dispatchEvent(new Event(EVENT_CONVERSION_FAILED));
		}
	}
}
