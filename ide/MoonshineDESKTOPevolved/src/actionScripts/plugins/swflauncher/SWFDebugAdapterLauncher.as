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
package actionScripts.plugins.swflauncher
{
	import actionScripts.plugins.debugAdapter.IDebugAdapterLauncher;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.filesystem.File;
	import actionScripts.valueObjects.Settings;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.SettingsEvent;
	import actionScripts.locator.IDEModel;
	import actionScripts.utils.getProjectSDKPath;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;

	public class SWFDebugAdapterLauncher extends ConsoleOutputter implements IDebugAdapterLauncher
	{
		private static const DEBUG_ADAPTER_BIN_PATH:String = "elements/swf-debug-adapter/bin/";
		private static const BUNDLED_DEBUGGER_PATH:String = "elements/swf-debug-adapter/bundled-debugger/";

		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var model:IDEModel = IDEModel.getInstance();

		public function getStartupInfo(project:ProjectVO):NativeProcessStartupInfo
		{
			var sdkFile:File = null;
			if(project is AS3ProjectVO)
			{
				var sdkPathAS3Proj:String = getProjectSDKPath(project, model);

				sdkFile = new File(sdkPathAS3Proj);
			}
			else
			{
				if(model.defaultSDK)
				{
					sdkFile = model.defaultSDK.fileBridge.getFile as File;
				}
			}

			if(!sdkFile)
			{
				error("Debug session cancelled. An ActionScript SDK must be defined to debug SWF files.");
				dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, "actionScripts.plugins.as3project.mxmlc::MXMLCPlugin"));
				return null;
			}

			var processArgs:Vector.<String> = new <String>[];
			var startupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();

			var sdkFramework:String = sdkFile.resolvePath("frameworks").nativePath;
			processArgs.push("-Dflexlib=" + sdkFramework);

			var projectFolderLocation:String = project.folderLocation.fileBridge.nativePath;
			processArgs.push("-Dworkspace=" + projectFolderLocation);
			processArgs.push("-cp");

			var cp:String = File.applicationDirectory.resolvePath(DEBUG_ADAPTER_BIN_PATH).nativePath + File.separator + "*";

			if (Settings.os == "win")
			{
				cp += ";"
			}
			else
			{
				cp += ":";
			}
			cp += File.applicationDirectory.resolvePath(BUNDLED_DEBUGGER_PATH).nativePath + File.separator + "*";

			processArgs.push(cp);
			processArgs.push("com.as3mxml.vscode.SWFDebug");
			var cwd:File = new File(project.folderLocation.fileBridge.nativePath);
			if(!cwd.exists)
			{
				error("Cannot find folder for debugging: " + cwd.nativePath);
				return null;
			}
			startupInfo.workingDirectory = cwd;
			startupInfo.arguments = processArgs;

			var javaFile:File;
			if (model.javaPathForTypeAhead != null)
			{
				javaFile = File(model.javaPathForTypeAhead.fileBridge.getFile);
			}
			else if (model.java8Path != null)
			{
				javaFile = File(model.java8Path.fileBridge.getFile);
			}
			else if (!model.javaPathForTypeAhead && !model.java8Path)
			{
				error("Java Development Kit path has not been set. Please set path to JDK.");
				return null;
			}

			var javaFileName:String = (Settings.os == "win") ? "java.exe" : "java";
			var javaPathFile:File = javaFile.resolvePath("bin/" + javaFileName);

			startupInfo.executable = javaPathFile;
			return startupInfo;
		}
	}
}