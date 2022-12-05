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
package actionScripts.utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import org.as3commons.asblocks.utils.FileUtil;

	public class SWFTrustPolicyModifier
	{
		public static function checkPolicyFileExistence(): File
		{
			// @NOTE
			// We encountered strange path values by File.DocumentsDirectory API
			// Thus, we needs to do some added works here to get a proper physical documents path
			// from the API output
			var tmpUserFolderSplit: Array = File.userDirectory.nativePath.split(FileUtil.separator);
			if (tmpUserFolderSplit[1] == "Users")
			{
				tmpUserFolderSplit = tmpUserFolderSplit.slice(1, 3);
			}
			var trustFile: File = new File("/" + tmpUserFolderSplit.join(FileUtil.separator) + "/Library/Preferences/Macromedia/Flash Player/#Security/FlashPlayerTrust"); 
			if (trustFile.exists)
			{
				trustFile = new File("/" + tmpUserFolderSplit.join(FileUtil.separator) + "/Library/Preferences/Macromedia/Flash Player/#Security/FlashPlayerTrust/moonshine.cfg");
				if (!trustFile.exists) generateTrustFile();
			}
			else
			{
				trustFile = File.userDirectory.resolvePath("Library/Application Support/Macromedia/FlashPlayerTrust");
				if (trustFile.exists) 
				{
					trustFile = File.userDirectory.resolvePath("Library/Application Support/Macromedia/FlashPlayerTrust/moonshine.cfg");
					if (!trustFile.exists) generateTrustFile();
				}
			}
			
			return trustFile;
			
			/*
			 * @local
			 */
			function generateTrustFile():void
			{
				var fs: FileStream = new FileStream();
				fs.openAsync(trustFile, FileMode.WRITE);
				fs.writeUTFBytes("");
				fs.close();
			}
		}

		public static function updatePolicyFile(value:String):void
		{
			/**
			 * For AppleScript
			 */
			/*var trustFile: File = checkPolicyFileExistence();
			if (trustFile.exists)
			{
				var file : File = File.applicationDirectory.resolvePath("macOScripts/UpdaterSWFTrustContent.scpt");
				var npInfo : NativeProcessStartupInfo = new NativeProcessStartupInfo();
				var arg:Vector.<String>;
				
				npInfo.executable = File.documentsDirectory.resolvePath("/usr/bin/osascript");
				arg = new Vector.<String>();
				arg.push(file.nativePath);
				arg.push(value);
			
				npInfo.arguments = arg;
				var process:NativeProcess = new NativeProcess();
				process.start( npInfo );
			}*/
			
			/**
			 * For File API
			 */
			var trustFile: File = checkPolicyFileExistence();
			if (trustFile && trustFile.exists)
			{
				var fs: FileStream = new FileStream();
				fs.open(trustFile, FileMode.READ);
				var paths: Array = String(fs.readUTFBytes(trustFile.size)).split("\n");
				fs.close();
				
				if (paths.indexOf(value) == -1) 
				{
					paths.push(value);
					fs = new FileStream();
					fs.open(trustFile, FileMode.APPEND);
					fs.writeUTFBytes("\n"+ value);
					fs.close()
				}
			}
		}
	}
}