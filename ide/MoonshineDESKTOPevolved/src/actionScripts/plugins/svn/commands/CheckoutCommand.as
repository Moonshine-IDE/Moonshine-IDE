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
package actionScripts.plugins.svn.commands
{
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	
	import actionScripts.events.ProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugins.svn.event.SVNEvent;
	import actionScripts.valueObjects.ProjectVO;
	
	public class CheckoutCommand extends SVNCommandBase
	{
		private var cmdFile:File;
		
		public function CheckoutCommand(executable:File, root:File)
		{
			super(executable, root);
			//cmdFile = new File("c:\\Windows\\System32\\cmd.exe");
			
		}
		
		public function checkout(event:SVNEvent):void
		{
			if (runningForFile)
			{
				error("Currently running, try again later.");
				return;
			}
			
			notice("Trying to check out %s. May take a while.", event.url);
			
			customInfo = new NativeProcessStartupInfo();
			customInfo.executable = executable;
			//customInfo.executable = cmdFile; 
			
			// http://stackoverflow.com/questions/1625406/using-tortoisesvn-via-the-command-line
			var args:Vector.<String> = new Vector.<String>();
			args.push("checkout");
			if (event.authObject != null)
			{
				args.push("--username");
				args.push(event.authObject.username);
				args.push("--password");
				args.push(event.authObject.password);
			}
			args.push(event.url);
			
			customInfo.arguments = args;
			customInfo.workingDirectory = event.file;
			
			customProcess = new NativeProcess();
			customProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, svnError);
			customProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, svnOutput);
			customProcess.addEventListener(NativeProcessExitEvent.EXIT, svnExit);
			customProcess.start(customInfo);
			
			var tmpSplit: Array = event.url.split("/");
			var tmpLastFolderName: String = tmpSplit[tmpSplit.length-1];
			var newFilePath: String = !NativeApplication.supportsSystemTrayIcon ? event.file.nativePath +"/"+ tmpLastFolderName : event.file.nativePath +"\\"+ tmpLastFolderName;
			
			runningForFile = new File(newFilePath);
		}
		
		protected function svnError(event:ProgressEvent):void
		{
			var output:IDataInput = customProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
	
			if (serverCertificatePrompt(data)) return;
	
			error("%s", data);
		}
		
		protected function svnOutput(event:ProgressEvent):void
		{ 
			var output:IDataInput = customProcess.standardOutput;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			
			notice("%s", data);
		}
		
		protected function svnExit(event:NativeProcessExitEvent):void
		{
			if (event.exitCode == 0)
			{
				var p:ProjectVO = new ProjectVO(new FileLocation(runningForFile.nativePath));
				dispatcher.dispatchEvent(
					new ProjectEvent(ProjectEvent.ADD_PROJECT, p)
				);
			}
			else
			{
				// Checkout failed
			}
			
			runningForFile = null;
			customProcess = null;
		}
		
	}
}