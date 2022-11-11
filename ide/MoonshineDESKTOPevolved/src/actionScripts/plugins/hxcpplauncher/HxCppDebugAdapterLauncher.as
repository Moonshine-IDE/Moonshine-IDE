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
package actionScripts.plugins.hxcpplauncher
{
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.SettingsEvent;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.plugins.debugAdapter.IDebugAdapterLauncher;
	import actionScripts.valueObjects.ProjectVO;

	import flash.desktop.NativeProcessStartupInfo;
	import flash.filesystem.File;
	import actionScripts.utils.UtilsCore;

	public class HxCppDebugAdapterLauncher extends ConsoleOutputter implements IDebugAdapterLauncher
	{
		private static const DEBUG_ADAPTER_PATH:String = "elements/hxcpp-debug-adapter/bin/adapter.js";

		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var model:IDEModel = IDEModel.getInstance();

		public function getStartupInfo(project:ProjectVO):NativeProcessStartupInfo
		{
			if(!UtilsCore.isNodeAvailable())
			{
				error("Debug session cancelled. A valid Node.js path must be defined to debug HXCPP apps.");
                dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, "actionScripts.plugins.js::JavaScriptPlugin"));
				return null;
			}

			var processArgs:Vector.<String> = new <String>[];
			var startupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			processArgs.push(File.applicationDirectory.resolvePath(DEBUG_ADAPTER_PATH).nativePath);
			var cwd:File = new File(project.folderLocation.fileBridge.nativePath);
			if(!cwd.exists)
			{
				error("Cannot find folder for debugging: " + cwd.nativePath);
				return null;
			}
			startupInfo.workingDirectory = cwd;
			startupInfo.arguments = processArgs;
			startupInfo.executable = new File(UtilsCore.getNodeBinPath());
			return startupInfo;
		}
	}
}