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
	import flash.events.IOErrorEvent;
	import flash.events.OutputProgressEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	public class FileUtils
	{
		public static const DATA_FORMAT_STRING:String = "dataAsString";
		public static const DATA_FORMAT_BYTEARRAY:String = "dataAsByteArray";
		
		/**
		 * Writes to file with data
		 * @required
		 * destination: File (save-destination)
		 * data: Object (String or ByteArray)
		 * successHandler: Function
		 * errorHandler: Function (attr:- 1. String)
		 */
		public static function writeToFileAsync(destination:File, data:Object, successHandler:Function=null, errorHandler:Function=null):void
		{
			var fs:FileStream = new FileStream();
			manageListeners(fs, true);
			fs.openAsync(destination, FileMode.WRITE);
			if (data is String) fs.writeUTFBytes(data as String);
			else if (data is ByteArray) fs.writeBytes(data as ByteArray);
			else 
			{
				throw Error('Save data is invalid: '+ destination.nativePath);
				return;
			}
			
			/*
			 * @local
			 */
			function onFileWriteProgress(event:OutputProgressEvent):void
			{
				if (event.bytesPending == 0)
				{
					manageListeners(event.target as FileStream, false);
					if (successHandler != null) successHandler();
				}
			}
			function handleFSError(event:IOErrorEvent):void
			{
				manageListeners(event.target as FileStream, false);
				if (errorHandler != null) successHandler(event.text);
			}
			function manageListeners(origin:FileStream, attach:Boolean):void
			{
				if (attach)
				{
					origin.addEventListener(IOErrorEvent.IO_ERROR, handleFSError);
					origin.addEventListener(OutputProgressEvent.OUTPUT_PROGRESS, onFileWriteProgress);
				}
				else
				{
					origin.close();
					origin.removeEventListener(IOErrorEvent.IO_ERROR, handleFSError);
					origin.removeEventListener(OutputProgressEvent.OUTPUT_PROGRESS, onFileWriteProgress);
				}
			}
		}
		
		/**
		 * Reads from file asynchronously
		 * @required
		 * target: File (read-destination)
		 * dataFormat: String (return data type after read)
		 * successHandler: Function (attr:- 1. String or ByteArray)
		 * errorHandler: Function (attr:- 1. String)
		 */
		public static function readFromFileAsync(target:File, dataFormat:String=DATA_FORMAT_STRING, successHandler:Function=null, errorHandler:Function=null):void
		{
			var fs:FileStream = new FileStream();
			manageListeners(fs, true);
			fs.openAsync(target, FileMode.READ);
			
			/*
			 * @local
			 */
			function onOutputProgress(event:ProgressEvent):void
			{
				if (event.bytesTotal == event.bytesLoaded)
				{
					var loadedBytes:ByteArray;
					var loadedString:String;
					if (dataFormat == DATA_FORMAT_STRING) loadedString = event.target.readUTFBytes(event.target.bytesAvailable);
					else 
					{
						loadedBytes = new ByteArray();
						event.target.readBytes(loadedBytes);
					}
					
					manageListeners(event.target as FileStream, false);
					if (successHandler != null) successHandler(loadedBytes || loadedString);
				}
			}
			function onIOErrorReadChannel(event:IOErrorEvent):void
			{
				manageListeners(event.target as FileStream, false);
				if (errorHandler != null) successHandler(event.text);
			}
			function manageListeners(origin:FileStream, attach:Boolean):void
			{
				if (attach)
				{
					origin.addEventListener(ProgressEvent.PROGRESS, onOutputProgress);
					origin.addEventListener(IOErrorEvent.IO_ERROR, onIOErrorReadChannel);
				}
				else
				{
					origin.close();
					origin.removeEventListener(ProgressEvent.PROGRESS, onOutputProgress);
					origin.removeEventListener(IOErrorEvent.IO_ERROR, onIOErrorReadChannel);
				}
			}
		}
	}
}