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
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeDragManager;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.InvokeEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	
	import actionScripts.events.FileCopyPasteEvent;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.events.TreeMenuItemEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.PluginBase;
	import actionScripts.valueObjects.FileWrapper;

	public class NativeFilesManagerPlugin extends PluginBase
	{
		override public function get name():String			{ return "FileAssociation"; }
		override public function get author():String		{ return "Moonshine Project Team"; }
		override public function get description():String	{ return "File Association Plugin. Esc exits."; }
		
		private var filesToBeCopied:Array;
		
		override public function activate():void
		{
			super.activate();
			
			// open-with listener
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onAppInvokeEvent, false, 0, true);
			
			// drag-drop listeners
			FlexGlobals.topLevelApplication.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, onNativeItemDragEnter, false, 0, true);
			FlexGlobals.topLevelApplication.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, onNativeItemDragDrop, false, 0, true);
			
			// file copy/paste listener
			dispatcher.addEventListener(FileCopyPasteEvent.EVENT_COPY_FILE, onFileCopyRequest, false, 0, true);
			dispatcher.addEventListener(FileCopyPasteEvent.EVENT_PASTE_FILES, onPasteFilesRequest, false, 0, true);
		}
		
		private function onAppInvokeEvent(event:InvokeEvent):void
		{
			if (event.arguments.length)
			{
				openFilesByPath(event.arguments);
			}
		}
		
		private function onNativeItemDragEnter(event:NativeDragEvent):void
		{
			if (!event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)) return;
			
			var files:Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
			for each (var i:File in files)
			{
				if (i.isDirectory) return;
			}
			
			// accept drop
			NativeDragManager.acceptDragDrop(InteractiveObject(event.currentTarget));
		}
		
		private function onNativeItemDragDrop(event:NativeDragEvent):void
		{
			if (!event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)) return;
			
			var files:Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
			files = files.map(function(element:*, index:int, arr:Array):String
			{
				return element.nativePath;
			});
			
			openFilesByPath(files);
		}
		
		private function openFilesByPath(paths:Array):void
		{
			for each (var i:String in paths)
			{
				var tmpOpenEvent:OpenFileEvent = new OpenFileEvent(OpenFileEvent.OPEN_FILE, [new FileLocation(i)]);
				tmpOpenEvent.independentOpenFile = true;
				
				dispatcher.dispatchEvent(tmpOpenEvent);
			}
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
			initiateFileCopyingProcess(event.wrappers[0], event.wrappers[0].file.fileBridge.getFile as File);
		}
		
		private function initiateFileCopyingProcess(destinationWrapper:FileWrapper, destination:File, overwrite:Boolean=false, overwriteAll:Boolean=false, cancel:Boolean=false):void
		{
			if (filesToBeCopied.length > 0)
			{
				if (!overwrite && !overwriteAll && destination.resolvePath(filesToBeCopied[0].name).exists)
				{
					Alert.buttonWidth = 90;
					Alert.yesLabel = "Overwrite All";
					Alert.noLabel = "Skip File";
					Alert.okLabel = "Overwrite";
					Alert.cancelLabel = "Cancel All";
					Alert.show(filesToBeCopied[0].name + " already exists to destination path.", "Confirm!", Alert.YES|Alert.NO|Alert.OK|Alert.CANCEL, null, onFileNotification);
				}
				else
				{
					// copy the file
					(filesToBeCopied[0] as File).addEventListener(Event.COMPLETE, onFileCopyingCompletes);
					(filesToBeCopied[0] as File).addEventListener(IOErrorEvent.IO_ERROR, onFileCopyingError);
					(filesToBeCopied[0] as File).copyToAsync(destination.resolvePath((filesToBeCopied[0] as File).name), true);
				}
			}
			else
			{
				// end of the list
				resetFields();
				// send the completed list of file to
				// treeView to update the tree
				dispatcher.dispatchEvent(new TreeMenuItemEvent(TreeMenuItemEvent.NEW_FILES_FOLDERS_COPIED, null, destinationWrapper));
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
					resetFields();
				}
			}
			
			function onFileCopyingCompletes(ev:Event):void
			{
				releaseListeners(ev.target);
				
				filesToBeCopied.shift();
				initiateFileCopyingProcess(destinationWrapper, destination, false, overwriteAll);
			}
			
			function onFileCopyingError(ev:Event):void
			{
				releaseListeners(ev.target);
			}
			
			function releaseListeners(origin:Object):void
			{
				origin.removeEventListener(Event.COMPLETE, onFileCopyingCompletes);
				origin.removeEventListener(IOErrorEvent.IO_ERROR, onFileCopyingError);
			}
			
			function resetFields():void
			{
				filesToBeCopied = [];
				Alert.buttonWidth = 65;
				Alert.yesLabel = "Yes";
				Alert.noLabel = "No";
				Alert.okLabel = "OK";
				Alert.cancelLabel = "Cancel";
			}
		}
	}
}