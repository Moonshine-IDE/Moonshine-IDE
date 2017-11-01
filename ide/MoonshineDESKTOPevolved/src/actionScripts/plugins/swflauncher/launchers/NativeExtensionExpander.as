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
package actionScripts.plugins.swflauncher.launchers
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	
	import actionScripts.valueObjects.Settings;

	public class NativeExtensionExpander
	{
		public function NativeExtensionExpander(extensions:Array)
		{
			for each (var i:File in extensions)
			{
				var onlyFileName:String = i.name.split(".")[0];
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
		
		private function startUnzipProcess(toFolder:File, byANE:File):void
		{
			var processArgs:Vector.<String> = new Vector.<String>;
			if (Settings.os == "win")
			{
				processArgs.push("/c");
			}
			else
			{
				processArgs.push("-c");
				processArgs.push("unzip ../"+ byANE.name);
			}
			
			var shellInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			shellInfo.executable = (Settings.os == "win") ? new File("c:\\Windows\\System32\\cmd.exe") : new File("/bin/bash");
			shellInfo.workingDirectory = toFolder;
			shellInfo.arguments = processArgs;
			
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