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
	
	import actionScripts.events.RefreshTreeEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugins.versionControl.VersionControlUtils;

	public class UpdateCommand extends SVNCommandBase
	{
		public function UpdateCommand(executable:File, root:File)
		{
			super(executable, root);
		}
		
		public function update(file:File, user:String=null, password:String=null, isTrustServerCertificateSVN:Boolean=false):void
		{
			if (customProcess && customProcess.running)
			{
				return;
			}
			
			this.isTrustServerCertificateSVN = isTrustServerCertificateSVN;
			root = file;
			
			// check repository info first
			this.getRepositoryInfo();
		}
		
		override protected function handleInfoUpdateComplete(event:Event):void
		{
			super.handleInfoUpdateComplete(event);
			if (this.repositoryItem) this.isTrustServerCertificateSVN = this.repositoryItem.isTrustCertificate;
			if (this.repositoryItem && this.repositoryItem.userName && this.repositoryItem.userPassword)
			{
				doUpdate(this.repositoryItem.userName, this.repositoryItem.userPassword);
			}
			else
			{
				doUpdate();
			}
		}
		
		private function doUpdate(user:String=null, password:String=null):void
		{
			customInfo = new NativeProcessStartupInfo();
			customInfo.executable = executable;
			
			var args:Vector.<String> = new Vector.<String>();
			
			args.push("update");
			if (user && password)
			{
				args.push("--username");
				args.push(user);
				args.push("--password");
				args.push(password);
			}
			args.push("--non-interactive");
			if (isTrustServerCertificateSVN) args.push("--trust-server-cert");
			
			customInfo.arguments = args;
			// We give the file as target, so go one directory up
			customInfo.workingDirectory = root;
			
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Requested", "SVN Process ", false));
			
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
			var str:String = customProcess.standardError.readUTFBytes(customProcess.standardOutput.bytesAvailable);
			error(str);
			
			//startShell(false);
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
		}
		
		protected function svnOutput(event:ProgressEvent):void
		{
			
		}
		
		protected function svnExit(event:NativeProcessExitEvent):void
		{
			if (event.exitCode == 0)
			{
				// Update succeded
				var str:String = customProcess.standardOutput.readUTFBytes(customProcess.standardOutput.bytesAvailable);
				
				notice(str);
						
				// Show changes in project view
				dispatcher.dispatchEvent(
					new RefreshTreeEvent(new FileLocation(root.nativePath))
				);
			}
			else
			{
				// Refresh failed
				var err:String = customProcess.standardError.readUTFBytes(customProcess.standardError.bytesAvailable);
				if (VersionControlUtils.hasAuthenticationFailError(err))
				{
					openAuthentication();
				}
				else error(err);
			}
			
			startShell(false);
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
		}
		
		override protected function onAuthenticationSuccess(username:String, password:String):void
		{
			this.doUpdate(username, password);
		}
	}
}