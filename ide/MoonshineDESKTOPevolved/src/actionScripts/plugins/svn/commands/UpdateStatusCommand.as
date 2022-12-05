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
    import actionScripts.utils.SerializeUtil;

    import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	
	import actionScripts.events.RefreshTreeEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugins.svn.provider.SVNStatus;
	
	public class UpdateStatusCommand extends SVNCommandBase
	{
		public var status:Object;
		
		public function UpdateStatusCommand(executable:File, root:File, status:Object)
		{
			this.status = status;
			super(executable, root);
		}
		
		// Modifies status object. obj[nativePath] = SVNStatus
		public function update(file:File, isTrustServerCertificateSVN:Boolean):void
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
			
			/*var target:String = file.getRelativePath(root, false);
			// If we're refreshing the root we give roots name
			if (!target) target = file.name; */
			args.push("status");
			/*args.push(file.name);*/
			args.push("--xml");
			args.push("--non-interactive");
			if (isTrustServerCertificateSVN) args.push("--trust-server-cert");
			
			customInfo.arguments = args;
			// We give the file as target, so go one directory up
			customInfo.workingDirectory = file;
			
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
				st.treeConflict = SerializeUtil.deserializeBoolean(entry.child('wc.status').attribute('tree-conflicted'));
				//st.date = DateUtil.parseBlaDate(entry..date);
				status[path] = st;
			}
		}
	}
}