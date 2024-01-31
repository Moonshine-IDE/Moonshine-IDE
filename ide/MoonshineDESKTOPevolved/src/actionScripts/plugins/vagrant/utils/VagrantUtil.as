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
	import actionScripts.valueObjects.ConstantsCoreVO;

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
		private static const macSHIConfigLocation:Array = [
				File.userDirectory.resolvePath("Library/Application Support/SuperHumanInstaller/.shi-config"),
				File.userDirectory.resolvePath("Library/Application Support/SuperHumanInstallerDev/.shi-config")
			];
		private static const winSHIConfigLocation:Array = [
				File.userDirectory.resolvePath("AppData/Roaming/SuperHumanInstaller/.shi-config"),
				File.userDirectory.resolvePath("AppData/Roaming/SuperHumanInstallerDev/.shi-config")
			];

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
			
			// parse from super.human.installer created instances
			getVagrantInstancesFromSHI(instances);
			
			return instances;
		}
		
		public static function getVagrantInstancesFromSHI(instances:ArrayCollection):Array
		{
			var shiInstances:Array = [];
			var locations:Array = ConstantsCoreVO.IS_MACOS ? macSHIConfigLocation : winSHIConfigLocation;
			
			for each (var filePath:File in locations)
			{
				if (filePath.exists)
				{
					var readString:String = FileUtils.readFromFile(filePath) as String;
					var readObject:Object = JSON.parse(readString);
					var vagrantInstance:VagrantInstanceVO;
					for (var i:int=0; i < readObject.servers.length; i++)
					{
						var isNameExists:Boolean = false;
						var server:Object = readObject.servers[i];
						var vagrantServer:Object = { serverType: server.type };
						var serverHostname:String = server.server_hostname;
						if ((server.server_hostname.indexOf(".") == -1))
						{
							serverHostname = server.server_hostname + "."+ server.server_organization +".com";
						}

						vagrantServer = {
							hostname: serverHostname,
							serverType: server.type
						};
						for each (var existingServer:VagrantInstanceVO in instances)
						{
							if (existingServer.titleOriginal == serverHostname)
							{
								isNameExists = true;
								break;
							}
						}
						
						if (isNameExists) continue;
						
						vagrantInstance = new VagrantInstanceVO();
						vagrantInstance.title = vagrantInstance.titleOriginal = serverHostname;
						vagrantInstance.url = "http://restapi."+ serverHostname +":8080";
						vagrantInstance.localPath = filePath.parent.nativePath +"/servers/"+ server.provisioner.type +"/"+ server.server_id;
						vagrantInstance.server = vagrantServer;
						instances.addItem(vagrantInstance);
						shiInstances.push(vagrantInstance);
					}
				}
			}
			
			// give a save on any newly addition
			saveVagrantInstances(instances);

			return shiInstances;
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
				request.idleTimeout = 2000;

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
			var instance:VagrantInstanceVO = instanceStateCheckLoaders[event.target];
			instance.state = VagrantInstanceState.UNREACHABLE;
			instance.capabilities = [];

			releaseLoaderListeners(event.target as URLLoader);
			delete instanceStateCheckLoaders[event.target];
			dispatcher.dispatchEvent(new Event(EVENT_INSTANCE_STATE_CHECK_COMPLETES));
		}

		private static function onStateCheckSecurityError(event:SecurityErrorEvent):void
		{
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