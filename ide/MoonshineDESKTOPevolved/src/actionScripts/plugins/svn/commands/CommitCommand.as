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
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import __AS3__.vec.Vector;
	
	import actionScripts.events.StatusBarEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugins.git.GitProcessManager;
	import actionScripts.plugins.svn.provider.SVNStatus;
	import actionScripts.plugins.versionControl.VersionControlUtils;
	import actionScripts.valueObjects.GenericSelectableObject;
	import actionScripts.valueObjects.VersionControlTypes;
	
	import components.popup.GitCommitSelectionPopup;

	public class CommitCommand extends SVNCommandBase
	{
		protected var message:String;
		// Files we need to add before commiting
		protected var toAdd:Array;
		protected var affectedFiles:ArrayCollection;
		
		public var status:Object;
		
		private var svnCommitWindow:GitCommitSelectionPopup;
		private var commitInfo:Object;
		
		public function CommitCommand(executable:File, root:File, status:Object)
		{
			this.status = status;
			super(executable, root);
		}
		
		public function commit(file:FileLocation, message:String=null, user:String=null, password:String=null, commitInfo:Object=null, isTrustServerCertificateSVN:Boolean=false, repositoryItem:RepositoryItemVO=null):void
		{
			this.root = file.fileBridge.getFile as File;
			this.isTrustServerCertificateSVN = isTrustServerCertificateSVN;
			this.commitInfo = commitInfo;
			this.message = message;
			this.repositoryItem = repositoryItem;
			
			if (user && password)
			{
				doCommit(user, password, commitInfo);
				return;
			}
			
			// Update status, in case files were added
			var statusCommand:UpdateStatusCommand = new UpdateStatusCommand(executable, root, status);
			statusCommand.addEventListener(Event.COMPLETE, handleCommitStatusUpdateComplete);
			statusCommand.addEventListener(Event.CANCEL, handleCommitStatusUpdateCancel);
			statusCommand.update(this.root, this.isTrustServerCertificateSVN);
			
			print("Updating status before commit");
		}
		
		protected function handleCommitStatusUpdateComplete(event:Event):void
		{
			// Ok, now we know the status is fresh.
			var topPath:String = this.root.nativePath;
			var topPathLength:int = topPath.length;
			affectedFiles = new ArrayCollection();
			for (var p:String in status)
			{
				var st:SVNStatus = status[p];
				
				if (st.canBeCommited)
				{	
					var relativePath:String = p.substr(topPathLength+1);
					affectedFiles.addItem(new GenericSelectableObject(false, {path: p, status:getFileStatus(st)}));
					//var w:SVNFileWrapper = new SVNFileWrapper(new File(p), st, relativePath);
					//affectedFiles.push(w);
				}
			}
			
			promptForCommitMessage();
			
			/*
			* @local
			*/
			function getFileStatus(value:SVNStatus):String
			{
				if (value.status == "deleted") return GitProcessManager.GIT_STATUS_FILE_DELETED;
				else if (value.status == "unversioned") return GitProcessManager.GIT_STATUS_FILE_NEW;
				return GitProcessManager.GIT_STATUS_FILE_MODIFIED;
			}
		}
		
		protected function handleCommitStatusUpdateCancel(event:Event):void
		{
			error("Could update status, commit failed.");
		}
		
		protected function promptForCommitMessage():void
		{
			if (!svnCommitWindow)
			{
				svnCommitWindow = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, GitCommitSelectionPopup, false) as GitCommitSelectionPopup;
				svnCommitWindow.title = "Commit";
				svnCommitWindow.commitDiffCollection = affectedFiles;
				svnCommitWindow.windowType = VersionControlTypes.SVN;
				svnCommitWindow.addEventListener(CloseEvent.CLOSE, onSVNCommitWindowClosed);
				PopUpManager.centerPopUp(svnCommitWindow);
				svnCommitWindow.isReadyToUse = true;
			}
			else
			{
				PopUpManager.bringToFront(svnCommitWindow);
			}
		}
		
		private function onSVNCommitWindowClosed(event:CloseEvent):void
		{
			if (svnCommitWindow.isSubmit) 
			{
				this.message = svnCommitWindow.commitMessage;
				
				// get repository infor to check authentication (if requires
				// and if exists) from repositoryItemVo
				this.getRepositoryInfo();
			}
			
			svnCommitWindow.removeEventListener(CloseEvent.CLOSE, onSVNCommitWindowClosed);
			PopUpManager.removePopUp(svnCommitWindow);
			svnCommitWindow = null;
		}
		
		override protected function handleInfoUpdateComplete(event:Event):void
		{
			super.handleInfoUpdateComplete(event);
			if (this.repositoryItem) this.isTrustServerCertificateSVN = this.repositoryItem.isTrustCertificate;
			initiateProcess();
		}
		
		private function releaseListenersFromInfoCommand(event:Event):void
		{
			event.target.removeEventListener(Event.COMPLETE, handleInfoUpdateComplete);
			event.target.removeEventListener(Event.CANCEL, handleInfoUpdateCancel);
		}
		
		protected function initiateProcess():void
		{
			// We'll need to add some files
			toAdd = [];
			for each (var wrap:GenericSelectableObject in affectedFiles)
			{
				if (wrap.isSelected && wrap.data.status == GitProcessManager.GIT_STATUS_FILE_NEW)
				{
					toAdd.push(wrap.data.path);	
				}
			}
			
			addFiles();
		}
		
		// Start adding files
		protected function addFiles(event:Event=null):void
		{
			if (toAdd.length == 0)
			{
				if (repositoryItem && repositoryItem.userName && repositoryItem.userPassword)
				{
					doCommit(repositoryItem.userName, repositoryItem.userPassword, this.commitInfo);
				}
				else
				{
					doCommit(null, null, this.commitInfo);
				}
			}
			else
			{
				var file:String = toAdd.pop();
				var addCommand:AddCommand = new AddCommand(executable, this.root);
				addCommand.addEventListener(Event.COMPLETE, addFiles);
				addCommand.addEventListener(Event.CANCEL, addFilesCancel);
				addCommand.add(file);
			}
		}
		
		protected function addFilesCancel(event:Event):void
		{
			error("Couldn't add file, commit failed.");
			toAdd = null;
		}
		
		protected function doCommit(user:String=null, password:String=null, commitInfo:Object=null):void
		{	
			// TODO: Check for empty commits, since svn commit will recurse-commit everything
			if (commitInfo)
			{
				affectedFiles ||= commitInfo.files;
				this.message ||= commitInfo.message;
				this.root ||= commitInfo.runningForFile;
			}

			customInfo = new NativeProcessStartupInfo();
			customInfo.executable = executable;
			
			var args:Vector.<String> = new Vector.<String>();
			
			args.push("commit");
			var argFiles:Vector.<String> = new Vector.<String>();
			for each (var wrap:GenericSelectableObject in affectedFiles)
			{
				if (wrap.isSelected)
				{
					argFiles.push(wrap.data.path);
				}
			}
			
			if (argFiles.length == 0)
			{
				error("No files to commit.");
				return;
			}
			
			args = args.concat(argFiles);
			args.push("--message");
			args.push(this.message);
			if (repositoryItem && repositoryItem.userName && repositoryItem.userPassword)
			{
				args.push("--username");
				args.push(repositoryItem.userName);
				args.push("--password");
				args.push(repositoryItem.userPassword);
			}
			else if (user && password)
			{
				args.push("--username");
				args.push(user);
				args.push("--password");
				args.push(password);
			}
			args.push("--non-interactive");
			if (isTrustServerCertificateSVN) args.push("--trust-server-cert");
			
			customInfo.arguments = args;
			
			customInfo.workingDirectory = this.root;
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Requested", "SVN Process ", false));
			
			startShell(true);
			customProcess.start(customInfo);
			
			print("Starting commit");
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
			var output:IDataInput = customProcess.standardOutput;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			
			if (data == ".") return;
			notice("%s", data);
		}
		
		protected function svnExit(event:NativeProcessExitEvent):void
		{
			if (event.exitCode == 0)
			{
				// Success
			}
			else
			{
				// Commit failed
				var err:String = customProcess.standardError.readUTFBytes(customProcess.standardError.bytesAvailable);
				if (VersionControlUtils.hasAuthenticationFailError(err))
				{
					openAuthentication();
				}
				else error(err);
			}
			
			// Update status (don't care if it fails or not, just try it)
			/*var statusCommand:UpdateStatusCommand = new UpdateStatusCommand(executable, runningForFile, status);
			statusCommand.update(runningForFile);
			
			// Show changes in project view
			dispatcher.dispatchEvent(
				new RefreshTreeEvent(new FileLocation(runningForFile.nativePath))
			);*/
			
			startShell(false);
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
		}
		
		override protected function onAuthenticationSuccess(username:String, password:String):void
		{
			this.doCommit(username, password, this.commitInfo);
		}
	}
}