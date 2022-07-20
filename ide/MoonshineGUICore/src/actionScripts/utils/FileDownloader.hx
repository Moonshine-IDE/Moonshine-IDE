package actionScripts.utils;

import actionScripts.events.GlobalEventDispatcher;
import actionScripts.plugin.console.ConsoleOutputEvent;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.HTTPStatusEvent;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.events.SecurityErrorEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;

class FileDownloader extends EventDispatcher {
	public static final EVENT_FILE_DOWNLOADED:String = "eventFileDownloaded";
	public static final EVENT_FILE_DOWNLOAD_FAILED:String = "eventFileDownloadFailed";
	public static final EVENT_FILE_DOWNLOAD_PROGRESS:String = "eventFileDownloadingInProgress";

	private var _downloadPercent:Int;
	private var _targetLocation:File;
	private var remoteLocation:String;
	private var urlStream:URLLoader;
	private var waitingForDataToWrite:Bool;

	public var downloadPercent(get, never):Int;
	public var targetLocation(get, never):File;

	private function get_downloadPercent():Int
		return _downloadPercent;

	private function get_targetLocation():File
		return _targetLocation;

	public function new(remoteLocation:String, targetLocation:File) {
		super();

		this.remoteLocation = remoteLocation;
		_targetLocation = targetLocation;
	}

	public function load():Void {
		if (urlStream != null) {
			configureListeners(false);
		}

		urlStream = new URLLoader();
		urlStream.dataFormat = URLLoaderDataFormat.BINARY;
		configureListeners(true);
		urlStream.load(new URLRequest(remoteLocation));
	}

	private function configureListeners(attach:Bool):Void {
		if (attach) {
			urlStream.addEventListener(Event.COMPLETE, completeHandler);
			urlStream.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			urlStream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			urlStream.addEventListener(Event.OPEN, openHandler);
			urlStream.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			urlStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		} else {
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

	private function completeHandler(event:Event):Void {
		var fs:FileStream = new FileStream();
		fs.open(_targetLocation, FileMode.WRITE);
		fs.writeBytes(event.target.data);
		fs.close();

		configureListeners(false);
		GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, "File download completes."));
		dispatchEvent(new Event(EVENT_FILE_DOWNLOADED));
	}

	private function openHandler(event:Event):Void {}

	private function progressHandler(event:ProgressEvent):Void {
		_downloadPercent = Math.round(event.bytesLoaded * 100 / event.bytesTotal);
		dispatchEvent(new Event(EVENT_FILE_DOWNLOAD_PROGRESS));
	}

	private function securityErrorHandler(event:SecurityErrorEvent):Void {
		GlobalEventDispatcher.getInstance()
			.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, event.text, false, false, ConsoleOutputEvent.TYPE_ERROR));
		dispatchEvent(new Event(EVENT_FILE_DOWNLOAD_FAILED));
	}

	private function httpStatusHandler(event:HTTPStatusEvent):Void {
		GlobalEventDispatcher.getInstance()
			.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, event.toString(), false, false, ConsoleOutputEvent.TYPE_ERROR));
		// dispatchEvent(new Event(EVENT_FILE_DOWNLOAD_FAILED));
	}

	private function ioErrorHandler(event:IOErrorEvent):Void {
		GlobalEventDispatcher.getInstance()
			.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, event.text, false, false, ConsoleOutputEvent.TYPE_ERROR));
		dispatchEvent(new Event(EVENT_FILE_DOWNLOAD_FAILED));
	}
}