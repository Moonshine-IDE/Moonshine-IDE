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
package actionScripts.plugins.haxelib.utils
{
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import actionScripts.utils.UtilsCore;

	public class HaxelibFinder extends EventDispatcher
	{
		public static function find(haxelibName:String, callback:Function):void
		{
			if(!UtilsCore.isHaxeAvailable())
			{
				callback(null);
				return;
			}
			var finder:HaxelibFinderImpl = new HaxelibFinderImpl(haxelibName, callback);
		}
	}
}

import actionScripts.valueObjects.EnvironmentExecPaths;
import actionScripts.utils.EnvironmentSetupUtils;
import flash.filesystem.File;
import actionScripts.valueObjects.Settings;
import flash.desktop.NativeProcessStartupInfo;
import flash.desktop.NativeProcess;
import flash.events.NativeProcessExitEvent;
import actionScripts.utils.CommandLineUtil;
import flash.events.ProgressEvent;
import flash.utils.IDataInput;

class HaxelibFinderImpl
{
	private var _haxelibName:String;
	private var _callback:Function;
	private var _result:String;

	public function HaxelibFinderImpl(haxelibName:String, callback:Function):void
	{
		_haxelibName = haxelibName;
		_callback = callback;
		_result = "";

		var pathCommand:Vector.<String> = new <String>[
			EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH,
			"libpath",
			haxelibName
		];
		EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(function(value:String):void
		{
			var cmdFile:File = null;
			var processArgs:Vector.<String> = new <String>[];
			
			if (Settings.os == "win")
			{
				cmdFile = new File("c:\\Windows\\System32\\cmd.exe");
				processArgs.push("/c");
				processArgs.push(value);
			}
			else
			{
				cmdFile = new File("/bin/bash");
				processArgs.push("-c");
				processArgs.push(value);
			}

			var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			processInfo.arguments = processArgs;
			processInfo.executable = cmdFile;
		
			var process:NativeProcess = new NativeProcess();
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, libpathProcess_standardOutputDataHandler);
			process.addEventListener(NativeProcessExitEvent.EXIT, libpathProcess_exitHandler);
			process.start(processInfo);
		}, null, [CommandLineUtil.joinOptions(pathCommand)]);
	}

	private function libpathProcess_standardOutputDataHandler(event:ProgressEvent):void
	{
		var process:NativeProcess = NativeProcess(event.currentTarget);
		var output:IDataInput = process.standardOutput;
		var data:String = output.readUTFBytes(output.bytesAvailable);
		_result += data;
	}

	private function libpathProcess_exitHandler(event:NativeProcessExitEvent):void
	{
		var process:NativeProcess = NativeProcess(event.currentTarget);
		process.removeEventListener(NativeProcessExitEvent.EXIT, libpathProcess_exitHandler);
		process.exit();

		if(event.exitCode != 0)
		{
			_callback(null);
			return;
		}

		_result = _result.replace(/[\r\n]/g, "");
		_callback(_result);
	}
}