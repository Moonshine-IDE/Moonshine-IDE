////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc. 
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.utils
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	
	public class SHClassTest
	{
		protected var process: NativeProcess;
		
		public function SHClassTest()
		{
		}
		
		/**
		 * Initialize CyberDuck FTP for MacOS
		 */
		public function removeExAttributesTo(appPath:String):void
		{
			// 1. declare necessary arguments
			var npInfo : NativeProcessStartupInfo = new NativeProcessStartupInfo();
			var arg:Vector.<String>;
			var exeCommand : String;
			var shPath : String = initCHMOD( npInfo, arg );
			
			// need to asynchronise the NativeProcess event completion
			// in initCHMOD to start the next process
			process.addEventListener(NativeProcessExitEvent.EXIT, onProcessEnd);
			
			/*
			* @local
			* on NativeProcess ends
			*/
			function onProcessEnd(event:NativeProcessExitEvent):void
			{
				// removals
				event.target.removeEventListener(NativeProcessExitEvent.EXIT, onProcessEnd);
				releaseListenersToProcess(event);
				
				// 2. triggering the application
				arg = new Vector.<String>();
				arg.push( "-c" ); 
				exeCommand = shPath+" '"+ appPath +"'";
				arg.push( exeCommand );
				
				npInfo.arguments = arg;
				process = new NativeProcess();
				process.start( npInfo );
				attachListenersToProcess(process);
			}
		}
		
		protected function initCHMOD( npInfo:NativeProcessStartupInfo, arg:Vector.<String>, withARGS:Boolean=true ) : String {
			
			// 2. generating arguments
			npInfo.executable = File.documentsDirectory.resolvePath( "/bin/bash" );
			arg = new Vector.<String>();
			
			// for MacOS platform
			var shFile : File = File.applicationDirectory.resolvePath("appScripts/openwithapplication.sh");
			
			// making proper case-sensitive to work in case-sensitive system like Linux
			//shFile.canonicalize();
			var pattern : RegExp = new RegExp( /( )/g );
			var shPath : String = shFile.nativePath;
			shPath = shPath.replace( pattern, "\\ " );
			
			// @call 1
			arg.push( "-c" );
			arg.push( "chmod +x "+shPath );
			npInfo.arguments = arg;
			process = new NativeProcess();
			process.start( npInfo );
			attachListenersToProcess(process);
			
			// @return
			return shPath;
		}
		
		/**
		 * Attach listeners to NativeProcess
		 */
		protected function attachListenersToProcess(target:NativeProcess):void
		{
			target.addEventListener(NativeProcessExitEvent.EXIT, onExit);
			target.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData);
			target.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onErrorData);
			target.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onIOError);
			target.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onIOError);
		}
		
		/**
		 * Release all the listeners from NativeProcess
		 */
		protected function releaseListenersToProcess(event:Event):void
		{
			event.target.removeEventListener(NativeProcessExitEvent.EXIT, onExit);
			event.target.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData);
			event.target.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, onErrorData);
			event.target.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onIOError);
			event.target.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onIOError);
			process.closeInput();
		}
		
		/**
		 * NativeProcess outputData handler
		 */
		private function onOutputData(event:ProgressEvent):void
		{
			releaseListenersToProcess(event);
			//superTrace.setConnectionLog("NativeProcess OutputData: " +process.standardOutput.readUTFBytes(process.standardOutput.bytesAvailable));
		}
		
		/**
		 * NativeProcess errorData handler
		 */
		private function onErrorData(event:ProgressEvent):void
		{
			releaseListenersToProcess(event);
			//superTrace.setConnectionLog("NativeProcess ERROR: " +process.standardError.readUTFBytes(process.standardError.bytesAvailable)); 
		}
		
		/**
		 * NativeProcess exit handler
		 */
		private function onExit(event:NativeProcessExitEvent):void
		{
			releaseListenersToProcess(event);
			//superTrace.setConnectionLog("NativeProcess Exit: " +event.exitCode);
		}
		
		/**
		 * NativeProcess ioError handler
		 */
		private function onIOError(event:IOErrorEvent):void
		{
			releaseListenersToProcess(event);
			//superTrace.setConnectionLog("NativeProcess IOERROR: " +event.toString());
		}
	}
}