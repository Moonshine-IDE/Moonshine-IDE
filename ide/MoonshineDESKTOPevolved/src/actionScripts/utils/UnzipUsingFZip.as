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