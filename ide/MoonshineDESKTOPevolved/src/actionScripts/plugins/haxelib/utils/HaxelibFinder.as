////////////////////////////////////////////////////////////////////////////////
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
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
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