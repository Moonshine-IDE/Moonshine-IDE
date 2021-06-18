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
			print("SWFDebugAdapterLauncher.getStartupInfo: Retrieving startup information");
			if(project is AS3ProjectVO)
			{
				var sdkPathAS3Proj = getProjectSDKPath(project, model);
				print("SWFDebugAdapterLauncher.getStartupInfo: SDK path when AS3 project" + sdkPathAS3Proj);

				sdkFile = new File(sdkPathAS3Proj);
			}
			else
			{
				print("SWFDebugAdapterLauncher.getStartupInfo: Init calculation SDK path for non AS3 project");
				if(model.defaultSDK)
				{
					sdkFile = model.defaultSDK.fileBridge.getFile as File;
					print("SWFDebugAdapterLauncher.getStartupInfo: SDK path for non AS3 project" + sdkFile.nativePath);
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
			processArgs.push("-Dflexlib=" + sdkFile.resolvePath("frameworks").nativePath);
			processArgs.push("-Dworkspace=" + project.folderLocation.fileBridge.nativePath);
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
			var javaFile:File = File(model.javaPathForTypeAhead.fileBridge.getFile);
			var javaFileName:String = (Settings.os == "win") ? "java.exe" : "java";
			var javaPathFile:File = javaFile.resolvePath("bin/" + javaFileName);
			print("getStartupInfo: Calculated Javapath: " + javaPathFile.nativePath);

			startupInfo.executable = javaPathFile;
			return startupInfo;
		}
	}
}