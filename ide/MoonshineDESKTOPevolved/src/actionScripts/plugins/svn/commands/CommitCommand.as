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
	
	import __AS3__.vec.Vector;
	
	import actionScripts.events.AddTabEvent;
	import actionScripts.events.RefreshTreeEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugins.svn.provider.SVNStatus;
	import actionScripts.plugins.svn.view.CommitMessageEditor;
	import actionScripts.ui.tabview.CloseTabEvent;

	public class CommitCommand extends SVNCommandBase
	{
		protected var message:String;
		// Files we need to add before commiting
		protected var toAdd:Array;
		protected var affectedFiles:Vector.<SVNFileWrapper> = new Vector.<SVNFileWrapper>();
		
		public var status:Object;
		
		public function CommitCommand(executable:File, root:File, status:Object)
		{
			this.status = status;
			super(executable, root);
		}
		
		public function commit(file:File, message:String=null):void
		{	
			if (runningForFile)
			{
				error("Currently running, try again later.");
				return;
			}
			
			runningForFile = file;
			this.message = message;
			
			// Update status, in case files were added
			var statusCommand:UpdateStatusCommand = new UpdateStatusCommand(executable, root, status);
			statusCommand.addEventListener(Event.COMPLETE, handleCommitStatusUpdateComplete);
			statusCommand.addEventListener(Event.CANCEL, handleCommitStatusUpdateCancel);
			statusCommand.update(file);
			
			print("Updating status before commit");
		}
		
		protected function handleCommitStatusUpdateComplete(event:Event):void
		{
			// Ok, now we know the status is fresh.
			var topPath:String = runningForFile.nativePath;
			var topPathLength:int = topPath.length;
			for (var p:String in status)
			{
				// Is file below our target file?
				if (p.length >= topPathLength && p.substr(0, topPathLength) == topPath)
				{
					var st:SVNStatus = status[p];
					
					if (st.canBeCommited)
					{	
						var relativePath:String = p.substr(topPathLength);
						var w:SVNFileWrapper = new SVNFileWrapper(new File(p), st, relativePath);
						affectedFiles.push(w);
					}
				}
			}
			
			promptForCommitMessage();
		}
		
		protected function handleCommitStatusUpdateCancel(event:Event):void
		{
			error("Could update status, commit failed.");
		}
		
		protected function promptForCommitMessage():void
		{
			var editor:CommitMessageEditor = new CommitMessageEditor();
			editor.files = affectedFiles;
			dispatcher.dispatchEvent(
				new AddTabEvent(editor)
			);
			
			editor.addEventListener(CloseTabEvent.EVENT_TAB_CLOSED, handleCommitEditorClose);
		}
		
		
		protected function handleCommitEditorClose(event:CloseTabEvent):void
		{
			var editor:CommitMessageEditor = event.tab as CommitMessageEditor;
			if (editor.isSaved)
			{
				message = editor.text;
			}
			else
			{
				error("No commit message given, aborting.");
				return;
			}
			
			// We'll need to add some files
			toAdd = [];
			for each (var wrap:SVNFileWrapper in affectedFiles)
			{
				if (wrap.ignore) continue;
				
				if (wrap.status.status == "unversioned")
				{
					toAdd.push(wrap.file);	
				}
			}
			
			addFiles();
		}
		
		// Start adding files
		protected function addFiles(event:Event=null):void
		{
			if (toAdd.length == 0)
			{
				doCommit(runningForFile, message);
			}
			else
			{
				var file:File = toAdd.pop();
				var addCommand:AddCommand = new AddCommand(executable, root);
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
		
		protected function doCommit(file:File, message:String):void
		{	
			// TODO: Check for empty commits, since svn commit will recurse-commit everything
			customInfo = new NativeProcessStartupInfo();
			customInfo.executable = executable;
			
			var args:Vector.<String> = new Vector.<String>();
			
			args.push("commit");
			var argFiles:Vector.<String> = new Vector.<String>();
			for each (var wrap:SVNFileWrapper in affectedFiles)
			{
				if (!wrap.ignore)
				{
					var relPath:String = root.getRelativePath(wrap.file, false);
					// TODO: Handle this properly
					if (!relPath) continue;
					argFiles.push(relPath);
				}
			}
			
			if (argFiles.length == 0)
			{
				error("No files to commit.");
				return;
			}
			
			args = args.concat(argFiles);
			args.push("--message");
			args.push(message);
			
			customInfo.arguments = args;
			
			customInfo.workingDirectory = root;
			
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
			var statusCommand:UpdateStatusCommand = new UpdateStatusCommand(executable, root, status);
			statusCommand.update(root);
			
			// Show changes in project view
			dispatcher.dispatchEvent(
				new RefreshTreeEvent(new FileLocation(runningForFile.nativePath))
			);
			
			runningForFile = null;
			customProcess = null;
		}
		
	}
}