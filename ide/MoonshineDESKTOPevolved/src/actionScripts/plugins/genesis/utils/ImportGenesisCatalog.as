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
package actionScripts.plugins.genesis.utils
{
import actionScripts.events.GeneralEvent;
import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.console.ConsoleOutputter;
import actionScripts.plugin.workspace.interfaces.IWorkspaceNameReceiver;
import actionScripts.utils.FileDownloader;
	import actionScripts.utils.FileUtils;
	import actionScripts.utils.UnzipUsingAS3CommonZip;

	import flash.events.ErrorEvent;

	import flash.events.Event;

	import flash.filesystem.File;

import moonshine.plugin.workspace.events.WorkspaceEvent;

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
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();

		public function ImportGenesisCatalog(fromURL:String, destinationFolder:File)
		{
			super();

			downloadURL = fromURL;
			targetDownloadDirectory = destinationFolder;
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

			unzipToTempDirectory();
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
			unzipToTempDirectory();
		}

		private function unzipToTempDirectory():void
		{
			// stars unzipping to temporary folder
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
			// check if a config file supplied
			if (targetDownloadDirectory.resolvePath("config.xml").exists)
			{
				readGenesisCatalogConfiguration(targetDownloadDirectory.resolvePath("config.xml"));
			}
			else
			{
				openProjectsSelectionDialog();
			}
		}

		private function readGenesisCatalogConfiguration(configFile:File):void
		{
			var configXML:XML = null;
			var targetWorkspace:String;
			try
			{
				configXML = new XML(FileUtils.readFromFile(configFile) as String);
			}
			catch (e:Error) {}
			if (configXML)
			{
				if (configXML.hasOwnProperty("SuggestedWorkspace"))
				{
					targetWorkspace = String(configXML.SuggestedWorkspace);
				}
				else
				{
					warning("Catalog define no workspace: opening to default workspace.");
				}
			}
			else
			{
				error("Catalog configuration file contains unexpected element.");
			}

			// finally
			openProjectsSelectionDialog(targetWorkspace);
		}

		protected function openProjectsSelectionDialog(targetWorkspace:String=null):void
		{
			dispatcher.addEventListener(WorkspaceEvent.GET_TARGET_WORKSPACE, onSettingTargetWorkspaceInProjectSelectionPopup, false, 0, true);
			dispatcher.dispatchEvent(
					new ProjectEvent(ProjectEvent.EVENT_IMPORT_PROJECT_NO_BROWSE_DIALOG, targetDownloadDirectory)
			);
			success("Project downloaded at: "+ targetDownloadDirectory.nativePath);

			/*
			 * @local
			 */
			function onSettingTargetWorkspaceInProjectSelectionPopup(event:GeneralEvent):void
			{
				dispatcher.removeEventListener(WorkspaceEvent.GET_TARGET_WORKSPACE, onSettingTargetWorkspaceInProjectSelectionPopup);
				if (event.value is IWorkspaceNameReceiver)
				{
					(event.value as IWorkspaceNameReceiver).targetWorkspace = targetWorkspace;
				}
			}
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
