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
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	import org.as3commons.zip.Zip;
	import org.as3commons.zip.ZipEvent;
	import org.as3commons.zip.ZipFile;

	public class UnzipUsingAS3CommonZip
	{
		private static var _fileUnzipErrorFunction:Function;
		private static var _destinationProjectFolder:File;

		public static function unzip(fileToUnzip:File, destinationToUnzip:File, unzipCompleteFunction:Function, unzipErrorFunction:Function = null):void
		{
			var zipFileBytes:ByteArray = new ByteArray();
			var fs:FileStream = new FileStream();
			var fzip:Zip = new Zip();

			_destinationProjectFolder = destinationToUnzip;

			fs.open(fileToUnzip, FileMode.READ);
			fs.readBytes(zipFileBytes);
			fs.close();

			fzip.addEventListener(ZipEvent.FILE_LOADED, onFileLoaded, false, 0, true);
			fzip.addEventListener(Event.COMPLETE, unzipCompleteFunction, false, 0, true);
			fzip.addEventListener(Event.COMPLETE, onUnzipComplete, false, 0, true);
			if (unzipErrorFunction != null)
			{
				fzip.addEventListener(ErrorEvent.ERROR, unzipErrorFunction, false, 0, true);
				_fileUnzipErrorFunction = unzipErrorFunction
			}
			fzip.loadBytes(zipFileBytes);
		}

		private static function onFileLoaded(event:ZipEvent):void
		{
			try
			{
				var fzf:ZipFile = event.file;
				var f:File = _destinationProjectFolder.resolvePath(fzf.filename);
				var fs:FileStream = new FileStream();

				if (isDirectory(fzf))
				{
					// Is a directory, not a file. Dont try to write anything into it.
					return;
				}

				fs.open(f, FileMode.WRITE);
				fs.writeBytes(fzf.content);
				fs.close();

			}
			catch (error:Error)
			{
				_fileUnzipErrorFunction.call();
			}
		}

		private static function onUnzipComplete(event:Event):void
		{
			var fzip:Zip = event.target as Zip;
			fzip.close();
			fzip.removeEventListener(ZipEvent.FILE_LOADED, onFileLoaded);
			fzip.removeEventListener(Event.COMPLETE, onUnzipComplete);
		}

		private static function isDirectory(file:ZipFile):Boolean
		{
			if (file.filename.substr(file.filename.length - 1) == "/" || file.filename.substr(file.filename.length - 1) == "\\")
			{
				return true;
			}
			return false;
		}
	}
}
