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
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	
	import actionScripts.factory.FileLocation;

	public class Untar
	{
		private var process:NativeProcess;
		private var ownerCompleteFn:Function;
		private var ownerErrorFn:Function;
		
		private var unzipTo:FileLocation;
		
		public function Untar(fileToUnzip:FileLocation, unzipTo:FileLocation, unzipCompleteFunction:Function, unzipErrorFunction:Function = null)
		{
			this.unzipTo = unzipTo;
			
			ownerCompleteFn = unzipCompleteFunction;
			ownerErrorFn = unzipErrorFunction;
			
			var tar:File;
			var startupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			var arguments:Vector.<String> = new Vector.<String>();
			
			tar = new File("/usr/bin/bsdtar");
			if (!tar.exists) tar = new File("/usr/bin/tar");
			
			arguments.push("xf");
			arguments.push(fileToUnzip.fileBridge.nativePath);
			arguments.push("-C");
			arguments.push(unzipTo.fileBridge.nativePath);
			
			startupInfo.executable = tar;
			startupInfo.arguments = arguments;
			
			process = new NativeProcess();
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, unTarFileProgress, false, 0, true);
			process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, unzipErrorFunction, false, 0, true);
			process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, unTarError, false, 0, true);
			process.addEventListener(NativeProcessExitEvent.EXIT, unzipCompleteFunction, false, 0, true);
			process.addEventListener(NativeProcessExitEvent.EXIT, unTarComplete, false, 0, true);
			process.start(startupInfo);
		}
		
		private function unTarError(event:Event):void
		{
			//var output:String = process.standardError.readUTFBytes(process.standardError.bytesAvailable);
		}
		
		private function unTarFileProgress(event:Event):void
		{
			/*var output:String = _process.standardOutput.readUTFBytes(_process.standardOutput.bytesAvailable);
			log(output);*/
		}
		
		private function unTarComplete(event:NativeProcessExitEvent):void
		{
			removeListeners();
			process.closeInput();
			process.exit(true);
		}
		
		private function removeListeners():void
		{
			process.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, unTarFileProgress);
			process.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, unTarError);
			process.removeEventListener(NativeProcessExitEvent.EXIT, unTarComplete);
			process.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, ownerErrorFn);
			process.removeEventListener(NativeProcessExitEvent.EXIT, ownerCompleteFn);
			
			ownerCompleteFn = null;
			ownerErrorFn = null;
		}
	}
}