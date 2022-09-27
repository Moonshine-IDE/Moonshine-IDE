////////////////////////////////////////////////////////////////////////////////
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License
//
// No warranty of merchantability or fitness of any kind.
// Use this software at your own risk.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.genesis.utils
{
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.utils.FileDownloader;
	import actionScripts.utils.FileUtils;
	import actionScripts.utils.UnzipUsingAS3CommonZip;

	import flash.events.ErrorEvent;

	import flash.events.Event;

	import flash.filesystem.File;

	import mx.events.CloseEvent;

	import mx.utils.UIDUtil;

	import org.as3commons.zip.Zip;
	import org.as3commons.zip.ZipFile;

	import spark.components.Alert;

	public class ImportGenesisCatalog extends ConsoleOutputter
	{
		private var downloadURL:String;
		private var fileDownloader:FileDownloader;
		private var tempDownloadDirectory:File;
		private var targetDownloadDirectory:File;
		private var model:IDEModel = IDEModel.getInstance();

		public function ImportGenesisCatalog(fromURL:String)
		{
			super();

			downloadURL = fromURL;
			startDownloading();
		}

		private function startDownloading():void
		{
			tempDownloadDirectory = gettempDownloadDirectoryPath();

			warning("Downloading Genesis Catalog");
			fileDownloader = new FileDownloader(downloadURL, tempDownloadDirectory.resolvePath("catalog.zip"));
			addFileDownloaderListeners();
			fileDownloader.load();
		}

		private function addFileDownloaderListeners():void
		{
			fileDownloader.addEventListener(FileDownloader.EVENT_FILE_DOWNLOADED, onTemplatesZipDownloaded);
			fileDownloader.addEventListener(FileDownloader.EVENT_FILE_DOWNLOAD_FAILED, onTemplatesZipDownloadFailed);
			fileDownloader.addEventListener(FileDownloader.EVENT_FILE_DOWNLOAD_PROGRESS, onTemplatesZipDownloadProgress);
		}

		private function removeAndCleanFileDownloaderListeners():void
		{
			fileDownloader.removeEventListener(FileDownloader.EVENT_FILE_DOWNLOADED, onTemplatesZipDownloaded);
			fileDownloader.removeEventListener(FileDownloader.EVENT_FILE_DOWNLOAD_FAILED, onTemplatesZipDownloadFailed);
			fileDownloader.removeEventListener(FileDownloader.EVENT_FILE_DOWNLOAD_PROGRESS, onTemplatesZipDownloadProgress);
			fileDownloader = null;
		}

		private function onTemplatesZipDownloaded(event:Event):void
		{
			removeAndCleanFileDownloaderListeners();

			success("Success: Genesis Catalog downloaded");
			selectProjectLocation();
		}

		private function onTemplatesZipDownloadFailed(event:Event):void
		{
			removeAndCleanFileDownloaderListeners();
		}

		private function onTemplatesZipDownloadProgress(event:Event):void
		{
			notice("File downloaded: "+ fileDownloader.downloadPercent +"%");
		}

		private function selectProjectLocation():void
		{
			model.fileCore.browseForDirectory("Select Parent Directory", onDirectorySelected);
		}

		private function onDirectorySelected(directory:File):void
		{
			targetDownloadDirectory = directory;
			UnzipUsingAS3CommonZip.unzip(
					tempDownloadDirectory.resolvePath("catalog.zip"),
					tempDownloadDirectory.resolvePath("unzip"),
					onUnzipSuccess,
					onUnzipError
			);
		}

		protected function onUnzipSuccess(event:Event):void
		{
			var fzip:Zip = UnzipUsingAS3CommonZip.zip;
			var fzipFile:ZipFile = fzip.getFileAt(0);
			targetDownloadDirectory = targetDownloadDirectory.resolvePath(fzipFile.filename);

			// check if nested root-directory or
			// all files placed on root
			var files:Array = tempDownloadDirectory.resolvePath("unzip").getDirectoryListing();
			if ((files.length == 1) && (files[0] as File).isDirectory)
			{
				// overwrite cehck
				if (targetDownloadDirectory.exists)
				{
					Alert.YES_LABEL = "Browse";
					Alert.show(targetDownloadDirectory.nativePath +" already exists.\nSelect a new parent directory?", "Error!", Alert.YES|Alert.CANCEL, null, onAlertListener);
				}
				else
				{
					print("This may take some time..");
					FileUtils.copyFileAsync(
							tempDownloadDirectory.resolvePath("unzip/"+ fzipFile.filename),
							targetDownloadDirectory,
							false,
							onProjectFilesMoved,
							onProjectFilesMoveFailed
					);
				}
			}
			else
			{
				error("Unsupported zip file: multiple files at base level.");
			}

			/*
			 * @local
			 */
			function onAlertListener(event2:CloseEvent):void
			{
				Alert.YES_LABEL = "Yes";
				if (event2.detail == Alert.YES)
				{
					selectProjectLocation();
				}
			}
		}

		protected function onProjectFilesMoved():void
		{
			GlobalEventDispatcher.getInstance().dispatchEvent(
					new ProjectEvent(ProjectEvent.EVENT_IMPORT_PROJECT_NO_BROWSE_DIALOG, targetDownloadDirectory)
			);
			success("Project downloaded at: "+ targetDownloadDirectory.nativePath);
		}

		protected function onProjectFilesMoveFailed(value:String):void
		{
			error("File copy error: "+ value);
		}

		protected function onUnzipError(event:ErrorEvent=null):void
		{
			if (event) error("Unzip error: ", event.toString());
			else error("Unzip terminated with unhandled error!");
		}

		private function gettempDownloadDirectoryPath():File
		{
			var tempDirectory:FileLocation = model.fileCore.resolveTemporaryDirectoryPath("moonshine/genesis");
			if (!tempDirectory.fileBridge.exists)
			{
				tempDirectory.fileBridge.createDirectory();
			}

			var instanceDirectory:File = tempDirectory.fileBridge.resolvePath(UIDUtil.createUID()).fileBridge.getFile as File;
			instanceDirectory.createDirectory();
			return instanceDirectory;
		}
	}
}
