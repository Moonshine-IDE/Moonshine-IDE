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
package actionScripts.utils
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	
	import actionScripts.extResources.deng.fzip.fzip.FZip;
	import actionScripts.extResources.deng.fzip.fzip.FZipErrorEvent;
	import actionScripts.extResources.deng.fzip.fzip.FZipFile;
	
	[Event(name="FILE_LOAD_SUCCESS", type="flash.events.Event")]
	[Event(name="FILE_LOAD_ERROR", type="flash.events.Event")]
	public class UnzipUsingFZip extends EventDispatcher
	{
		public static const FILE_LOAD_SUCCESS:String = "fileLoadSuccess";
		public static const FILE_LOAD_ERROR:String = "fileLoadError";
		
		private var fZip:FZip;
		private var loader:Loader;
		private var filesUnzippedCount:int;
		
		private var _filesCount:int;
		public function get filesCount():int
		{
			return _filesCount;
		}
		
		public function UnzipUsingFZip(zipFile:File)
		{
			// @NOTE
			// Since load method as provided by the FZip
			// fails on macOS for some reason, we need
			// manual handling to loads its bytes data
			FileUtils.readFromFileAsync(zipFile, FileUtils.DATA_FORMAT_BYTEARRAY, onReadCompletes, onReadIOError);
		}
		
		private function onReadCompletes(value:ByteArray):void
		{
			fZip = new FZip();
			fZip.loadBytes(value);
			
			_filesCount = fZip.getFileCount();
			dispatchEvent(new Event(FILE_LOAD_SUCCESS));
		}
		
		private function onReadIOError(value:String):void
		{
			dispatchEvent(new Event(FILE_LOAD_ERROR));
		}
		
		public function getFileAt(index:int):FZipFile
		{
			if (fZip && (index < filesCount)) return fZip.getFileAt(index);
			return null;
		}
		
		public function getFilesList():Array
		{
			if (fZip)
			{
				var filesList:Array = [];
				for (var i:int = 0; i < filesCount; i++)
				{
					filesList.push(fZip.getFileAt(i));
				}
				return filesList;
			}
			
			return null;
		}
		
		public function getFileByName(fileName:String):FZipFile
		{
			if (fZip)
			{
				var fzipFile:FZipFile;
				for (var i:int = 0; i < filesCount; i++)
				{
					fzipFile = (fZip.getFileAt(i) as FZipFile);
					if (fzipFile.filename == fileName) return fzipFile;
				}
			}
			
			return null;
		}
		
		public function getFilesByExtension(extensionName:String):Array
		{
			if (fZip)
			{
				var filesList:Array = [];
				var fzipFile:FZipFile;
				for (var i:int = 0; i < filesCount; i++)
				{
					fzipFile = (fZip.getFileAt(i) as FZipFile);
					if (!fzipFile.isDirectory)
					{
						if (fzipFile.extension == extensionName) filesList.push(fzipFile);
					}
				}
				return filesList;
			}
			
			return null;
		}
		
		public function unzipTo(destination:File, onCompletion:Function=null):void
		{
			if (!fZip || !destination.exists) return;
			
			var fzipFile:FZipFile;
			var bytes:ByteArray;
			var toFile:File;
			var fs:FileStream;
			if (filesUnzippedCount < filesCount)
			{
				fzipFile = (fZip.getFileAt(filesUnzippedCount) as FZipFile);
				toFile = destination.resolvePath(fzipFile.filename);
				if (fzipFile.isDirectory) 
				{
					toFile.createDirectory();
					onSuccessWrite();
				}
				else FileUtils.writeToFileAsync(toFile, fzipFile.content, onSuccessWrite, onErrorWrite);
			}
			else if (onCompletion != null)
			{
				filesUnzippedCount = 0;
				onCompletion(destination);
			}
			
			/*
			 * @local
			 */
			function onSuccessWrite():void
			{
				filesUnzippedCount++;
				unzipTo(destination, onCompletion);
			}
			function onErrorWrite(value:String):void
			{
				filesUnzippedCount = 0;
			}
		}
		
		private function addListeners(isAdd:Boolean):void
		{
			if (isAdd)
			{
				fZip.addEventListener(Event.COMPLETE, onFzipFileLoaded);
				fZip.addEventListener(FZipErrorEvent.PARSE_ERROR, onFzipParserError);
				fZip.addEventListener(IOErrorEvent.IO_ERROR, onFzipIOError);
			}
			else
			{
				fZip.removeEventListener(Event.COMPLETE, onFzipFileLoaded);
				fZip.removeEventListener(FZipErrorEvent.PARSE_ERROR, onFzipParserError);
				fZip.removeEventListener(IOErrorEvent.IO_ERROR, onFzipIOError);
			}
		}
		
		private function onFzipFileLoaded(event:Event):void
		{
			addListeners(false);
			_filesCount = fZip.getFileCount();
			dispatchEvent(new Event(FILE_LOAD_SUCCESS));
		}
		
		private function onFzipParserError(event:FZipErrorEvent):void
		{
			// in zip error cases
			Alert.show("Unable to load zip file:\n"+ event.text, "Error");
			addListeners(false);
			dispatchEvent(new Event(FILE_LOAD_ERROR));
		}
		
		private function onFzipIOError(event:IOErrorEvent):void
		{
			// in file/read error cases
			Alert.show("Unable to load zip file:\n"+ event.text, "Error");
			addListeners(false);
			dispatchEvent(new Event(FILE_LOAD_ERROR));
		}
	}
}