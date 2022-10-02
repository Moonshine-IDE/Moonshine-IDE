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
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.plugin.console.ConsoleOutputEvent;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;

	public class FileDownloader extends EventDispatcher
	{
		public static const EVENT_FILE_DOWNLOADED:String = "eventFileDownloaded";
		public static const EVENT_FILE_DOWNLOAD_PROGRESS:String = "eventFileDownloadingInProgress";
		public static const EVENT_FILE_DOWNLOAD_FAILED:String = "eventFileDownloadFailed";

		private var urlStream:URLLoader;
		private var remoteLocation:String;
		private var waitingForDataToWrite:Boolean;

		private var _downloadPercent:int;
		public function get downloadPercent():int
		{
			return _downloadPercent;
		}

		private var _targetLocation:File;
		public function get targetLocation():File
		{
			return _targetLocation;
		}

		public function FileDownloader(remoteLocation:String, targetLocation:File)
		{
			super();

			this.remoteLocation = remoteLocation;
			this._targetLocation = targetLocation;
		}

		public function load():void
		{
			if (urlStream)
			{
				configureListeners(false);
			}

			urlStream = new URLLoader();
			urlStream.dataFormat = URLLoaderDataFormat.BINARY;
			configureListeners(true);
			urlStream.load(new URLRequest(remoteLocation));
		}

		private function configureListeners(attach:Boolean):void
		{
			if (attach)
			{
				urlStream.addEventListener(Event.COMPLETE, completeHandler);
				urlStream.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
				urlStream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				urlStream.addEventListener(Event.OPEN, openHandler);
				urlStream.addEventListener(ProgressEvent.PROGRESS, progressHandler);
				urlStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			}
			else
			{
				urlStream.removeEventListener(Event.COMPLETE, completeHandler);
				urlStream.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
				urlStream.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				urlStream.removeEventListener(Event.OPEN, openHandler);
				urlStream.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
				urlStream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);

				urlStream.close();
				urlStream = null;
			}
		}

		private function completeHandler(event:Event):void
		{
			var fs:FileStream = new FileStream();
			fs.open(_targetLocation, FileMode.WRITE);
			fs.writeBytes(event.target.data);
			fs.close();

			configureListeners(false);
			GlobalEventDispatcher.getInstance().dispatchEvent(
					new ConsoleOutputEvent(
							ConsoleOutputEvent.CONSOLE_PRINT,
							"File download completes.",
							false, false,
							ConsoleOutputEvent.TYPE_SUCCESS
					));
			dispatchEvent(new Event(EVENT_FILE_DOWNLOADED));
		}

		private function openHandler(event:Event):void
		{

		}

		private function progressHandler(event:ProgressEvent):void
		{
			_downloadPercent = Math.round(event.bytesLoaded * 100 / event.bytesTotal);
			dispatchEvent(new Event(EVENT_FILE_DOWNLOAD_PROGRESS));
		}

		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
			GlobalEventDispatcher.getInstance().dispatchEvent(
					new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, event.text, false, false, ConsoleOutputEvent.TYPE_ERROR));
			dispatchEvent(new Event(EVENT_FILE_DOWNLOAD_FAILED));
		}

		private function httpStatusHandler(event:HTTPStatusEvent):void
		{
			GlobalEventDispatcher.getInstance().dispatchEvent(
					new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, event.toString(), false, false, ConsoleOutputEvent.TYPE_ERROR));
			//dispatchEvent(new Event(EVENT_FILE_DOWNLOAD_FAILED));
		}

		private function ioErrorHandler(event:IOErrorEvent):void
		{
			GlobalEventDispatcher.getInstance().dispatchEvent(
					new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, event.text, false, false, ConsoleOutputEvent.TYPE_ERROR));
			dispatchEvent(new Event(EVENT_FILE_DOWNLOAD_FAILED));
		}
	}
}
