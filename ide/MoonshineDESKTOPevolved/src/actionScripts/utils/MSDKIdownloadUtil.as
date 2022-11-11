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
				nativeApplicationUpdater = new NativeApplicationUpdater();
				if (executableFile.exists)
				{
					runAppStoreHelperWindows();
				}
				else if (((!executableFile.exists && !isUpdateChecking && !isDownloading) || 
					(!isUpdateChecking && !isDownloading)) && 
					!isUpdateChecked) 
				{
					// make sure we does this check once
					// in an application lifecycle
					initializeApplicationUpdater();
				}
			}
		}
		
		private function initializeApplicationUpdater():void
		{
			isUpdateChecking = true;
			
			updaterHelper = new AutoUpdaterHelper();
			updaterHelper.addEventListener(GeneralEvent.DONE, onUpdaterHelperDone, false, 0, true);
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
				onUpdaterHelperDone(null);
				runAppStoreHelperWindows();
			}
		}
		
		private function updater_beforeInstallation(event:UpdateEvent):void
		{
			dispatchEvent(new GeneralEvent(GeneralEvent.DONE));
			onUpdaterHelperDone(null);
		}
		
		private function onUpdaterHelperDone(event:GeneralEvent):void
		{
			if (nativeApplicationUpdater)
			{
				nativeApplicationUpdater.removeEventListener(UpdateEvent.INITIALIZED, updaterHelper.updater_initializedHandler);
				nativeApplicationUpdater.removeEventListener(StatusUpdateEvent.UPDATE_STATUS, updater_updateStatusHandler);
				nativeApplicationUpdater.removeEventListener(ErrorEvent.ERROR, updaterHelper.updater_errorHandler);
				nativeApplicationUpdater.removeEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, updaterHelper.updater_errorHandler);
				nativeApplicationUpdater.removeEventListener(StatusUpdateErrorEvent.UPDATE_ERROR, updaterHelper.updater_errorHandler);
				nativeApplicationUpdater.removeEventListener(UpdateEvent.BEFORE_INSTALL, updater_beforeInstallation);
				nativeApplicationUpdater = null;
				
				updaterHelper.removeEventListener(GeneralEvent.DONE, onUpdaterHelperDone);
				updaterHelper = null;
				
				isUpdateChecking = false;
				isUpdateChecked = false;
				isDownloading = false;
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
			if (executableFile.exists)
			{
				nativeApplicationUpdater.exitApplicationBeforeInstall = false;
				nativeApplicationUpdater.installFromFile(executableFile);
				//executableFile.openWithDefaultApplication();
			}
		}
	}
}