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
package actionScripts.plugins.vagrant.utils
{
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.utils.FileUtils;
	import actionScripts.utils.UtilsCore;

	import flash.desktop.NativeProcess;

	import flash.desktop.NativeProcessStartupInfo;

	import flash.filesystem.File;

	public class VagrantUtil
	{
		public static const VAGRANT_UP:String = "Up";
		public static const VAGRANT_HALT:String = "Halt";
		public static const VAGRANT_RELOAD:String = "Reload (to sync files)";
		public static const VAGRANT_SSH:String = "SSH";
		public static const VAGRANT_DESTROY:String = "Destroy";
		public static const VAGRANT_MENU_OPTIONS:Array = [VAGRANT_UP, VAGRANT_HALT, VAGRANT_RELOAD, VAGRANT_SSH, VAGRANT_DESTROY];

		public static const AS_VAGRANT_SSH: XML = <root><![CDATA[
			#!/bin/bash
			on run argv
				set userVagrantFilePath to (item 1 of argv) as string
				set vagrantExecutablePath to (item 2 of argv) as string
				set userVagrantFilePath to replace_chars(userVagrantFilePath, " ", "\\ ")
				set vagrantExecutablePath to replace_chars(vagrantExecutablePath, " ", "\\ ")

				tell application "Terminal"

					do script "clear"
					activate
					set currentTab to (selected tab of (get first window))
					set tabProcs to processes of currentTab
					set theProc to (end of tabProcs)
					do script "cd " & userVagrantFilePath in currentTab
					do script "clear" in currentTab
					do script vagrantExecutablePath & " ssh" in currentTab

				end tell
			end run
			on replace_chars(this_text, search_string, replacement_string)
				set AppleScript's text item delimiters to the search_string
				set the item_list to every text item of this_text
				set AppleScript's text item delimiters to the replacement_string
				set this_text to the item_list as string
				set AppleScript's text item delimiters to ""
				return this_text
			end replace_chars]]></root>

		private static const SSH_FILE_LOCATION:String = "vagrant/vagrang_ssh.scpt";

		private static var sshAt:String;

		public static function runVagrantSSHAt(path:String):void
		{
			sshAt = path;
			var destinationFile:File = File.applicationStorageDirectory.resolvePath(SSH_FILE_LOCATION);
			FileUtils.writeToFileAsync(destinationFile, AS_VAGRANT_SSH.valueOf().toString(), onVagrantSSHFileWriteCompletes, onVagrantSSHFileWriteFail);
		}

		private static function onVagrantSSHFileWriteCompletes():void
		{
			// declare necessary arguments
			var npInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			var arg:Vector.<String>;

			npInfo.executable = File.documentsDirectory.resolvePath("/usr/bin/osascript");
			arg = new Vector.<String>();
			arg.push(File.applicationStorageDirectory.resolvePath(SSH_FILE_LOCATION).nativePath);
			arg.push(sshAt);
			arg.push(UtilsCore.getVagrantBinPath());

			// triggers the process
			npInfo.arguments = arg;
			var process:NativeProcess = new NativeProcess();
			process.start(npInfo);
		}

		private static function onVagrantSSHFileWriteFail(value:String):void
		{
			GlobalEventDispatcher.getInstance().dispatchEvent(
					new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, value, false, false, ConsoleOutputEvent.TYPE_ERROR)
			);
		}
	}
}