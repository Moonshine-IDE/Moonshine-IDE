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
	import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLStream;
	
	import actionScripts.events.GeneralEvent;
	import actionScripts.extResources.riaspace.nativeApplicationUpdater.AutoUpdaterHelper;
	import actionScripts.extResources.riaspace.nativeApplicationUpdater.NativeApplicationUpdater;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.HelperConstants;
	
	import air.update.events.DownloadErrorEvent;
	import air.update.events.StatusUpdateErrorEvent;
	import air.update.events.StatusUpdateEvent;
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
		private var nativeApplicationUpdater:NativeApplicationUpdater;
		private var updaterHelper:AutoUpdaterHelper;

		private var _executableFile:File;
		private function get executableFile():File
		{
			if (!_executableFile) _executableFile = (new File(HelperConstants.WINDOWS_64BIT_DOWNLOAD_DIRECTORY)).resolvePath("MoonshineSDKInstaller.exe");
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
				if ((!executableFile.exists && !isUpdateChecking && !isDownloading) || 
					(!isUpdateChecking && !isDownloading)) 
				{
					// make sure we does this check once
					// in an application lifecycle
					if (!isUpdateChecked)
					{
						initializeApplicationUpdater();
					}
					else if (executableFile.exists)
					{
						runAppStoreHelperWindows();
					}
				}
			}
		}
		
		private function initializeApplicationUpdater():void
		{
			isUpdateChecking = true;
			
			updaterHelper = new AutoUpdaterHelper();
			nativeApplicationUpdater = new NativeApplicationUpdater();
			
			updaterHelper.updater = nativeApplicationUpdater;
			nativeApplicationUpdater.addEventListener(UpdateEvent.INITIALIZED, updaterHelper.updater_initializedHandler, false, 0, true);
			nativeApplicationUpdater.addEventListener(StatusUpdateEvent.UPDATE_STATUS, updater_updateStatusHandler, false, 0, true);
			nativeApplicationUpdater.addEventListener(ErrorEvent.ERROR, updaterHelper.updater_errorHandler, false, 0, true);
			nativeApplicationUpdater.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, updaterHelper.updater_errorHandler, false, 0, true);
			nativeApplicationUpdater.addEventListener(StatusUpdateErrorEvent.UPDATE_ERROR, updaterHelper.updater_errorHandler, false, 0, true);
			nativeApplicationUpdater.addEventListener(UpdateEvent.BEFORE_INSTALL, updater_beforeInstallation, false, 0, true);
			
			nativeApplicationUpdater.currentVersion = getInstalledVersion();
			nativeApplicationUpdater.updateURL = HelperConstants.INSTALLER_UPDATE_CHECK_URL;
			nativeApplicationUpdater.initialize();
		}
		
		private function getInstalledVersion():String
		{
			var currentVersion:String;
			
			// if only any previous installation is present
			// we will able to compare its version with
			var localDescriptor:File = new File(HelperConstants.WINDOWS_64BIT_DOWNLOAD_DIRECTORY).resolvePath("META-INF/AIR/application.xml");
			if (localDescriptor.exists)
			{
				// load local information
				var applicationDescriptor:XML = new XML(FileUtils.readFromFile(localDescriptor));
				var xmlns:Namespace = new Namespace(applicationDescriptor.namespace());
				
				if (xmlns.uri == "http://ns.adobe.com/air/application/2.1")
					currentVersion = applicationDescriptor.xmlns::version;
				else
					currentVersion = applicationDescriptor.xmlns::versionNumber;
				
				return currentVersion;
			}
			
			return "0.0.0";
		}
		
		private function updater_updateStatusHandler(event:StatusUpdateEvent):void
		{
			if (event.available)
			{
				// In case update is available prevent default behavior of checkNow() function 
				// and switch to the view that gives the user ability to decide if he wants to
				// install new version of the application.
				event.preventDefault();
				nativeApplicationUpdater.exitApplicationBeforeInstall = false;
				updaterHelper.btnYes_clickHandler(null);
			}
			else
			{
				runAppStoreHelperWindows();
			}
		}
		
		private function updater_beforeInstallation(event:UpdateEvent):void
		{
			dispatchEvent(new GeneralEvent(GeneralEvent.DONE));
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
			if (executableFile.exists) executableFile.openWithDefaultApplication();
		}
	}
}