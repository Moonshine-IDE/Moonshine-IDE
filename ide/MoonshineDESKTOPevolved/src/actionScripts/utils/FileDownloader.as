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
					new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, "Success: Java agent generation templates downloaded", false, false, ConsoleOutputEvent.TYPE_SUCCESS));
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
			trace("httpStatusHandler: " + event);
		}

		private function ioErrorHandler(event:IOErrorEvent):void
		{
			GlobalEventDispatcher.getInstance().dispatchEvent(
					new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, event.text, false, false, ConsoleOutputEvent.TYPE_ERROR));
			dispatchEvent(new Event(EVENT_FILE_DOWNLOAD_FAILED));
		}
	}
}
