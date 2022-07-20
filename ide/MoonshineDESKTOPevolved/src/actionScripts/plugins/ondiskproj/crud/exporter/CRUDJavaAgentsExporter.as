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
package actionScripts.plugins.ondiskproj.crud.exporter
{
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.MenuEvent;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.plugin.templating.TemplatingHelper;
	import actionScripts.utils.FileDownloader;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectReferenceVO;

	import flash.events.ErrorEvent;

	import flash.events.Event;
	import flash.filesystem.File;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	import mx.utils.UIDUtil;
	import org.as3commons.zip.Zip;
	import org.as3commons.zip.ZipEvent;
	import org.as3commons.zip.ZipFile;

	public class CRUDJavaAgentsExporter extends ConsoleOutputter
	{
		private static const TEMPLATE_DOWNLOAD_URL:String = "https://moonshine-ide.com/downloads/Moonshine-Domino-CRUD/dev/template.zip";

		private var archiveDirectory:File;
		private var targetDirectory:File;
		private var model:IDEModel = IDEModel.getInstance();
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var fileDownloader:FileDownloader;

		/**
		 * CONSTRUCTOR
		 */
		public function CRUDJavaAgentsExporter()
		{
			super();

			// temp directory to download zip and uncompress
			archiveDirectory = getDownloadArchivePath();
			// starts downloading zip remotely
			startDownloadArchive();
		}
		
		//--------------------------------------------------------------------------
		//
		//  1. DOWNLOAD AND UNZIP API
		//
		//--------------------------------------------------------------------------

		private function getDownloadArchivePath():File
		{
			var tempDirectory:FileLocation = model.fileCore.resolveTemporaryDirectoryPath("moonshine/onDisk");
			if (!tempDirectory.fileBridge.exists)
			{
				tempDirectory.fileBridge.createDirectory();
			}

			var instanceDirectory:File = tempDirectory.fileBridge.resolvePath(UIDUtil.createUID()).fileBridge.getFile as File;
			instanceDirectory.createDirectory();
			return instanceDirectory;
		}

		private function startDownloadArchive():void
		{
			warning("Downloading Java agent templates");
			fileDownloader = new FileDownloader(TEMPLATE_DOWNLOAD_URL, archiveDirectory.resolvePath("template.zip"));
			configureFileDownloaderListeners(true);
			fileDownloader.load();
		}

		private function configureFileDownloaderListeners(attach:Boolean):void
		{
			if (attach)
			{
				fileDownloader.addEventListener(FileDownloader.EVENT_FILE_DOWNLOADED, onTemplatesZipDownloaded);
				fileDownloader.addEventListener(FileDownloader.EVENT_FILE_DOWNLOAD_FAILED, onTemplatesZipDownloadFailed);
				fileDownloader.addEventListener(FileDownloader.EVENT_FILE_DOWNLOAD_PROGRESS, onTemplatesZipDownloadProgress);
			}
			else
			{
				fileDownloader.removeEventListener(FileDownloader.EVENT_FILE_DOWNLOADED, onTemplatesZipDownloaded);
				fileDownloader.removeEventListener(FileDownloader.EVENT_FILE_DOWNLOAD_FAILED, onTemplatesZipDownloadFailed);
				fileDownloader.removeEventListener(FileDownloader.EVENT_FILE_DOWNLOAD_PROGRESS, onTemplatesZipDownloadProgress);
				fileDownloader = null;
			}
		}

		private function onTemplatesZipDownloaded(event:Event):void
		{
			success("Success: Java agent generation templates downloaded");
			unzipTemplateArchive(fileDownloader.targetLocation);
			configureFileDownloaderListeners(false);
		}

		private function onTemplatesZipDownloadFailed(event:Event):void
		{
			configureFileDownloaderListeners(false);
		}

		private function onTemplatesZipDownloadProgress(event:Event):void
		{
			notice("Files downloaded: "+ fileDownloader.downloadPercent +"%");
		}

		private function unzipTemplateArchive(value:File):void
		{
			var zipFileBytes:ByteArray = new ByteArray();
			var fs:FileStream = new FileStream();
			var fzip:Zip = new Zip();

			fs.open(value, FileMode.READ);
			fs.readBytes(zipFileBytes);
			fs.close();

			configureUnzipListeners(fzip, true);
			fzip.loadBytes(zipFileBytes);
		}

		private function configureUnzipListeners(fzip:Zip, attach:Boolean):void
		{
			if (attach)
			{
				fzip.addEventListener(ZipEvent.FILE_LOADED, onFileLoaded, false, 0, true);
				fzip.addEventListener(Event.COMPLETE, onUnzipCompletes, false, 0, true);
				fzip.addEventListener(ErrorEvent.ERROR, onUnzipError, false, 0, true);
			}
			else
			{
				fzip.removeEventListener(ZipEvent.FILE_LOADED, onFileLoaded);
				fzip.removeEventListener(Event.COMPLETE, onUnzipCompletes);
				fzip.removeEventListener(ErrorEvent.ERROR, onUnzipError);

				fzip.close();
				fzip = null;
			}
		}

		private function onUnzipCompletes(event:Event):void
		{
			configureUnzipListeners(event.target as Zip, false);
			archiveDirectory.resolvePath("template.zip").deleteFile();

			// open file-browser for export location
			browseToExport();
		}

		private function onFileLoaded(event:ZipEvent):void
		{
			try
			{
				var fzf:ZipFile = event.file;
				var file:File = archiveDirectory.resolvePath(fzf.filename)
				var fs:FileStream = new FileStream();

				if (isDirectory(fzf))
				{
					// Is a directory, not a file. Dont try to write anything into it.
					return;
				}

				fs.open(file, FileMode.WRITE);
				fs.writeBytes(fzf.content);
				fs.close();

			}
			catch (e:Error)
			{
				error("Template files failed to unzip: " + e.message);
				configureUnzipListeners(event.target as Zip, false);
			}
		}

		private function onUnzipError(event:ErrorEvent):void
		{
			configureUnzipListeners(event.target as Zip, false);
			error("Template file failed to unzip: " + event.text);
		}

		private function isDirectory(file:ZipFile):Boolean
		{
			if (file.filename.substr(file.filename.length - 1) == "/" ||
					file.filename.substr(file.filename.length - 1) == "\\")
			{
				return true;
			}
			return false;
		}

		//--------------------------------------------------------------------------
		//
		//  2. EXPORT API
		//
		//--------------------------------------------------------------------------

		protected function browseToExport():void
		{
			model.fileCore.browseForDirectory("Select Parent Directory to Export", onDirectorySelected, onDirectorySelectionCancelled);
		}

		protected function onDirectorySelected(path:File):void
		{
			targetDirectory = path.resolvePath(model.activeProject.name + "_JavaAgents");
			if (!targetDirectory.exists) targetDirectory.createDirectory();
			else
			{
				error(model.activeProject.name + "_JavaAgents directory already exists. Terminating process.");
				return;
			}

			createFileSystemBeforeSave();
		}

		protected function onDirectorySelectionCancelled():void
		{

		}

		protected function createFileSystemBeforeSave():void
		{
			// project folder copy
			var th:TemplatingHelper = new TemplatingHelper();
			th.templatingData["%project%"] = targetDirectory.name;
			th.templatingData["%NotesExecutablePath%"] = ConstantsCoreVO.IS_MACOS ? model.notesPath +"/Contents/MacOS/" : model.notesPath;

			var excludes:Array = ["%eachform%Agents"];

			th.projectTemplate(
					new FileLocation(archiveDirectory.resolvePath("project").nativePath),
					new FileLocation(targetDirectory.nativePath),
					excludes
			);

			// modules folder copy
			generateModules();
		}

		private function generateModules():void
		{
			new CRUDJavaAgentsModuleExporter(
					archiveDirectory,
					targetDirectory,
					model.activeProject,
					onModulesExported
			);
		}

		private function onModulesExported():void
		{
			// success message
			notice("Project saved at: "+ targetDirectory.nativePath);
			notice("Opening project in Moonshine..");

			// open project in Moonshine
			openProjectInMoonshine();
		}
		
		private function openProjectInMoonshine():void
		{
			var refVO:ProjectReferenceVO = new ProjectReferenceVO();
			refVO.path = targetDirectory.nativePath;
			refVO.name = targetDirectory.name;
			dispatcher.dispatchEvent(new MenuEvent("eventOpenRecentProject", false, false, refVO));
		}
	}
}