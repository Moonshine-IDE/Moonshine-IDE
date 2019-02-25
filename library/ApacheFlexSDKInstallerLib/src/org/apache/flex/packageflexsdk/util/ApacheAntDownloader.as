////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package org.apache.flex.packageflexsdk.util
{
	import flash.desktop.NativeProcess;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	
	import org.apache.flex.packageflexsdk.model.OS;
	import org.apache.flex.packageflexsdk.model.PackageVO;
	import org.apache.flex.packageflexsdk.resource.ViewResourceConstants;
	import org.apache.flex.packageflexsdk.view.events.GenericEvent;
	
	import ws.tink.spark.controls.StepItem;
	
	public class ApacheAntDownloader
	{
		public var installerApacheFlexInstance:InstallApacheFlex;
		public var viewResourceConstants:ViewResourceConstants;
		
		[Bindable] private var antVersionSelected:PackageVO;
		
		private var _os:OS = new OS();
		private var _antTempDir:File;
		private var _apacheAntZipFile:File;
		private var loader:ApacheURLLoader;
		private var antHomeDir:File;
		
		public function ApacheAntDownloader(antVersionSelected:PackageVO)
		{
			this.antVersionSelected = antVersionSelected;
		}
		
		public function startInstallation():void
		{
			// check if the version already downloaded or not
			var antHome:File = new File(antVersionSelected.downloadingTo);
			antHomeDir = antHome;
			if (!antHome.exists) antHome.createDirectory();
			else if (antHome.exists)
			{
				antHome = antHome.resolvePath("bin/ant");
				if (antHome.exists)
				{
					// we take this as the particular ant varsiion already downloaded
					antVersionSelected.isAlreadyDownloaded = true;
					installerApacheFlexInstance.dispatchEvent(new GenericEvent(GenericEvent.INSTALL_FINISH));
					return;
				}
			}
			
			try
			{
				antVersionSelected.isDownloading = true;
				installerApacheFlexInstance.logMASH(viewResourceConstants.INFO_DOWNLOADING_APACHE_ANT + antVersionSelected.packageURL);
				
				var tmpArr:Array = antVersionSelected.packageURL.split("/");
				var packageFileName:String = tmpArr[tmpArr.length - 1];
				
				_antTempDir = antHomeDir.resolvePath("temp");
				if (!_antTempDir.exists) _antTempDir.createDirectory();
				_apacheAntZipFile = _antTempDir.resolvePath(packageFileName);
				installerApacheFlexInstance.copyOrDownloadMASH(antVersionSelected.packageURL, handleApacheAntDownload, _apacheAntZipFile, handleAntDownloadError);
			}
			catch (e:Error)
			{
				antVersionSelected.isDownloading = false;
				antVersionSelected.hasError = true;
				installerApacheFlexInstance.abortInstallationMASH(viewResourceConstants.STEP_OPTIONAL_INSTALL_APACHE_ANT + e.toString());
			}
		}
		
		protected function handleApacheAntDownload(event:Event):void
		{
			try
			{
				installerApacheFlexInstance.writeFileToDirectoryMASH(_apacheAntZipFile, event.target.data);
			}
			catch (e:Error)
			{
				installerApacheFlexInstance.abortInstallationMASH(viewResourceConstants.STEP_OPTIONAL_INSTALL_APACHE_ANT + e.toString());
				antVersionSelected.isDownloading = false;
				antVersionSelected.hasError = true;
			}
			
			unzipAnt();
		}
		
		protected function unzipAnt():void
		{
			try
			{
				if (_os.isWindows())
				{
					unzipAntWindows()
				}
				else
				{
					unzipAntMac();
				}
			}
			catch (e:Error)
			{
				installerApacheFlexInstance.abortInstallationMASH(viewResourceConstants.STEP_UNZIP_APACHE_ANT + e.toString());
				antVersionSelected.isDownloading = false;
				antVersionSelected.hasError = true;
			}
		}
		
		protected function unzipAntWindows():void
		{
			installerApacheFlexInstance.logMASH(viewResourceConstants.INFO_UNZIPPING + _apacheAntZipFile.nativePath);
			installerApacheFlexInstance.unzipMASH(_apacheAntZipFile, handleApacheAntWinZipFileUnzipComplete, handleApacheAntWinZipFileUnzipError);
		}
		
		protected function unzipAntMac():void
		{
			if (NativeProcess.isSupported)
			{
				installerApacheFlexInstance.untarMASH(_apacheAntZipFile, antHomeDir.parent, handleAntMacUntarComplete, handleAntMacUntarError);
			}
			else
			{
				installerApacheFlexInstance.logMASH(viewResourceConstants.ERROR_NATIVE_PROCESS_NOT_SUPPORTED);
			}
		}
		
		protected function handleAntDownloadError(error:* = null):void
		{
			antVersionSelected.isDownloading = false;
			antVersionSelected.hasError = true;
			
			installerApacheFlexInstance.logMASH(viewResourceConstants.ERROR_UNABLE_TO_DOWNLOAD_APACHE_ANT);
			installerApacheFlexInstance.abortInstallationMASH(viewResourceConstants.ERROR_UNABLE_TO_DOWNLOAD_APACHE_ANT);
		}
		
		protected function handleApacheAntWinZipFileUnzipComplete(event:Event):void
		{
			installerApacheFlexInstance.logMASH(viewResourceConstants.INFO_FINISHED_UNZIPPING + _apacheAntZipFile.nativePath);
			installerApacheFlexInstance.logMASH(viewResourceConstants.INFO_INSTALLATION_COMPLETE);
			
			antVersionSelected.isDownloading = false;
			antVersionSelected.isDownloaded = true;
			
			if (_antTempDir && _antTempDir.exists) _antTempDir.deleteDirectory(true);
			installerApacheFlexInstance.dispatchEvent(new GenericEvent(GenericEvent.INSTALL_FINISH));
		}
		
		protected function handleApacheAntWinZipFileUnzipError(error:ErrorEvent = null):void
		{
			installerApacheFlexInstance.updateActivityStepMASH(viewResourceConstants.STEP_UNZIP_APACHE_ANT, StepItem.ERROR);
			antVersionSelected.isDownloading = false;
			antVersionSelected.hasError = true;
		}
		
		protected function handleAntMacUntarError(error:ProgressEvent = null):void
		{
			installerApacheFlexInstance.updateActivityStepMASH(viewResourceConstants.STEP_UNZIP_APACHE_ANT, StepItem.ERROR);
			installerApacheFlexInstance.abortInstallationMASH(viewResourceConstants.STEP_UNZIP_APACHE_ANT);
			antVersionSelected.isDownloading = false;
			antVersionSelected.hasError = true;
		}
		
		protected function handleAntMacUntarComplete(event:Event):void
		{
			installerApacheFlexInstance.updateActivityStepMASH(viewResourceConstants.STEP_UNZIP_APACHE_ANT, StepItem.COMPLETE);
			installerApacheFlexInstance.logMASH(viewResourceConstants.INFO_FINISHED_UNTARING + _apacheAntZipFile.nativePath);
			installerApacheFlexInstance.logMASH(viewResourceConstants.INFO_INSTALLATION_COMPLETE);
			
			antVersionSelected.isDownloaded = true;
			antVersionSelected.isDownloading = false;
			
			if (_antTempDir && _antTempDir.exists) _antTempDir.deleteDirectory(true);
			installerApacheFlexInstance.dispatchEvent(new GenericEvent(GenericEvent.INSTALL_FINISH));
		}
	}
}