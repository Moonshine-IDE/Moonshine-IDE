////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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
	import actionScripts.valueObjects.RepositoryItemVO;

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
		
		public function update(file:File, user:String=null, password:String=null, isTrustServerCertificateSVN:Boolean=false, repositoryItem:RepositoryItemVO=null):void
		{
			if (customProcess && customProcess.running)
			{
				return;
			}

			this.repositoryItem = repositoryItem;
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
		
		private function doUpdate(user:String=null, password:String=null, repository:RepositoryItemVO=null):void
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
			else if (repositoryItem && repositoryItem.userName && repositoryItem.userPassword)
			{
				args.push("--username");
				args.push(repositoryItem.userName);
				args.push("--password");
				args.push(repositoryItem.userPassword);
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
				
				checkCurrentEditorForModification();
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