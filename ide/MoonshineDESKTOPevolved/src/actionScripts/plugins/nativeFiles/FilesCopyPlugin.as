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
package actionScripts.plugins.nativeFiles
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.events.Event;
	import flash.events.FileListEvent;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	import actionScripts.events.FileCopyPasteEvent;
	import actionScripts.events.TreeMenuItemEvent;
	import actionScripts.plugin.PluginBase;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.FileWrapper;
	
	public class FilesCopyPlugin extends PluginBase
	{
		override public function get name():String			{ return "FilesCopyPlugin"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String	{ return "Files Copy/Paste Plugin."; }
		
		private var filesToBeCopied:Array;
		private var foldersOnlyToBeCopied:Array = [];
		private var manchurian:String;
		
		override public function activate():void
		{
			super.activate();
			
			// file copy/paste listener
			dispatcher.addEventListener(FileCopyPasteEvent.EVENT_COPY_FILE, onFileCopyRequest, false, 0, true);
			dispatcher.addEventListener(FileCopyPasteEvent.EVENT_PASTE_FILES, onPasteFilesRequest, false, 0, true);
		}
		
		private function onFileCopyRequest(event:FileCopyPasteEvent):void
		{
			var files:Array = [];
			for each (var fw:FileWrapper in event.wrappers)
			{
				files.push(fw.file.fileBridge.getFile);
			}
			
			Clipboard.generalClipboard.setData(ClipboardFormats.FILE_LIST_FORMAT, files);
		}
		
		private function onPasteFilesRequest(event:FileCopyPasteEvent):void
		{
			filesToBeCopied = Clipboard.generalClipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
			extractFoldersOnly(filesToBeCopied);
			
			initiateFileCopyingProcess(event.wrappers[0], event.wrappers[0].file.fileBridge.getFile as File);
		}
		
		private function extractFoldersOnly(files:Array):void
		{
			for (var i:int; i < files.length; i++)
			{
				if (files[i].isDirectory) 
				{
					if (!manchurian)
					{
						generatePathPrefix(files[i]);
					}
					
					foldersOnlyToBeCopied.push(files.splice(i, 1)[0]);
					i--;
				}
			}
			
			if (!manchurian) generatePathPrefix(files[0]);
			
			/*
			* @local
			*/
			function generatePathPrefix(file:File):void
			{
				var folderName:String = file.name;
				manchurian = file.nativePath.substring(0, file.nativePath.indexOf(File.separator + folderName));
			}
		}
		
		private function initiateFileCopyingProcess(destinationWrapper:FileWrapper, destination:File, overwrite:Boolean=false, overwriteAll:Boolean=false, cancel:Boolean=false):void
		{
			var copiedFileDestination:File;
			var relativePathToCopiedFileDestination:String;
			if (foldersOnlyToBeCopied.length != 0)
			{
				adjustDestinationFilePath(foldersOnlyToBeCopied[0]);
				if (copiedFileDestination.nativePath.indexOf(foldersOnlyToBeCopied[0].nativePath + File.separator) != -1)
				{
					// parent not permitted to copied as children
					Alert.show("Parent is not permitted to copy as children:\n"+ destination.name + File.separator + relativePathToCopiedFileDestination +"\nCopy terminates.", "Error!");
					resetAndNotifyCaller();
					return;
				}
				else if (!overwrite && !overwriteAll && copiedFileDestination.exists)
				{
					setAlerts(true);
					Alert.show("Directory already exists to destination path:\n"+ destination.name + File.separator + relativePathToCopiedFileDestination, "Confirm!", Alert.YES|Alert.NO|Alert.OK|Alert.CANCEL, null, onFolderOnlyNotification);
				}
				else
				{
					// copy folder and all its contents
					(foldersOnlyToBeCopied[0] as File).addEventListener(Event.COMPLETE, onFileCopyingCompletes);
					(foldersOnlyToBeCopied[0] as File).addEventListener(IOErrorEvent.IO_ERROR, onFileCopyingError);
					(foldersOnlyToBeCopied[0] as File).copyToAsync(copiedFileDestination, true);
				}
			}
			else
			{
				// go for folder copying
				if (filesToBeCopied.length != 0)
				{
					adjustDestinationFilePath(filesToBeCopied[0]);
					if (!overwrite && !overwriteAll && copiedFileDestination.exists)
					{
						setAlerts(false);
						Alert.show("File already exists to destination path:\n"+ destination.name + File.separator + relativePathToCopiedFileDestination, "Confirm!", Alert.YES|Alert.NO|Alert.OK|Alert.CANCEL, null, onFileNotification);
					}
					else
					{
						// copy the file
						(filesToBeCopied[0] as File).addEventListener(Event.COMPLETE, onFileCopyingCompletes);
						(filesToBeCopied[0] as File).addEventListener(IOErrorEvent.IO_ERROR, onFileCopyingError);
						(filesToBeCopied[0] as File).copyToAsync(copiedFileDestination, true);
					}
					
					return;
				}
				
				// end of the list
				resetAndNotifyCaller();
			}
			
			/*
			* @local
			*/
			function onFileNotification(ev:CloseEvent):void
			{
				if (ev.detail == Alert.YES)
				{
					initiateFileCopyingProcess(destinationWrapper, destination, false, true);
				} 
				else if (ev.detail == Alert.NO)
				{
					filesToBeCopied.shift();
					initiateFileCopyingProcess(destinationWrapper, destination);
				}
				else if (ev.detail == Alert.OK)
				{
					initiateFileCopyingProcess(destinationWrapper, destination, true);
				}
				else if (ev.detail == Alert.CANCEL)
				{
					resetAndNotifyCaller();
				}
			}
			
			function onFolderOnlyNotification(ev:CloseEvent):void
			{
				if (ev.detail == Alert.YES)
				{
					initiateFileCopyingProcess(destinationWrapper, destination, true);
				} 
				else if (ev.detail == Alert.NO)
				{
					foldersOnlyToBeCopied.shift();
					initiateFileCopyingProcess(destinationWrapper, destination);
				}
				else if (ev.detail == Alert.OK)
				{
					(foldersOnlyToBeCopied[0] as File).addEventListener(FileListEvent.DIRECTORY_LISTING, onDirectoryListingCompleted);
					(foldersOnlyToBeCopied[0] as File).getDirectoryListingAsync();
				}
				else if (ev.detail == Alert.CANCEL)
				{
					resetAndNotifyCaller();
				}
			}
			
			function setAlerts(forDirectory:Boolean):void
			{
				Alert.buttonWidth = 90;
				Alert.noLabel = "Skip File";
				Alert.cancelLabel = "Cancel All";
				if (!forDirectory)
				{
					Alert.okLabel = "Overwrite";
					Alert.yesLabel = "Overwrite All";
				}
				else
				{
					Alert.okLabel = "Check Files";
					Alert.yesLabel = "Overwrite";
				}
			}
			
			function resetAndNotifyCaller():void
			{
				resetFields();
				// send the completed list of file to
				// treeView to update the tree
				dispatcher.dispatchEvent(new TreeMenuItemEvent(TreeMenuItemEvent.NEW_FILES_FOLDERS_COPIED, null, destinationWrapper));
			}
			
			function adjustDestinationFilePath(file:File):void
			{
				relativePathToCopiedFileDestination = file.nativePath.substring(manchurian.length+1, file.nativePath.length);
				copiedFileDestination = destination.resolvePath(relativePathToCopiedFileDestination);
			}
			
			function onFileCopyingCompletes(ev:Event):void
			{
				releaseListeners(ev.target);
				
				if (ev.target.isDirectory) foldersOnlyToBeCopied.shift();
				else filesToBeCopied.shift();
				initiateFileCopyingProcess(destinationWrapper, destination, false, overwriteAll);
			}
			
			function onFileCopyingError(ev:Event):void
			{
				releaseListeners(ev.target);
				resetFields();
			}
			
			function onDirectoryListingCompleted(ev:FileListEvent):void
			{
				ev.target.removeEventListener(FileListEvent.DIRECTORY_LISTING, onDirectoryListingCompleted);
				
				filesToBeCopied = ev.files;
				if (filesToBeCopied.length == 0)
				{
					// in case there is no files in the targeted folder
					resetFields();
					Alert.show("The folder contains no file or folder.\nProcess terminates.", "Note!");
					return;
				}
				
				foldersOnlyToBeCopied.splice(0, 1);
				extractFoldersOnly(filesToBeCopied);
				initiateFileCopyingProcess(destinationWrapper, destination, false, overwriteAll);
			}
			
			function releaseListeners(origin:Object):void
			{
				origin.removeEventListener(Event.COMPLETE, onFileCopyingCompletes);
				origin.removeEventListener(IOErrorEvent.IO_ERROR, onFileCopyingError);
			}
			
			function resetFields():void
			{
				manchurian = null;
				filesToBeCopied = [];
				foldersOnlyToBeCopied = [];
				
				Alert.buttonWidth = 65;
				Alert.yesLabel = "Yes";
				Alert.noLabel = "No";
				Alert.okLabel = "OK";
				Alert.cancelLabel = "Cancel";
			}
		}
	}
}