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
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	
	import actionScripts.valueObjects.Settings;
	
	public class TaskListManager extends EventDispatcher
	{
		public static const SERVICE_LIST_PARSED:String = "SERVICE_LIST_PARSED";
		
		public var probableJavaServices:Array;
		
		protected var process: NativeProcess;
		protected var executable:File;
		protected var killAfterParsingTasks:Boolean;
		
		public function TaskListManager()
		{
			if (Settings.os == "win") executable = new File("c:\\Windows\\System32\\cmd.exe");
			else executable = new File("/bin/bash");
		}
		
		/**
		 * Initialize CyberDuck FTP for MacOS
		 */
		public function searchAgainstServiceName(killTasks:Boolean):void
		{
			killAfterParsingTasks = killTasks;
			
			// 1. declare necessary arguments
			var npInfo : NativeProcessStartupInfo = new NativeProcessStartupInfo();
			var arg:Vector.<String>;
			
			arg = new Vector.<String>();
			arg.push("/c"); // Windows 
			arg.push("tasklist");
			arg.push("/FI");
			arg.push("sessionname eq console");
			arg.push("/FO");
			arg.push("CSV");
			arg.push("/NH");
			
			npInfo.arguments = arg;
			npInfo.executable = executable;
			process = new NativeProcess();
			attachListenersToProcess(process);
			process.start(npInfo);
		}
		
		/**
		 * Kill any given number of tasks
		 */
		public function killTasks(value:Array):void
		{
			for (var i:String in value)
			{
				var tmpItems:Array = value[i].split(",");
				var serviceNumber:String = tmpItems[1].substring(1, tmpItems[i].length - 2);
				
				var npInfo : NativeProcessStartupInfo = new NativeProcessStartupInfo();
				var arg:Vector.<String>;
				
				arg = new Vector.<String>();
				arg.push("/c"); // Windows 
				arg.push("taskkill");
				arg.push("/PID");
				arg.push(serviceNumber);
				arg.push("/F");
				
				npInfo.arguments = arg;
				npInfo.executable = executable;
				var tmpProcess:NativeProcess = new NativeProcess();
				tmpProcess.start(npInfo);
			}
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
			var output:String = process.standardOutput.readUTFBytes(process.standardOutput.bytesAvailable);
			var tmpArr:Array = output.split("\n");
			var isMoonshineAttempted:Boolean;
			var isFirstJavaAttempted:Boolean;
			
			probableJavaServices = [];
			for (var i:String in tmpArr)
			{
				// for test/debug, make it 'adl' else 'Moonshine'
				if (tmpArr[i].indexOf("adl") != -1) isMoonshineAttempted = true;
				else if (isMoonshineAttempted) 
				{
					if (isFirstJavaAttempted)
					{
						// example
						// "java.exe","7492","Console","1","46,164 K"
						if (tmpArr[i].indexOf("java") != -1) probableJavaServices.push(tmpArr[i]);
					}
					
					// we're skipping this considering first java service AFTER Moonshine is
					// the java server for type-ahead. We don't want to stop that
					if (tmpArr[i].indexOf("java") != -1) isFirstJavaAttempted = true;
				}
			}
			
			// notify the caller
			if (!killAfterParsingTasks) dispatchEvent(new Event(SERVICE_LIST_PARSED));
			else killTasks(probableJavaServices);
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