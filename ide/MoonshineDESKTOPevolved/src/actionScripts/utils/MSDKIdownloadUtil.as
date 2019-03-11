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
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import actionScripts.events.GeneralEvent;
	import actionScripts.extResources.riaspace.nativeApplicationUpdater.UpdaterErrorCodes;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.HelperConstants;
	
	import air.update.events.DownloadErrorEvent;
	import air.update.events.UpdateEvent;

	public class MSDKIdownloadUtil extends EventDispatcher
	{
		private var downloadingFile:File;
		private var fileStream:FileStream;
		private var urlStream:URLStream;
		private var isDownloading:Boolean;

		private var _executableFile:File;
		private function get executableFile():File
		{
			if (!_executableFile) _executableFile = (new File(HelperConstants.WINDOWS_64BIT_DOWNLOAD_DIRECTORY)).resolvePath("Moonshine SDK Installer.exe");
			return _executableFile;
		}
		
		private static var instance:MSDKIdownloadUtil;
		
		public static function getInstance():MSDKIdownloadUtil 
		{	
			if (!instance) instance = new MSDKIdownloadUtil();
			return instance;
		}
		
		public function is64BitSDKInstallerExists():Boolean
		{
			return executableFile.exists;
		}
		
		public function runOrDownloadSDKInstaller():void
		{
			if (ConstantsCoreVO.IS_MACOS) runAppStoreHelperOSX();
			else
			{
				if (!executableFile.exists) 
				{
					// prevent multi-execution
					if (isDownloading) return;
					initiate64BitDownloadProcess();
				}
				else runAppStoreHelperWindows();
			}
		}
		
		private function runAppStoreHelperOSX():void
		{
			var arg:Vector.<String> = new Vector.<String>();
			var npInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			npInfo.executable = File.documentsDirectory.resolvePath("/bin/bash");
			
			if (HelperConstants.IS_MACOS)
			{
				var scriptFile:File = File.applicationDirectory.resolvePath("macOScripts/SendToASH.sh");
				var pattern:RegExp = new RegExp( /( )/g );
				var shPath:String = scriptFile.nativePath.replace(pattern, "\\ ");
				
				arg.push("-c");
				arg.push(shPath);
			}
			
			npInfo.arguments = arg;
			var process:NativeProcess = new NativeProcess();
			process.start(npInfo);
		}
		
		private function runAppStoreHelperWindows():void
		{
			var npInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			npInfo.executable = executableFile;
			npInfo.arguments = new Vector.<String>();
			var process:NativeProcess = new NativeProcess();
			process.start(npInfo);
		}
		
		private function initiate64BitDownloadProcess():void
		{
			var fileName:String = HelperConstants.WINDOWS_64BIT_DOWNLOAD_URL.substr(HelperConstants.WINDOWS_64BIT_DOWNLOAD_URL.lastIndexOf("/") + 1)
			downloadingFile = new File(HelperConstants.WINDOWS_64BIT_DOWNLOAD_DIRECTORY);
			if (!downloadingFile.exists) downloadingFile.createDirectory();
			downloadingFile = downloadingFile.resolvePath(fileName);
			
			fileStream = new FileStream();
			fileStream.addEventListener(IOErrorEvent.IO_ERROR, urlStream_ioErrorHandler);
			fileStream.addEventListener(Event.CLOSE, fileStream_closeHandler);
			fileStream.openAsync(downloadingFile, FileMode.WRITE);
			
			urlStream = new URLStream();
			urlStream.addEventListener(Event.OPEN, urlStream_openHandler);
			urlStream.addEventListener(ProgressEvent.PROGRESS, urlStream_progressHandler);
			urlStream.addEventListener(Event.COMPLETE, urlStream_completeHandler);
			urlStream.addEventListener(IOErrorEvent.IO_ERROR, urlStream_ioErrorHandler);
			
			try
			{
				urlStream.load(new URLRequest(HelperConstants.WINDOWS_64BIT_DOWNLOAD_URL));
				isDownloading = true;
			}
			catch(error:Error)
			{
				dispatchEvent(new DownloadErrorEvent(DownloadErrorEvent.DOWNLOAD_ERROR, false, false, 
					"Error downloading update file: " + error.message, UpdaterErrorCodes.ERROR_9004, error.message));
			}
		}
		
		protected function urlStream_ioErrorHandler(event:IOErrorEvent):void
		{
			fileStream.removeEventListener(Event.CLOSE, fileStream_closeHandler);
			fileStream.removeEventListener(IOErrorEvent.IO_ERROR, urlStream_ioErrorHandler);
			fileStream.close();
			
			urlStream.removeEventListener(Event.OPEN, urlStream_openHandler);
			urlStream.removeEventListener(ProgressEvent.PROGRESS, urlStream_progressHandler);
			urlStream.removeEventListener(Event.COMPLETE, urlStream_completeHandler);
			urlStream.removeEventListener(IOErrorEvent.IO_ERROR, urlStream_ioErrorHandler);
			urlStream.close();
			
			isDownloading = false;
			dispatchEvent(new DownloadErrorEvent(DownloadErrorEvent.DOWNLOAD_ERROR, false, false, 
				"Error downloading update file: " + event.text, UpdaterErrorCodes.ERROR_9005, event.errorID));
		}
		
		protected function fileStream_closeHandler(event:Event):void
		{
			fileStream.removeEventListener(Event.CLOSE, fileStream_closeHandler);
			fileStream.removeEventListener(IOErrorEvent.IO_ERROR, urlStream_ioErrorHandler);
			
			isDownloading = false;
			unzipDownloadedFile();
		}
		
		protected function urlStream_openHandler(event:Event):void
		{
			dispatchEvent(new UpdateEvent(UpdateEvent.DOWNLOAD_START));
		}
		
		protected function urlStream_progressHandler(event:ProgressEvent):void
		{
			var bytes:ByteArray = new ByteArray();
			urlStream.readBytes(bytes);
			fileStream.writeBytes(bytes);
			dispatchEvent(event);
		}
		
		protected function urlStream_completeHandler(event:Event):void
		{
			urlStream.removeEventListener(Event.OPEN, urlStream_openHandler);
			urlStream.removeEventListener(ProgressEvent.PROGRESS, urlStream_progressHandler);
			urlStream.removeEventListener(Event.COMPLETE, urlStream_completeHandler);
			urlStream.removeEventListener(IOErrorEvent.IO_ERROR, urlStream_ioErrorHandler);
			urlStream.close();
			fileStream.close();
			isDownloading = false;
		}
		
		private function unzipDownloadedFile():void
		{
			var unZip:Unzip = new Unzip(downloadingFile);
			unZip.addEventListener(Unzip.FILE_LOAD_SUCCESS, onFileLoadedInMemory);
			
			/*
			 * @local
			 */
			function onFileLoadedInMemory(event:Event):void
			{
				event.target.removeEventListener(Unzip.FILE_LOAD_SUCCESS, onFileLoadedInMemory);
				unZip.unzipTo(new File(HelperConstants.WINDOWS_64BIT_DOWNLOAD_DIRECTORY), onUnzipCompleted);
			}
			function onUnzipCompleted(destination:File):void
			{
				dispatchEvent(new GeneralEvent(GeneralEvent.DONE));
				runAppStoreHelperWindows();
				try { downloadingFile.deleteFile(); } catch (e:Error) { downloadingFile.deleteFileAsync(); }
			}
		}
	}
}