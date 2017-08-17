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
	import actionScripts.factory.FileLocation;
	import actionScripts.plugins.svn.provider.SVNStatus;
	import actionScripts.utils.UtilsCore;
	
	public class UpdateStatusCommand extends SVNCommandBase
	{
		public var status:Object;
		
		public function UpdateStatusCommand(executable:File, root:File, status:Object)
		{
			this.status = status;
			super(executable, root);
		}
		
		// Modifies status object. obj[nativePath] = SVNStatus
		public function update(file:File):void
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
			args.push("status");
			args.push(target);
			args.push("--xml");
			
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
				// Refresh succeded
				var str:String = customProcess.standardOutput.readUTFBytes(customProcess.standardOutput.bytesAvailable);
				var data:XML = new XML(str);

				parseStatusXML(data);
				
				// Show changes in project view
				dispatcher.dispatchEvent(
					new RefreshTreeEvent(new FileLocation(runningForFile.nativePath))
				);
				
				dispatchEvent(new Event(Event.COMPLETE));
			}
			else
			{
				// Refresh failed
				var err:String = customProcess.standardError.readUTFBytes(customProcess.standardError.bytesAvailable);
				error(err);
				
				dispatchEvent(new Event(Event.CANCEL));
			}
			
			runningForFile = null;
			customProcess = null;
		}
		
		protected function parseStatusXML(data:XML):void
		{
			// Remove status for files under given file/directory
			//  in case they are now versioned we don't want to display old data
			var topPath:String = runningForFile.nativePath;
			var topPathLength:int = topPath.length;

			for (var p:String in status)
			{
				if (p.length > topPathLength && p.substr(0, topPathLength) == topPath)
				{
					delete status[p];	
				}
			}
			
			var path:String;
			var pathParts:Array;
			var st:SVNStatus;
			var folderPath:String = runningForFile.parent.nativePath + File.separator;
			for each (var entry:XML in data.target.entry)
			{
				path = entry.@path;
				// Add status for the path
				pathParts = path.split(File.separator);
				// Loop the path parts, skip the last one since it'll have a proper status
				// SVN only idicates which items that changed, 
				// 	 we want to display something for all directories leading up to each item
				var pathTrail:String = "";
				for (var i:int = 0; i < pathParts.length-1; i++)
				{
					pathTrail += pathParts[i];
					st = new SVNStatus();
					st.status = "childChanged";
					status[folderPath + pathTrail] = st;
					pathTrail += File.separator;
				}
				
				// Add status for the file
				st = new SVNStatus();
				st.status = entry.child('wc-status').@item.toString();
				st.revision = parseInt(entry.child('wc-status').@revision);
				st.author = entry..author;
				st.treeConflict = UtilsCore.deserializeBoolean(entry.child('wc.status').attribute('tree-conflicted'));
				//st.date = DateUtil.parseBlaDate(entry..date);
				status[folderPath + path] = st;
			}
		}
		
	}
}