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
		protected var databaseName:String;

		private var downloader:FileDownloader;

		public function DeployBuildOnVagrantJob(server:String, dbName:String)
		{
			databaseName = dbName;
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

			print("Downloading database file from: "+ serverURL + withJSONObject.workingDir);
			var nsfFileNameSplit:Array = possibleGeneratedPath.split(File.separator);
			downloader = new FileDownloader(
					serverURL + possibleGeneratedPath,
					targetDirectory.fileBridge.resolvePath(nsfFileNameSplit[nsfFileNameSplit.length - 1]).fileBridge.getFile as File
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
