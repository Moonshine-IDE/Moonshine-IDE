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
