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
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	
	import actionScripts.events.StatusBarEvent;
	import actionScripts.plugins.git.model.MethodDescriptor;
	import actionScripts.plugins.svn.event.SVNEvent;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.RepositoryItemVO;
	
	public class LoadRemoteListCommand extends SVNCommandBase
	{
		private var cmdFile:File;
		private var isEventReported:Boolean;
		private var remoteOutput:String;
		private var onCompletion:Function;
		private var lastEventServerCertificateState:Boolean;
		
		public function LoadRemoteListCommand(executable:File, root:File)
		{
			super(executable, root);
		}
		
		public function loadList(event:SVNEvent, completion:Function):void
		{
			onCompletion = null;
			remoteOutput = null;
			lastKnownMethod = null;
			lastEvent = null;
			
			lastEvent = event;
			onCompletion = completion;
			lastEventServerCertificateState = event.repository.isTrustCertificate;
			notice("Remote data requested. This may take a while.", event.repository.url);
			
			isEventReported = false;
			customInfo = new NativeProcessStartupInfo();
			customInfo.executable = executable;
			
			var args:Vector.<String> = new Vector.<String>();
			var username:String;
			var password:String;
			args.push("ls");
			args.push("--depth");
			args.push("immediates");
			if (event.repository && event.repository.userName && event.repository.userPassword)
			{
				username = event.repository.userName;
				password = event.repository.userPassword;
			}
			else if (event.authObject != null)
			{
				username = event.authObject.username;
				password = event.authObject.password;
			}
			if (username != null && password != null)
			{
				args.push("--username");
				args.push(username);
				args.push("--password");
				args.push(password);
			}
			args.push(event.repository.url);
			if (lastEventServerCertificateState) args.push("--trust-server-cert");
			
			customInfo.arguments = args;
			
			startShell(true);
			customProcess.start(customInfo);
		}
		
		override protected function onCancelAuthentication():void
		{
			// notify to the caller
			if (onCompletion != null) 
			{
				onCompletion(lastEvent.repository, false);
				onCompletion = null;
			}
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
			
			var match:Array = data.toLowerCase().match(/error validating server certificate for/);
			if (!match) match = data.toLowerCase().match(/issuer is not trusted/);
			if (match) 
			{
				//serverCertificatePrompt(data);
				onCancelAuthentication();
			}
			
			match = data.toLowerCase().match(/authentication failed/);
			if (match)
			{
				lastKnownMethod = new MethodDescriptor(this, "loadList", lastEvent, onCompletion);
				openAuthentication();
			}
	
			error("%s", data);
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
			dispatcher.dispatchEvent(new SVNEvent(SVNEvent.SVN_ERROR, null));
			startShell(false);
		}
		
		protected function svnOutput(event:ProgressEvent):void
		{
			if (!isEventReported)
			{
				dispatcher.dispatchEvent(new SVNEvent(SVNEvent.SVN_RESULT, null));
				isEventReported = true;
			}
			
			var output:IDataInput = customProcess.standardOutput;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			
			if (!remoteOutput) remoteOutput = data;
			else remoteOutput += data;
		}
		
		protected function svnExit(event:NativeProcessExitEvent):void
		{
			if (event.exitCode == 0)
			{
				parseRemoteOutput();
			}
			
			startShell(false);
		}
		
		protected function parseRemoteOutput():void
		{
			if (remoteOutput)
			{
				var lines:Array = remoteOutput.split(ConstantsCoreVO.IS_MACOS ? "\n" : "\r\n");
				var tmpRepoItem:RepositoryItemVO;
				for each (var line:String in lines)
				{
					if (line != "")
					{
						tmpRepoItem = new RepositoryItemVO();
						if (line.charAt(line.length-1) == "/")
						{
							// consider a folder
							tmpRepoItem.children = [];
							line = line.replace("/", "");
							tmpRepoItem.url = lastEvent.repository.url +"/"+ line;
						}
						
						tmpRepoItem.label = line;
						
						// we also want to keep few information from
						// top level for later retreival
						tmpRepoItem.isRequireAuthentication = lastEvent.repository.isRequireAuthentication;
						tmpRepoItem.isTrustCertificate = lastEvent.repository.isTrustCertificate;
						
						lastEvent.repository.children.push(tmpRepoItem);
					}
				}
				
				// notify to the caller
				if (onCompletion != null) 
				{
					onCompletion(lastEvent.repository, true);
					onCompletion = null;
				}
			}
		}
	}
}