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
