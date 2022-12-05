////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
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
			var shFile : File = File.applicationDirectory.resolvePath("macOScripts/openwithapplication.sh");
			
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