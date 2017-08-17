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
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;

	public class AddCommand extends SVNCommandBase
	{
		public function AddCommand(executable:File, root:File)
		{
			super(executable, root);
		}

		public function add(file:File):void
		{
			if (runningForFile)
			{
				error("Currently running, try again later.");
				return;
			}
			
			runningForFile = file;
			
			customInfo = new NativeProcessStartupInfo();
			customInfo.executable = executable;
			
			var args:Vector.<String> = new Vector.<String>();
			
			var target:String = file.getRelativePath(root, false);
			// If we're refreshing the root we give roots name
			if (!target) target = file.name;
			 
			args.push("add");
			args.push(target);
			
			customInfo.arguments = args;
			// We give the file as target, so go one directory up
			customInfo.workingDirectory = file.parent;
			
			customProcess = new NativeProcess();
			customProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, svnError);
			customProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, svnOutput);
			customProcess.addEventListener(NativeProcessExitEvent.EXIT, svnExit);
			customProcess.start(customInfo);
		}
		
		protected function svnError(event:ProgressEvent):void
		{
			
		} 
		protected function svnOutput(event:ProgressEvent):void
		{
			
		}
		
		protected function svnExit(event:NativeProcessExitEvent):void
		{
			if (event.exitCode == 0)
			{
				// Update succeded (but no need to tell anyone, useful for debugging maybe)
				//var str:String = customProcess.standardOutput.readUTFBytes(customProcess.standardOutput.bytesAvailable);
				//notice(str);
				
				// Tell caller we're done
				dispatchEvent( new Event(Event.COMPLETE) );
			}
			else
			{
				// Add failed
				var err:String = customProcess.standardError.readUTFBytes(customProcess.standardError.bytesAvailable);
				error(err);
				
				// Tell caller we failed
				dispatchEvent( new Event(Event.CANCEL) );
			}
			
			runningForFile = null;
			customProcess = null;
		}
		
	}
}