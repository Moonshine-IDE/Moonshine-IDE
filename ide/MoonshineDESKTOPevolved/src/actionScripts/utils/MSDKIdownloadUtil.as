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
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	
	import actionScripts.events.GeneralEvent;
	import actionScripts.extResources.riaspace.nativeApplicationUpdater.UpdaterErrorCodes;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.HelperConstants;
	
	import air.update.events.DownloadErrorEvent;
	import air.update.events.UpdateEvent;

	public class MSDKIdownloadUtil extends EventDispatcher
	{
		public static const EVENT_NEW_VERSION_DETECTED:String = "eventNewVersionDetected";
		
		private var downloadingFile:File;
		private var fileStream:FileStream;
		private var urlStream:URLStream;
		private var isDownloading:Boolean;
		private var isUpdateChecking:Boolean;
		private var isUpdateChecked:Boolean;
		private var updateDescriptorLoader:URLLoader;

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
				else if (!isUpdateChecking && !isDownloading) 
				{
					// make sure we does this check once
					// in an application lifecycle
					if (!isUpdateChecked)
					{
						isUpdateChecking = true;
						checkForUpdates();
					}
					else runAppStoreHelperWindows();
				}
			}
		}
		
		private function checkForUpdates():void
		{
			if (updateDescriptorLoader) return;
			
			updateDescriptorLoader = new URLLoader();
			updateDescriptorLoader.addEventListener(Event.COMPLETE, updateDescriptorLoader_completeHandler);
			updateDescriptorLoader.addEventListener(IOErrorEvent.IO_ERROR, updateDescriptorLoader_ioErrorHandler);
			try
			{
				updateDescriptorLoader.load(new URLRequest(HelperConstants.INSTALLER_UPDATE_CHECK_URL));
			}
			catch(error:Error)
			{
				runAppStoreHelperWindows();
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
		
		private function initiate64BitDownloadProcess(downloadUrl:String=null):void
		{
			downloadUrl = downloadUrl || HelperConstants.WINDOWS_64BIT_DOWNLOAD_URL;
			
			var fileName:String = downloadUrl.substr(downloadUrl.lastIndexOf("/") + 1)
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
				urlStream.load(new URLRequest(downloadUrl));
				isDownloading = true;
			}
			catch(error:Error)
			{
				dispatchEvent(new DownloadErrorEvent(DownloadErrorEvent.DOWNLOAD_ERROR, false, false, 
					"Error downloading update file: " + error.message, UpdaterErrorCodes.ERROR_9004, error.message));
			}
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
		
		private function isNewerVersionFunction(updateVersion:String, currentVersion:String):Boolean
		{
			var tmpSplit:Array = updateVersion.split(".");
			var uv1:Number = Number(tmpSplit[0]);
			var uv2:Number = Number(tmpSplit[1]);
			var uv3:Number = Number(tmpSplit[2]);
			
			var tmpSplit2:Array = currentVersion.split(".");
			var cv1:Number = Number(tmpSplit2[0]);
			var cv2:Number = Number(tmpSplit2[1]);
			var cv3:Number = Number(tmpSplit2[2]);
			
			if (uv1 > cv1) return true;
			else if (uv1 >= cv1 && uv2 > cv2) return true;
			else if (uv1 >= cv1 && uv2 >= cv2 && uv3 > cv3) return true;
			
			return false;
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
		
		protected function updateDescriptorLoader_completeHandler(event:Event):void
		{
			isUpdateChecked = true;
			isUpdateChecking = false;
			updateDescriptorLoader.removeEventListener(Event.COMPLETE, updateDescriptorLoader_completeHandler);
			updateDescriptorLoader.removeEventListener(IOErrorEvent.IO_ERROR, updateDescriptorLoader_ioErrorHandler);
			updateDescriptorLoader.close();
			
			// store remote information
			var updateDescriptor:XML = new XML(updateDescriptorLoader.data);
			var updateVersion:String = String(updateDescriptor.exe.version);
			var updateVersionUrl:String = String(updateDescriptor.exe.url);
			
			updateDescriptorLoader = null;
			
			// load local information
			var localDescriptor:File = new File(HelperConstants.WINDOWS_64BIT_DOWNLOAD_DIRECTORY).resolvePath("META-INF/AIR/application.xml");
			if (!localDescriptor.exists) return;
			var currentVersion:String;
			var applicationDescriptor:XML = new XML(FileUtils.readFromFile(localDescriptor));
			var xmlns:Namespace = new Namespace(applicationDescriptor.namespace());
			
			if (xmlns.uri == "http://ns.adobe.com/air/application/2.1")
				currentVersion = applicationDescriptor.xmlns::version;
			else
				currentVersion = applicationDescriptor.xmlns::versionNumber;
			
			if (isNewerVersionFunction(updateVersion, currentVersion))
			{
				dispatchEvent(new Event(EVENT_NEW_VERSION_DETECTED));
				// initiate new download
				initiate64BitDownloadProcess(updateVersionUrl);
			}
			else
			{
				// continue running existing download
				runAppStoreHelperWindows();
			}
		}
		
		protected function updateDescriptorLoader_ioErrorHandler(event:IOErrorEvent):void
		{
			updateDescriptorLoader.removeEventListener(Event.COMPLETE, updateDescriptorLoader_completeHandler);
			updateDescriptorLoader.removeEventListener(IOErrorEvent.IO_ERROR, updateDescriptorLoader_ioErrorHandler);
			updateDescriptorLoader.close();
			updateDescriptorLoader = null;
			
			isUpdateChecked = true;
			isUpdateChecking = false;
			Alert.show("Error downloading Installer updater file, try again later.\n"+ event.text, "Error!");
		}
	}
}