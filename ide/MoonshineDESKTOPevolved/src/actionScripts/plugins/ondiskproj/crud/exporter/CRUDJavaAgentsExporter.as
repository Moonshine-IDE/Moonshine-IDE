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
package actionScripts.plugins.ondiskproj.crud.exporter
{
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.MenuEvent;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.factory.FileLocation;
	import actionScripts.interfaces.IDeployDominoDatabaseProject;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.plugin.ondiskproj.vo.OnDiskProjectVO;
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
		private static const TEMPLATE_DOWNLOAD_URL:String = "https://moonshine-ide.com/downloads/Moonshine-Domino-CRUD/prod/template.zip";

		protected var archiveDirectory:File;
		protected var targetDirectory:File;
		protected var model:IDEModel = IDEModel.getInstance();
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
			addFileDownloaderListeners();
			fileDownloader.load();
		}

		private function onTemplatesZipDownloaded(event:Event):void
		{
			success("Success: Java agent generation templates downloaded");
			unzipTemplateArchive(fileDownloader.targetLocation);
			removeAndCleanFileDownloaderListeners();
		}

		private function onTemplatesZipDownloadFailed(event:Event):void
		{
			removeAndCleanFileDownloaderListeners();
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

			addUnzipListeners(fzip);
			fzip.loadBytes(zipFileBytes);
		}

		private function onUnzipCompletes(event:Event):void
		{
			removeAndCloseUnzipListeners(event.target as Zip);
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
				removeAndCloseUnzipListeners(event.target as Zip);
			}
		}

		private function onUnzipError(event:ErrorEvent):void
		{
			removeAndCloseUnzipListeners(event.target as Zip);
			error("Template file failed to unzip: " + event.text);
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

		private function addUnzipListeners(fzip:Zip):void
		{
			fzip.addEventListener(ZipEvent.FILE_LOADED, onFileLoaded, false, 0, true);
			fzip.addEventListener(Event.COMPLETE, onUnzipCompletes, false, 0, true);
			fzip.addEventListener(ErrorEvent.ERROR, onUnzipError, false, 0, true);
		}

		private function removeAndCloseUnzipListeners(fzip:Zip):void
		{
			fzip.removeEventListener(ZipEvent.FILE_LOADED, onFileLoaded);
			fzip.removeEventListener(Event.COMPLETE, onUnzipCompletes);
			fzip.removeEventListener(ErrorEvent.ERROR, onUnzipError);

			fzip.close();
			fzip = null;
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
			th.templatingData["%server%"] = (model.activeProject as IDeployDominoDatabaseProject).targetServer;
			th.templatingData["%databaseName%"] = (model.activeProject as IDeployDominoDatabaseProject).targetDatabase;

			var excludes:Array = ["%eachform%Agents", "%eachform%Docs", "%eachform%Scripts"];

			th.projectTemplate(
					new FileLocation(archiveDirectory.resolvePath("project").nativePath),
					new FileLocation(targetDirectory.nativePath),
					excludes
			);

			// modules folder copy
			generateModules();
		}

		protected function generateModules():void
		{
			new CRUDJavaAgentsModuleExporter(
					archiveDirectory,
					targetDirectory,
					model.activeProject,
					onModulesExported
			);
		}

		protected function onModulesExported():void
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
			//refVO.name = targetDirectory.name;
			dispatcher.dispatchEvent(new MenuEvent("eventOpenRecentProject", false, false, refVO));
		}
	}
}