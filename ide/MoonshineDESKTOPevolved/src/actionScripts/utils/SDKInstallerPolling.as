////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.utils.Timer;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.StartupHelperEvent;
	import actionScripts.valueObjects.HelperConstants;
	
	public class SDKInstallerPolling extends EventDispatcher
	{
		private static var instance:SDKInstallerPolling;
		
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var pollingTimer:Timer;
		
		private var _notifierFileLocation:File = File.applicationStorageDirectory.resolvePath(HelperConstants.MOONSHINE_NOTIFIER_FILE_NAME);
		public function get notifierFileLocation():File
		{
			return _notifierFileLocation;
		}
		
		public static function getInstance():SDKInstallerPolling
		{	
			if (!instance) instance = new SDKInstallerPolling();
			return instance;
		}
		
		public function startPolling():void
		{
			stopPolling();
			
			pollingTimer = new Timer(10000);
			pollingTimer.addEventListener(TimerEvent.TIMER, onPollTimerTick);
			pollingTimer.start();
			onPollTimerTick(null);
		}
		
		public function stopPolling():void
		{
			if (pollingTimer && pollingTimer.running)
			{
				pollingTimer.stop();
				pollingTimer.removeEventListener(TimerEvent.TIMER, onPollTimerTick);
				pollingTimer = null;
			}
		}
		
		private function onPollTimerTick(event:TimerEvent):void
		{
			if (notifierFileLocation.exists)
			{
				dispatcher.dispatchEvent(new StartupHelperEvent(StartupHelperEvent.EVENT_SDK_INSTALLER_NOTIFIER_NOTIFICATION));
			}
		}
	}
}