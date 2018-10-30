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
	
	public class ApacheMavenDownloader
	{
		public var installerApacheFlexInstance:InstallApacheFlex;
		public var viewResourceConstants:ViewResourceConstants;
		
		[Bindable] private var mavenVersionSelected:PackageVO;
		
		private var _os:OS = new OS();
		private var _mavenTempDir:File;
		private var _apacheMavenZipFile:File;
		private var loader:ApacheURLLoader;
		private var mavenHomeDir:File;
		
		public function ApacheMavenDownloader(mavenVersionSelected:PackageVO)
		{
			this.mavenVersionSelected = mavenVersionSelected;
		}
		
		public function startInstallation():void
		{
			// check if the version already downloaded or not
			var mavenHome:File = new File(mavenVersionSelected.downloadingTo);
			mavenHomeDir = mavenHome;
			if (!mavenHome.exists) mavenHome.createDirectory();
			else if (mavenHome.exists)
			{
				mavenHome = mavenHome.resolvePath("bin/mvn");
				if (mavenHome.exists)
				{
					// we take this as the particular ant varsiion already downloaded
					mavenVersionSelected.isAlreadyDownloaded = true;
					installerApacheFlexInstance.dispatchEvent(new GenericEvent(GenericEvent.INSTALL_FINISH));
					return;
				}
			}
			
			try
			{
				mavenVersionSelected.isDownloading = true;
				installerApacheFlexInstance.logMASH(viewResourceConstants.INFO_DOWNLOADING_APACHE_ANT + mavenVersionSelected.packageURL);
				
				var tmpArr:Array = mavenVersionSelected.packageURL.split("/");
				var packageFileName:String = tmpArr[tmpArr.length - 1];
				
				_mavenTempDir = mavenHomeDir.resolvePath("temp");
				if (!_mavenTempDir.exists) _mavenTempDir.createDirectory();
				_apacheMavenZipFile = _mavenTempDir.resolvePath(packageFileName);
				installerApacheFlexInstance.copyOrDownloadMASH(mavenVersionSelected.packageURL, handleApacheAntDownload, _apacheMavenZipFile, handleAntDownloadError);
			}
			catch (e:Error)
			{
				mavenVersionSelected.isDownloading = false;
				mavenVersionSelected.hasError = true;
				installerApacheFlexInstance.abortInstallationMASH(viewResourceConstants.STEP_OPTIONAL_INSTALL_APACHE_ANT + e.toString());
			}
		}
		
		protected function handleApacheAntDownload(event:Event):void
		{
			try
			{
				installerApacheFlexInstance.writeFileToDirectoryMASH(_apacheMavenZipFile, event.target.data);
			}
			catch (e:Error)
			{
				installerApacheFlexInstance.abortInstallationMASH(viewResourceConstants.STEP_OPTIONAL_INSTALL_APACHE_ANT + e.toString());
				mavenVersionSelected.isDownloading = false;
				mavenVersionSelected.hasError = true;
			}
			
			unzipAnt();
		}
		
		protected function unzipAnt():void
		{
			try
			{
				if (_os.isWindows())
				{
					unzipMavenWindows()
				}
				else
				{
					unzipMavenMac();
				}
			}
			catch (e:Error)
			{
				installerApacheFlexInstance.abortInstallationMASH(viewResourceConstants.STEP_UNZIP_APACHE_ANT + e.toString());
				mavenVersionSelected.isDownloading = false;
				mavenVersionSelected.hasError = true;
			}
		}
		
		protected function unzipMavenWindows():void
		{
			installerApacheFlexInstance.logMASH(viewResourceConstants.INFO_UNZIPPING + _apacheMavenZipFile.nativePath);
			installerApacheFlexInstance.unzipMASH(_apacheMavenZipFile, handleApacheAntWinZipFileUnzipComplete, handleApacheAntWinZipFileUnzipError);
		}
		
		protected function unzipMavenMac():void
		{
			if (NativeProcess.isSupported)
			{
				installerApacheFlexInstance.untarMASH(_apacheMavenZipFile, mavenHomeDir.parent, handleAntMacUntarComplete, handleAntMacUntarError);
			}
			else
			{
				installerApacheFlexInstance.logMASH(viewResourceConstants.ERROR_NATIVE_PROCESS_NOT_SUPPORTED);
			}
		}
		
		protected function handleAntDownloadError(error:* = null):void
		{
			mavenVersionSelected.isDownloading = false;
			mavenVersionSelected.hasError = true;
			
			installerApacheFlexInstance.logMASH(viewResourceConstants.ERROR_UNABLE_TO_DOWNLOAD_APACHE_ANT);
			installerApacheFlexInstance.abortInstallationMASH(viewResourceConstants.ERROR_UNABLE_TO_DOWNLOAD_APACHE_ANT);
		}
		
		protected function handleApacheAntWinZipFileUnzipComplete(event:Event):void
		{
			installerApacheFlexInstance.logMASH(viewResourceConstants.INFO_FINISHED_UNZIPPING + _apacheMavenZipFile.nativePath);
			installerApacheFlexInstance.logMASH(viewResourceConstants.INFO_INSTALLATION_COMPLETE);
			
			mavenVersionSelected.isDownloading = false;
			mavenVersionSelected.isDownloaded = true;
			
			if (_mavenTempDir && _mavenTempDir.exists) _mavenTempDir.deleteDirectory(true);
			installerApacheFlexInstance.dispatchEvent(new GenericEvent(GenericEvent.INSTALL_FINISH));
		}
		
		protected function handleApacheAntWinZipFileUnzipError(error:ErrorEvent = null):void
		{
			installerApacheFlexInstance.updateActivityStepMASH(viewResourceConstants.STEP_UNZIP_APACHE_ANT, StepItem.ERROR);
			mavenVersionSelected.isDownloading = false;
			mavenVersionSelected.hasError = true;
		}
		
		protected function handleAntMacUntarError(error:ProgressEvent = null):void
		{
			installerApacheFlexInstance.updateActivityStepMASH(viewResourceConstants.STEP_UNZIP_APACHE_ANT, StepItem.ERROR);
			installerApacheFlexInstance.abortInstallationMASH(viewResourceConstants.STEP_UNZIP_APACHE_ANT);
			mavenVersionSelected.isDownloading = false;
			mavenVersionSelected.hasError = true;
		}
		
		protected function handleAntMacUntarComplete(event:Event):void
		{
			installerApacheFlexInstance.updateActivityStepMASH(viewResourceConstants.STEP_UNZIP_APACHE_ANT, StepItem.COMPLETE);
			installerApacheFlexInstance.logMASH(viewResourceConstants.INFO_FINISHED_UNTARING + _apacheMavenZipFile.nativePath);
			installerApacheFlexInstance.logMASH(viewResourceConstants.INFO_INSTALLATION_COMPLETE);
			
			mavenVersionSelected.isDownloaded = true;
			mavenVersionSelected.isDownloading = false;
			
			if (_mavenTempDir && _mavenTempDir.exists) _mavenTempDir.deleteDirectory(true);
			installerApacheFlexInstance.dispatchEvent(new GenericEvent(GenericEvent.INSTALL_FINISH));
		}
	}
}