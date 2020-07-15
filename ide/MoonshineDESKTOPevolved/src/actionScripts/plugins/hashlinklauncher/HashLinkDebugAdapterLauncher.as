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
package actionScripts.plugins.hashlinklauncher
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

	public class HashLinkDebugAdapterLauncher extends ConsoleOutputter implements IDebugAdapterLauncher
	{
		private static const DEBUG_ADAPTER_PATH:String = "elements/hashlink-debug-adapter/adapter.js";

		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var model:IDEModel = IDEModel.getInstance();

		public function getStartupInfo(project:ProjectVO):NativeProcessStartupInfo
		{
			if(!UtilsCore.isNodeAvailable())
			{
				error("Debug session cancelled. A valid Node.js path must be defined to debug HashLink apps.");
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