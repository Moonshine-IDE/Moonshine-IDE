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
	
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.plugins.svn.event.SVNEvent;
	import actionScripts.plugins.versionControl.VersionControlUtils;
	import actionScripts.plugins.versionControl.event.VersionControlEvent;
	import actionScripts.valueObjects.RepositoryItemVO;
	import actionScripts.valueObjects.VersionControlTypes;
	
	public class CheckoutCommand extends SVNCommandBase
	{
		private var cmdFile:File;
		private var isEventReported:Boolean;
		private var url:String;
		private var targetFolder:String;
		
		public function CheckoutCommand(executable:File, root:File)
		{
			super(executable, root);
			//cmdFile = new File("c:\\Windows\\System32\\cmd.exe");
		}
		// url, folder, user, password, istrust
		public function checkout(url:String, rootDirectory:File, targetFolder:String, isTrustServerCertificateSVN:Boolean, repository:RepositoryItemVO, userName:String=null, userPassword:String=null):void
		{
			this.repositoryItem = repository;
			this.root = rootDirectory;
			this.url = url;
			this.targetFolder = targetFolder;
			this.isTrustServerCertificateSVN = isTrustServerCertificateSVN;
			notice("Trying to check out %s. May take a while.", url);
			
			isEventReported = false;
			customInfo = new NativeProcessStartupInfo();
			customInfo.executable = executable;
			//customInfo.executable = cmdFile; 
			
			// http://stackoverflow.com/questions/1625406/using-tortoisesvn-via-the-command-line
			var args:Vector.<String> = new Vector.<String>();
			var username:String;
			var password:String;
			args.push("checkout");
			if (repositoryItem && repositoryItem.userName && repositoryItem.userPassword)
			{
				username = repositoryItem.userName;
				password = repositoryItem.userPassword;
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
			args.push(url);
			args.push(targetFolder);
			args.push("--non-interactive");
			if (isTrustServerCertificateSVN) args.push("--trust-server-cert");
			
			customInfo.arguments = args;
			customInfo.workingDirectory = this.root;
			
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
				runningForFile = null;
			}
		}
		
		protected function svnError(event:ProgressEvent):void
		{
			var output:IDataInput = customProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			
			var match:Array = data.toLowerCase().match(/Error validating server certificate for/);
			if (match) 
			{
				//serverCertificatePrompt(data);
				//return;
			}
			
			if (VersionControlUtils.hasAuthenticationFailError(data))
			{
				openAuthentication();
			}
			else
			{
				dispatcher.dispatchEvent(new VersionControlEvent(VersionControlEvent.CLONE_CHECKOUT_COMPLETED, {hasError:true, message:data}));
			}
	
			error("%s", data);
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
			dispatcher.dispatchEvent(new SVNEvent(SVNEvent.SVN_ERROR, null));
			startShell(false);
		}
		
		override protected function onAuthenticationSuccess(username:String, password:String):void
		{
			this.checkout(this.url, this.root, this.targetFolder, this.isTrustServerCertificateSVN, this.repositoryItem, username, password);
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
			
			notice("%s", data);
		}
		
		protected function svnExit(event:NativeProcessExitEvent):void
		{
			if (event.exitCode == 0)
			{
				var tmpPath:File = new File(this.root.nativePath + File.separator + targetFolder);
				
				// following method is mainly applicable for git-meta type of repository
				VersionControlUtils.parseRepositoryDependencies(repositoryItem, tmpPath);
				dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.SEARCH_PROJECTS_IN_DIRECTORIES, tmpPath));
				dispatcher.dispatchEvent(new VersionControlEvent(VersionControlEvent.CLONE_CHECKOUT_COMPLETED, {hasError:false, message:null}));
				/*var p:ProjectVO = new ProjectVO(new FileLocation(runningForFile.nativePath));
				dispatcher.dispatchEvent(
					new ProjectEvent(ProjectEvent.ADD_PROJECT, p)
				);*/
			}
			else
			{
				// Checkout failed
			}
			
			/*runningForFile = null;
			customProcess = null;*/
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
			startShell(false);
		}
	}
}