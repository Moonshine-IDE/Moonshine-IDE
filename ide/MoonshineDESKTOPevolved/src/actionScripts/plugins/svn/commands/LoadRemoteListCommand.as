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
package actionScripts.plugins.svn.commands
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	
	import actionScripts.events.StatusBarEvent;
	import actionScripts.plugins.svn.event.SVNEvent;
	import actionScripts.plugins.versionControl.VersionControlUtils;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.RepositoryItemVO;
	import actionScripts.valueObjects.VersionControlTypes;
	
	public class LoadRemoteListCommand extends SVNCommandBase
	{
		private var cmdFile:File;
		private var isEventReported:Boolean;
		private var remoteOutput:String;
		private var onCompletion:Function;
		
		public function LoadRemoteListCommand(executable:File, root:File)
		{
			super(executable, root);
		}
		
		public function loadList(repository:RepositoryItemVO, completion:Function, userName:String=null, userPassword:String=null):void
		{
			onCompletion = null;
			remoteOutput = null;
			
			onCompletion = completion;
			this.repositoryItem = repository;
			this.isTrustServerCertificateSVN = this.repositoryItem.isTrustCertificate;
			notice("Remote data requested. This may take a while.", this.repositoryItem.url);
			
			isEventReported = false;
			customInfo = new NativeProcessStartupInfo();
			customInfo.executable = executable;
			
			var args:Vector.<String> = new Vector.<String>();
			var username:String;
			var password:String;
			args.push("ls");
			args.push("--depth");
			args.push("immediates");
			if (this.repositoryItem && this.repositoryItem.userName && this.repositoryItem.userPassword)
			{
				username = this.repositoryItem.userName;
				password = this.repositoryItem.userPassword;
			}
			else if (userName && userPassword)
			{
				username = userName;
				password = userPassword;
			}
			if (username != null && password != null)
			{
				args.push("--username");
				args.push(username);
				args.push("--password");
				args.push(password);
			}
			args.push(this.repositoryItem.url);
			args.push("--non-interactive");
			if (this.isTrustServerCertificateSVN) args.push("--trust-server-cert");
			
			customInfo.arguments = args;
			
			startShell(true);
			customProcess.start(customInfo);
		}
		
		override protected function onCancelAuthentication():void
		{
			// notify to the caller
			if (onCompletion != null) 
			{
				onCompletion(this.repositoryItem, false);
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
			var isAuthError:Boolean;
			
			/*var match:Array = data.toLowerCase().match(/error validating server certificate for/);
			if (!match) match = data.toLowerCase().match(/issuer is not trusted/);
			if (match) 
			{
				//serverCertificatePrompt(data);
			}*/
			
			error("%s", data);
			startShell(false);
			
			if (VersionControlUtils.hasAuthenticationFailError(data))
			{
				askOrReconnectWithAuthentication();
				isAuthError = true;
			}
	
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
			dispatcher.dispatchEvent(new SVNEvent(SVNEvent.SVN_ERROR, null));
			if (!isAuthError) onCancelAuthentication();
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
							tmpRepoItem.url = this.repositoryItem.url +"/"+ line;
						}
						
						tmpRepoItem.label = line;
						
						// we also want to keep few information from
						// top level for later retreival
						tmpRepoItem.isRequireAuthentication = this.repositoryItem.isRequireAuthentication;
						tmpRepoItem.isTrustCertificate = this.repositoryItem.isTrustCertificate;
						tmpRepoItem.udid = this.repositoryItem.udid;
						tmpRepoItem.type = VersionControlTypes.SVN;
						
						this.repositoryItem.children.push(tmpRepoItem);
					}
				}
			}
			
			// notify to the caller
			if (onCompletion != null) 
			{
				onCompletion(this.repositoryItem, true);
				onCompletion = null;
			}
		}
		
		private function askOrReconnectWithAuthentication():void
		{
			var tmpTopLevel:RepositoryItemVO = VersionControlUtils.getRepositoryItemByUdid(this.repositoryItem.udid);
			if (tmpTopLevel && tmpTopLevel.userName && tmpTopLevel.userPassword)
			{
				// in case user choose to save auth for the Moonshine session
				onAuthenticationSuccess(tmpTopLevel.userName, tmpTopLevel.userPassword);
			}
			else
			{
				// in case we requires to prompt to auth
				openAuthentication();
			}
		}
		
		override protected function onAuthenticationSuccess(username:String, password:String):void
		{
			this.loadList(this.repositoryItem, onCompletion, username, password);
			notice("Trying to authenticate with temporary saved information");
		}
	}
}