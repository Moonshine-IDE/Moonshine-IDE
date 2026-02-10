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
    import flash.events.Event;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    
    import actionScripts.valueObjects.ConstantsCoreVO;
	
	public class InfoCommand extends SVNCommandBase
	{
		public var infoLines:Array;
		
		public function InfoCommand(executable:File, root:File)
		{
			super(executable, root);
		}
		
		// Modifies status object. obj[nativePath] = SVNStatus
		public function request(file:File, isTrustServerCertificateSVN:Boolean):void
		{
			if (runningForFile)
			{
				error("Currently running, try again later.");
				return;
			}
			
			infoLines = null;
			runningForFile = file;
			
			customInfo = new NativeProcessStartupInfo();
			customInfo.executable = executable;
			
			var args:Vector.<String> = new Vector.<String>();
			
			/*var target:String = file.getRelativePath(root, false);
			// If we're refreshing the root we give roots name
			if (!target) target = file.name; */
			args.push("info");
			/*args.push(file.name);*/
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
				infoLines = str.split(ConstantsCoreVO.IS_WINDOWS ? "\r\n" : "\n");

				dispatchEvent(new Event(Event.COMPLETE));
			}
			else
			{
				// Refresh failed
				var err:String = customProcess.standardError.readUTFBytes(customProcess.standardError.bytesAvailable);
				error(err);
				
				dispatchEvent(new Event(Event.CANCEL));
			}
			
			removeListeners();
		}
		
		protected function removeListeners():void
		{
			customProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, svnError);
			customProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, svnOutput);
			customProcess.removeEventListener(NativeProcessExitEvent.EXIT, svnExit);
			
			runningForFile = null;
			customProcess = null;
		}
	}
}