////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
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
	import actionScripts.valueObjects.FileWrapper;

	public class FilesCopyPlugin extends PluginBase
	{
		override public function get name():String			{ return "FilesCopyPlugin"; }
		override public function get author():String		{ return "Moonshine Project Team"; }
		override public function get description():String	{ return "Files Copy/Paste Plugin. Esc exits."; }
		
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
			Clipboard.generalClipboard.setData(ClipboardFormats.FILE_LIST_FORMAT, [event.wrapper.file.fileBridge.getFile]);
		}
		
		private function onPasteFilesRequest(event:FileCopyPasteEvent):void
		{
			filesToBeCopied = Clipboard.generalClipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
			extractFoldersOnly(filesToBeCopied);
			
			initiateFileCopyingProcess(event.wrapper, event.wrapper.file.fileBridge.getFile as File);
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
			if (filesToBeCopied.length > 0)
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
			}
			else
			{
				// go for folder copying
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