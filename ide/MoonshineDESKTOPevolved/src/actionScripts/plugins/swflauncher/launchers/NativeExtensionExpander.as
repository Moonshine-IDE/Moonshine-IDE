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
package actionScripts.plugins.swflauncher.launchers
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	
	import mx.controls.Alert;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;

	public class NativeExtensionExpander
	{
		public function NativeExtensionExpander(extensions:Array)
		{
			for each (var i:File in extensions)
			{
				if (i.extension.toLowerCase() == "ane")
				{
					var onlyFileName:String = i.name.substr(0, i.name.length - 4);
					var extensionNamedFolder:File = i.parent.resolvePath(onlyFileName +"ANE.ane");
					
					// if no named folder exists
					if (!extensionNamedFolder.exists)
					{
						extensionNamedFolder.createDirectory();
						startUnzipProcess(extensionNamedFolder, i);
					}
					// in case of named folder already exists
					else if (extensionNamedFolder.isDirectory)
					{
						// predict if all files are available
						if (extensionNamedFolder.getDirectoryListing().length < 4)
						{
							startUnzipProcess(extensionNamedFolder, i);
						}
					}
				}
			}
		}
		
		private function startUnzipProcess(toFolder:File, byANE:File):void
		{
			var processArgs:Vector.<String> = new Vector.<String>;
			if (ConstantsCoreVO.IS_MACOS)
			{
				processArgs.push("-c");
				processArgs.push("unzip ../"+ byANE.name);
			}
			else
			{
				processArgs.push("xf");
				processArgs.push("..\\"+ byANE.name);
			}
			
			var tmpExecutableJava:FileLocation = UtilsCore.getExecutableJavaLocation();
			if (!ConstantsCoreVO.IS_MACOS && (!tmpExecutableJava || !tmpExecutableJava.fileBridge.exists))
			{
				Alert.show("You need Java to complete this process.\nYou can setup Java by going into Settings under File menu.", "Error!");
				return;
			}
			else if (!ConstantsCoreVO.IS_MACOS)
			{
				tmpExecutableJava = tmpExecutableJava.fileBridge.parent.resolvePath("jar.exe");
			}
			
			var shellInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			shellInfo.arguments = processArgs;
			shellInfo.executable = ConstantsCoreVO.IS_MACOS ? new File("/bin/bash") : tmpExecutableJava.fileBridge.getFile as File;
			shellInfo.workingDirectory = toFolder;
			
			var fcsh:NativeProcess = new NativeProcess();
			startShell(fcsh, shellInfo);
		}
		
		private function startShell(fcsh:NativeProcess, shellInfo:NativeProcessStartupInfo = null, start:Boolean = true):void 
		{
			if (start)
			{
				fcsh = new NativeProcess();
				fcsh.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
				fcsh.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR,shellError);
				fcsh.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR,shellError);
				fcsh.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
				fcsh.start(shellInfo);
			}
			else
			{
				if (!fcsh) return;
				if (fcsh.running) fcsh.exit();
				fcsh.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
				fcsh.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR,shellError);
				fcsh.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR,shellError);
				fcsh.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
				fcsh = null;
			}
		}
		
		private function shellError(event:ProgressEvent):void 
		{
			var output:IDataInput = event.target.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			trace("Error in Native Extension unzip process: "+ data);
			
			startShell(event.target as NativeProcess, null, false);
		}
		
		private function shellExit(event:NativeProcessExitEvent):void 
		{
			startShell(event.target as NativeProcess, null, false);
		}
	}
}