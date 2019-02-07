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
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.Capabilities;

	public class DownloadUtil
	{
		public static function download(url:String, completeFunction:Function, errorFunction:Function=null, progressFunction:Function=null):void
		{
			var loader:URLLoader = new URLLoader();
			var req:URLRequest = new URLRequest(url);
			req.idleTimeout = 60000;
			
			loader.dataFormat = URLLoaderDataFormat.BINARY; 
			loader.addEventListener(Event.COMPLETE, completeFunction,false,0,true);
			
			if (errorFunction != null)
			{
				loader.addEventListener(ErrorEvent.ERROR,errorFunction,false,0,true);
				loader.addEventListener(IOErrorEvent.IO_ERROR,errorFunction,false,0,true);
			}
			if(progressFunction != null)
			{
				loader.addEventListener(ProgressEvent.PROGRESS, progressFunction,false,0,true);
			}
			
			loader.load(req);
		}
		
		public static function invokeNativeProcess(args:Vector.<String>):void
		{
			var os:String = Capabilities.os.toLowerCase();
			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			var cmdExe:File = (os.indexOf("win") > -1) ? new File("C:\\Windows\\System32\\cmd.exe") : null;
			if (cmdExe && cmdExe.exists)
			{
				info.executable = cmdExe;
				info.arguments = args;
			}
			var installProcess:NativeProcess = new NativeProcess();
			installProcess.start(info);
		}
		
		public static function executeFile(file:File,completeFunction:Function=null):void
		{
			var os:String = Capabilities.os.toLowerCase();
			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			info.executable = file;
			var process:NativeProcess = new NativeProcess();
			if(completeFunction != null)
			{
				process.addEventListener(NativeProcessExitEvent.EXIT, completeFunction,false,0,true);
			}
			process.addEventListener(NativeProcessExitEvent.EXIT, handleNativeProcessComplete,false,0,true);
			process.start(info);
		}
		
		protected static function handleNativeProcessComplete(event:NativeProcessExitEvent):void
		{
			var process:NativeProcess = NativeProcess(event.target);
			process.closeInput();
			process.exit(true);
		}
	}
}