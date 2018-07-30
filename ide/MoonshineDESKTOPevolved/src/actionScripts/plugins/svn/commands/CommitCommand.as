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
	
	import actionScripts.events.RefreshTreeEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugins.git.GitProcessManager;
	import actionScripts.plugins.svn.provider.SVNStatus;
	import actionScripts.valueObjects.GenericSelectableObject;
	
	import components.popup.GitCommitSelectionPopup;

	public class CommitCommand extends SVNCommandBase
	{
		protected var message:String;
		// Files we need to add before commiting
		protected var toAdd:Array;
		protected var affectedFiles:ArrayCollection;
		
		public var status:Object;
		
		private var svnCommitWindow:GitCommitSelectionPopup;
		
		public function CommitCommand(executable:File, root:File, status:Object)
		{
			this.status = status;
			super(executable, root);
		}
		
		public function commit(file:FileLocation, message:String=null):void
		{	
			if (runningForFile)
			{
				error("Currently running, try again later.");
				return;
			}
			
			runningForFile = file.fileBridge.getFile as File;
			this.message = message;
			
			// Update status, in case files were added
			var statusCommand:UpdateStatusCommand = new UpdateStatusCommand(executable, root, status);
			statusCommand.addEventListener(Event.COMPLETE, handleCommitStatusUpdateComplete);
			statusCommand.addEventListener(Event.CANCEL, handleCommitStatusUpdateCancel);
			statusCommand.update(file.fileBridge.getFile as File);
			
			print("Updating status before commit");
		}
		
		protected function handleCommitStatusUpdateComplete(event:Event):void
		{
			// Ok, now we know the status is fresh.
			var topPath:String = runningForFile.nativePath;
			var topPathLength:int = topPath.length;
			affectedFiles = new ArrayCollection();
			for (var p:String in status)
			{
				// Is file below our target file?
				if (p.length >= topPathLength && p.substr(0, topPathLength) == topPath)
				{
					var st:SVNStatus = status[p];
					
					if (st.canBeCommited)
					{	
						var relativePath:String = p.substr(topPathLength+1);
						affectedFiles.addItem(new GenericSelectableObject(false, {path: relativePath, status:getFileStatus(st)}));
						//var w:SVNFileWrapper = new SVNFileWrapper(new File(p), st, relativePath);
						//affectedFiles.push(w);
					}
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
				svnCommitWindow.windowType = GitCommitSelectionPopup.TYPE_SVN;
				svnCommitWindow.addEventListener(CloseEvent.CLOSE, onSVNCommitWindowClosed);
				PopUpManager.centerPopUp(svnCommitWindow);
			}
			else
			{
				PopUpManager.bringToFront(svnCommitWindow);
			}
			
			/*var editor:CommitMessageEditor = new CommitMessageEditor();
			//editor.files = affectedFiles;
			dispatcher.dispatchEvent(
				new AddTabEvent(editor)
			);*/
			
			//editor.addEventListener(CloseTabEvent.EVENT_TAB_CLOSED, handleCommitEditorClose);
		}
		
		private function onSVNCommitWindowClosed(event:CloseEvent):void
		{
			if (svnCommitWindow.isSubmit) 
			{
				this.message = svnCommitWindow.commitMessage;
				initiateProcess();
			}
			
			svnCommitWindow.removeEventListener(CloseEvent.CLOSE, onSVNCommitWindowClosed);
			PopUpManager.removePopUp(svnCommitWindow);
			svnCommitWindow = null;
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
				doCommit();
			}
			else
			{
				var file:String = toAdd.pop();
				var addCommand:AddCommand = new AddCommand(executable, runningForFile);
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
		
		protected function doCommit():void
		{	
			// TODO: Check for empty commits, since svn commit will recurse-commit everything
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
			
			customInfo.arguments = args;
			
			customInfo.workingDirectory = runningForFile;
			
			customProcess = new NativeProcess();
			customProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, svnError);
			customProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, svnOutput);
			customProcess.addEventListener(NativeProcessExitEvent.EXIT, svnExit);
			customProcess.start(customInfo);
			
			print("Starting commit");
		}
		
		protected function svnError(event:ProgressEvent):void
		{
			
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
				error(err);
			}
			
			// Update status (don't care if it fails or not, just try it)
			var statusCommand:UpdateStatusCommand = new UpdateStatusCommand(executable, runningForFile, status);
			statusCommand.update(runningForFile);
			
			// Show changes in project view
			dispatcher.dispatchEvent(
				new RefreshTreeEvent(new FileLocation(runningForFile.nativePath))
			);
			
			runningForFile = null;
			customProcess = null;
		}
		
	}
}