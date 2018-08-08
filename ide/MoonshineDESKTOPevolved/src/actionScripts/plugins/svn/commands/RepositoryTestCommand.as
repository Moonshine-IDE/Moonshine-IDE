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
	import flash.utils.IDataInput;
	
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugins.svn.SVNPlugin;
	import actionScripts.ui.menu.vo.ProjectMenuTypes;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ProjectVO;
	
	public class RepositoryTestCommand extends SVNCommandBase
	{
		private var cmdFile:File;
		private var projectPath:String;
		
		public function RepositoryTestCommand(executable:File, root:File, projectPath:String)
		{
			super(executable, root);
			this.projectPath = projectPath;
		}
		
		public function test():void
		{
			if (customProcess && customProcess.running)
			{
				return;
			}
			
			customInfo = new NativeProcessStartupInfo();
			customInfo.executable = executable;
			
			var args:Vector.<String> = new Vector.<String>();
			args.push("ls");
			/*args.push("--username");
			args.push("santanu");
			args.push("--password");
			args.push("qas78mkp");*/
			args.push("--non-interactive");
			args.push("--trust-server-cert");
			/*args.push("--trust-server-cert-failures");
			args.push("unknown-ca,cn-mismatch,expired,not-yet-valid,other");*/
			args.push(projectPath);
			
			customInfo.arguments = args;
			
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "SVN Repository", "Testing ", false));
			
			startShell(true);
			customProcess.start(customInfo);
		}
		
		private function startShell(start:Boolean):void
		{
			if (start)
			{
				customProcess = new NativeProcess();
				customProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, svnError);
				customProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, svnOutput);
				customProcess.addEventListener(NativeProcessExitEvent.EXIT, svnExit);
			}
			else
			{
				if (!customProcess) return;
				if (customProcess.running) customProcess.exit();
				customProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, svnError);
				customProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, svnOutput);
				customProcess.removeEventListener(NativeProcessExitEvent.EXIT, svnExit);
				customProcess = null;
				customInfo = null;
			}
		}
		
		protected function svnError(event:ProgressEvent):void
		{
			var output:IDataInput = customProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
	
			error("%s", data);
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
			startShell(false);
			dispatcher.dispatchEvent(new Event(SVNPlugin.SVN_TEST_COMPLETED));
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
				var tmpProject:ProjectVO = UtilsCore.getProjectByPath(projectPath);
				(tmpProject as AS3ProjectVO).menuType += ","+ ProjectMenuTypes.SVN_PROJECT;
				// following will enable/disable Moonshine top menus based on project
				dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.ACTIVE_PROJECT_CHANGED, tmpProject));
			}
			else
			{
				// Checkout failed
			}
			
			/*runningForFile = null;
			customProcess = null;*/
			startShell(false);
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
			dispatcher.dispatchEvent(new Event(SVNPlugin.SVN_TEST_COMPLETED));
		}
	}
}