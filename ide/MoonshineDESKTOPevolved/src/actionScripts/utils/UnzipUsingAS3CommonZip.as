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
		private static var _fileUnzipCompleteFunction:Function;
		private static var _destinationProjectFolder:File;

		private static var _fzip:Zip
		public static function get zip():Zip
		{
			return _fzip;
		}

		public static function unzip(fileToUnzip:File, destinationToUnzip:File, unzipCompleteFunction:Function, unzipErrorFunction:Function = null):void
		{
			var zipFileBytes:ByteArray = new ByteArray();
			var fs:FileStream = new FileStream();
			_fzip = new Zip();

			_destinationProjectFolder = destinationToUnzip;
			_fileUnzipErrorFunction = unzipErrorFunction;
			_fileUnzipCompleteFunction = unzipCompleteFunction;

			fs.open(fileToUnzip, FileMode.READ);
			fs.readBytes(zipFileBytes);
			fs.close();

			configureListeners();

			_fzip.loadBytes(zipFileBytes);
		}

		public static function isDirectory(file:ZipFile):Boolean
		{
			if (file.filename.substr(file.filename.length - 1) == "/" || file.filename.substr(file.filename.length - 1) == "\\")
			{
				return true;
			}
			return false;
		}

		private static function configureListeners():void
		{
			_fzip.addEventListener(ZipEvent.FILE_LOADED, onFileLoaded, false, 0, true);
			_fzip.addEventListener(ErrorEvent.ERROR, onUnzipFailed, false, 0, true);
			_fzip.addEventListener(Event.COMPLETE, onUnzipComplete, false, 0, true);
		}

		private static function removeListeners():void
		{
			_fzip.removeEventListener(ZipEvent.FILE_LOADED, onFileLoaded);
			_fzip.removeEventListener(ErrorEvent.ERROR, onUnzipFailed);
			_fzip.removeEventListener(Event.COMPLETE, onUnzipComplete);
			_fzip = null;
			_fileUnzipErrorFunction = null;
			_fileUnzipCompleteFunction = null;
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
			_fzip.close();
			_fileUnzipCompleteFunction(event);
			removeListeners();
		}

		private static function onUnzipFailed(event:ErrorEvent):void
		{
			if (_fileUnzipErrorFunction != null) _fileUnzipErrorFunction(event);
			removeListeners();
		}
	}
}
