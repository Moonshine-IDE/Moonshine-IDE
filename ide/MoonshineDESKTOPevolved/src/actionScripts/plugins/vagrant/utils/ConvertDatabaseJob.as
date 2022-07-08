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

	public class ConvertDatabaseJob extends ConsoleOutputter
	{
		public static const EVENT_CONVERSION_COMPLETE:String = "eventDBConversionCompletes";
		public static const EVENT_CONVERSION_FAILED:String = "eventDBConversionFailed";

		private static const CONVERSION_TEST_INTERVAL:int = 5000; // 5 seconds

		private var serverURL:String;
		private var uploadedNSFFilePath:String;
		private var uploadedNSFFileSize:Number;
		private var loader:DataAgent;
		private var conversioTestTimeout:uint;
		private var retryCount:int;
		private var destinationProjectFolder:File;
		private var isTerminate:Boolean;
		private var downloader:FileDownloader;

		public function ConvertDatabaseJob(nsfUploadCompletionData:Object, server:String, destinationFolder:File)
		{
			if (nsfUploadCompletionData)
			{
				serverURL = server;
				destinationProjectFolder = destinationFolder;
				if ("error" in nsfUploadCompletionData)
				{
					error("Failed to upload file with exit code:"+ nsfUploadCompletionData.error +"\n"+ nsfUploadCompletionData.message);
				}
				else
				{
					uploadedNSFFilePath = nsfUploadCompletionData.path;
					uploadedNSFFileSize = Number(nsfUploadCompletionData.size);

					print("Requesting conversion job to: "+ serverURL +"/task");
					runConversionCommandOnServer();
				}
			}
		}

		public function stop():void
		{
			clearTimeout(conversioTestTimeout);
			isTerminate = true;
			if (downloader) configureListenerOnFileDownloader(false);
			warning("Conversion job terminates. Note: Some process may still runs on server.");
		}

		private function runConversionCommandOnServer(withId:String=null):void
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

		private function onConversionRunResponseLoaded(value:Object, message:String=null):void
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
					error("Conversion failed with exit code:"+ infoObject.error +"\n"+ infoObject.message);
					dispatchEvent(new Event(EVENT_CONVERSION_FAILED));
				}
				else
				{
					if ("taskStatus" in infoObject)
					{
						switch ((infoObject.taskStatus as String).toLowerCase())
						{
							case "executing":
								print("Re-try conversion check: "+ (++retryCount));
								conversioTestTimeout = setTimeout(
										runConversionCommandOnServer,
										CONVERSION_TEST_INTERVAL,
										infoObject.id
								);
								break;
							case "completed":
								if (infoObject.exitStatus != "0" && ("errorMessage" in infoObject))
								{
									error("Conversion failed with exit code: "+ infoObject.exitStatus +"\n"+ infoObject.errorMessage);
									dispatchEvent(new Event(EVENT_CONVERSION_FAILED));
								}
								else
								{
									print("Checking conversion project from: "+ serverURL + infoObject.workingDir);
									downloader = new FileDownloader(
											serverURL +"/file/download?path="+ infoObject.workingDir +"/result.zip", File.cacheDirectory.resolvePath("moonshine/result.zip")
									);
									configureListenerOnFileDownloader(true);
									downloader.load();
								}
								break;
							case "created":
								trace(">>>>>> ", infoObject.taskStatus);
								break;
							case "failed":
								if (infoObject.exitStatus != "0" && ("errorMessage" in infoObject))
								{
									error("Conversion failed with exit code: "+ infoObject.exitStatus +"\n"+ infoObject.errorMessage);
									dispatchEvent(new Event(EVENT_CONVERSION_FAILED));
								}
								break;
						}
					}
				}
			}
		}

		private function onConversionRunFault(message:String):void
		{
			loader = null;
			error("Conversion request failed: "+ message);
			dispatchEvent(new Event(EVENT_CONVERSION_FAILED));
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

		private function onFileDownloadeded(event:Event):void
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

		private function onFileDownloadFailed(event:Event):void
		{
			configureListenerOnFileDownloader(false);
		}

		private function onUnzipSuccess(event:Event):void
		{
			GlobalEventDispatcher.getInstance().dispatchEvent(
					new ProjectEvent(ProjectEvent.EVENT_IMPORT_PROJECT_NO_BROWSE_DIALOG, File.desktopDirectory.resolvePath("result"))
			);

			dispatchEvent(new Event(EVENT_CONVERSION_COMPLETE));
		}

		private function onUnzipError(event:ErrorEvent=null):void
		{
			if (event) error("Unzip error: ", event.toString());
			else error("Unzip terminated with unhandled error!");
			dispatchEvent(new Event(EVENT_CONVERSION_FAILED));
		}
	}
}
