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
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	
	import deng.fzip.FZip;
	import deng.fzip.FZipErrorEvent;
	import deng.fzip.FZipFile;

	public class Unzip
	{
		private var fZip:FZip;
		
		public function Unzip(zipFile:File)
		{
			fZip = new FZip();
			addListeners(true);
			fZip.load(new URLRequest(zipFile.nativePath));
		}
		
		private var _filesCount:int;
		public function get filesCount():int
		{
			return _filesCount;
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
					if (fzipFile.filename.substr(fzipFile.filename.length-3, fzipFile.filename.length) == extensionName) filesList.push(fzipFile);
				}
				return filesList;
			}
			
			return null;
		}
		
		public function unzipTo(destination:File):void
		{
			if (!fZip || !destination.exists) return;
			
			var fzipFile:FZipFile;
			var bytes:ByteArray;
			var toFile:File;
			var fs:FileStream;
			for (var i:int = 0; i < filesCount; i++)
			{
				fzipFile = (fZip.getFileAt(i) as FZipFile);
				toFile = destination.resolvePath(fzipFile.filename);
				fs = new FileStream();
				
				fs.open(toFile, FileMode.WRITE);
				fs.writeBytes(fzipFile.content);
				fs.close();
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
		}
		
		private function onFzipParserError(event:FZipErrorEvent):void
		{
			// in zip error cases
			Alert.show("Unable to load zip file:\n"+ event.text, "Error");
			addListeners(false);
		}
		
		private function onFzipIOError(event:IOErrorEvent):void
		{
			// in file/read error cases
			Alert.show("Unable to load zip file:\n"+ event.text, "Error");
			addListeners(false);
		}
	}
}