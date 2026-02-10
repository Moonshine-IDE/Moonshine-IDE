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
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.interfaces.IModulesFinder;
	import actionScripts.plugins.build.ConsoleBuildPluginBase;
	import actionScripts.valueObjects.ConstantsCoreVO;

	public class ModulesFinder extends ConsoleBuildPluginBase implements IModulesFinder
	{
		protected var onExitFunction:Function;
		protected var modulesFileList:Array;
		
		private var isError:Boolean;
		
		public function ModulesFinder()
		{
			super.activate();
		}
		
		public function search(projectFolder:FileLocation, sourceFolder:FileLocation, exitFn:Function):void
		{
			if (nativeProcess && nativeProcess.running) return;
			
			onExitFunction = exitFn;
			isError = false;
			
			var command:String;
			if (ConstantsCoreVO.IS_WINDOWS)
			{
				command = '"c:\\Windows\\System32\\findstr.exe" /s /i /m /c:"<s:Module " ';
				command += '"'+ (sourceFolder ? sourceFolder.fileBridge.nativePath : projectFolder.fileBridge.nativePath) +'\\*"';
			}
			else
			{
				command = "/usr/bin/grep -ilR '<s:Module ' '"+ 
					(
						(!sourceFolder || projectFolder.fileBridge.nativePath == sourceFolder.fileBridge.nativePath) ? 
						projectFolder.fileBridge.nativePath : 
						projectFolder.fileBridge.getRelativePath(sourceFolder, true)
					) +"'";
			}
			
			// run the command
			this.start(
				new <String>[command], projectFolder
			);
		}
		
		public function dispose():void
		{
			super.deactivate();
			
			onExitFunction = null;
			modulesFileList = null;
		}
		
		override protected function onNativeProcessStandardOutputData(event:ProgressEvent):void
		{
			modulesFileList = getDataFromBytes(nativeProcess.standardOutput).split(
				ConstantsCoreVO.IS_WINDOWS ? "\r\n" : "\n" 
			);
			
			// result insert a blank row at the end
			modulesFileList.pop();
		}
		
		override protected function onNativeProcessExit(event:NativeProcessExitEvent):void
		{
			super.onNativeProcessExit(event);
			if (onExitFunction != null)
			{
				onExitFunction(modulesFileList, isError);
			}
		}
		
		override protected function onNativeProcessIOError(event:IOErrorEvent):void
		{
			super.onNativeProcessIOError(event);
			isError = true;
		}
		
		override protected function onNativeProcessStandardErrorData(event:ProgressEvent):void
		{
			super.onNativeProcessStandardErrorData(event);
			isError = true;
		}
	}
}