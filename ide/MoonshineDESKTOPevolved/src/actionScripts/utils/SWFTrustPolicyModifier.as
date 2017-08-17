////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc. 
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
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
				var file : File = File.applicationDirectory.resolvePath("appScripts/UpdaterSWFTrustContent.scpt");
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