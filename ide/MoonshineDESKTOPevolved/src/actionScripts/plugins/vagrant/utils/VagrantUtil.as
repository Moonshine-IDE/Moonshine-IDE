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
	import actionScripts.plugins.vagrant.vo.VagrantInstanceState;
	import actionScripts.plugins.vagrant.vo.VagrantInstanceVO;
	import actionScripts.utils.FileUtils;
	import actionScripts.utils.SharedObjectConst;
	import actionScripts.utils.UtilsCore;

	import flash.desktop.NativeProcess;

	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;

	import flash.filesystem.File;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	import mx.collections.ArrayCollection;

	public class VagrantUtil extends EventDispatcher
	{
		public static const EVENT_INSTANCE_STATE_CHECK_COMPLETES:String = "eventInstanceStateCheckCompletes";

		public static const VAGRANT_UP:String = "Up";
		public static const VAGRANT_HALT:String = "Halt";
		public static const VAGRANT_RELOAD:String = "Reload (to sync files)";
		public static const VAGRANT_SSH:String = "SSH";
		public static const VAGRANT_DESTROY:String = "Destroy";
		public static const VAGRANT_MENU_OPTIONS:Array = [VAGRANT_UP, VAGRANT_HALT, VAGRANT_RELOAD, VAGRANT_SSH, VAGRANT_DESTROY];

		private static const instanceStateCheckLoaders:Dictionary = new Dictionary();
		private static const dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();

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

		public static function getVagrantInstances():ArrayCollection
		{
			var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);
			var instances:ArrayCollection = new ArrayCollection();
			if (cookie.data.hasOwnProperty('vagrantInstances'))
			{
				var storedInstances:Array = cookie.data.vagrantInstances;
				for each (var instance:Object in storedInstances)
				{
					instances.addItem(
							VagrantInstanceVO.getNewInstance(instance)
					);
				}
			}

			return instances;
		}

		public static function saveVagrantInstances(value:ArrayCollection):void
		{
			var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);
			cookie.data['vagrantInstances'] = value.source;
			cookie.flush();
		}

		public static function checkStates(value:ArrayCollection):void
		{
			for each (var instance:VagrantInstanceVO in value)
			{
				var request:URLRequest = new URLRequest();
				request.url = instance.url +"/info";
				request.method = "GET";

				var loader:URLLoader = new URLLoader();
				loader.addEventListener(Event.COMPLETE, onStateCheckSuccess);
				loader.addEventListener(IOErrorEvent.IO_ERROR, onStateCheckIOError);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onStateCheckSecurityError);
				instanceStateCheckLoaders[loader] = instance;

				loader.load( request );
			}
		}
		
		private static function releaseLoaderListeners(loader:URLLoader):void
		{
			loader.removeEventListener(Event.COMPLETE, onStateCheckSuccess);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onStateCheckIOError);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onStateCheckSecurityError);
		}

		private static function onStateCheckSuccess(event:Event):void
		{
			var infoObject:Object = JSON.parse(event.target.data.toString());
			var instance:VagrantInstanceVO = instanceStateCheckLoaders[event.target];
			instance.state = ("status" in infoObject) ? infoObject["status"] : VagrantInstanceState.UNREACHABLE;
			instance.capabilities = ("capabilities" in infoObject) ? (infoObject["capabilities"] as Array) : [];

			releaseLoaderListeners(event.target as URLLoader);
			delete instanceStateCheckLoaders[event.target];
			dispatcher.dispatchEvent(new Event(EVENT_INSTANCE_STATE_CHECK_COMPLETES));
		}

		private static function onStateCheckIOError(event:IOErrorEvent):void
		{
			dispatcher.dispatchEvent(
					new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, "Unable to check status: "+ event.text, false, false, ConsoleOutputEvent.TYPE_ERROR)
			);

			var instance:VagrantInstanceVO = instanceStateCheckLoaders[event.target];
			instance.state = VagrantInstanceState.UNREACHABLE;
			instance.capabilities = [];

			releaseLoaderListeners(event.target as URLLoader);
			delete instanceStateCheckLoaders[event.target];
			dispatcher.dispatchEvent(new Event(EVENT_INSTANCE_STATE_CHECK_COMPLETES));
		}

		private static function onStateCheckSecurityError(event:SecurityErrorEvent):void
		{
			dispatcher.dispatchEvent(
					new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, "Unable to check status: "+ event.text, false, false, ConsoleOutputEvent.TYPE_ERROR)
			);

			var instance:VagrantInstanceVO = instanceStateCheckLoaders[event.target];
			instance.state = VagrantInstanceState.UNREACHABLE;
			instance.capabilities = [];

			releaseLoaderListeners(event.target as URLLoader);
			delete instanceStateCheckLoaders[event.target];
			dispatcher.dispatchEvent(new Event(EVENT_INSTANCE_STATE_CHECK_COMPLETES));
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
			dispatcher.dispatchEvent(
					new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, value, false, false, ConsoleOutputEvent.TYPE_ERROR)
			);
		}
	}
}