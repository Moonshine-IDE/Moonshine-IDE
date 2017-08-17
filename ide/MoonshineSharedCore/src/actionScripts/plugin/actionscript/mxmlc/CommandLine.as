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
package actionScripts.plugin.actionscript.mxmlc
{
	import flash.events.ProgressEvent;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.valueObjects.Settings;
	
	public class CommandLine extends ConsoleOutputter
	{
		private function getShell():FileLocation
		{
			// TODO: Maybe this should be a setting.
			var shellPath:String;
			if (Settings.os == "win")
			{
				shellPath = "C:/Windows/System32/cmd.exe";
			}
			else
			{
				shellPath = "/bin/bash"
			}
			
			return new FileLocation(shellPath);
		}
		
		//private var info:NativeProcessStartupInfo;
		private var inited:Boolean;
		
		public function CommandLine() 
		{
			/*var shell:FileLocation = getShell();
			if (!shell.fileBridge.exists) 
			{
				Alert.show("No shell found.");
				return;
			}
			
			info = new NativeProcessStartupInfo();
			info.executable = shell.fileBridge.getFile as File;*/
		}
		
		
		public function write(msg:String, workingDir:FileLocation = null):void 
		{
			/*if (workingDir) info.workingDirectory = workingDir;
			
			var proc:NativeProcess = new NativeProcess();
			proc.start(info);
			proc.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, readData);
			proc.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, readData);
			proc.addEventListener(NativeProcessExitEvent.EXIT, exit);
			proc.standardInput.writeMultiByte(msg+"\nexit\n", "us-ascii");*/
		}
		
		private function readData(e:ProgressEvent):void 
		{
			/*var output:IDataInput = (e.target as NativeProcess).standardOutput;
			debug("CMD: %s", output.readMultiByte(output.bytesAvailable, "us-ascii"));*/
		}
	}
}