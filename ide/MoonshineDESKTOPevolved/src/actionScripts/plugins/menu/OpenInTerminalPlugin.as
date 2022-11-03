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
package actionScripts.plugins.menu
{
	import actionScripts.events.FilePluginEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugins.build.ConsoleBuildPluginBase;
import actionScripts.valueObjects.ConstantsCoreVO;

import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.filesystem.File;

public class OpenInTerminalPlugin extends ConsoleBuildPluginBase
	{
		override public function get name():String			{ return "OpenInTerminalPlugin"; }
		
		override public function activate():void 
		{
			if (activated) return;
			
			super.activate();
			dispatcher.addEventListener(FilePluginEvent.EVENT_OPEN_PATH_IN_TERMINAL, onOpenPathInTerminal, false, 0, true);
		}

		override public function deactivate():void
		{
			super.deactivate();
			dispatcher.removeEventListener(FilePluginEvent.EVENT_OPEN_PATH_IN_TERMINAL, onOpenPathInTerminal);
		}
		
		private function onOpenPathInTerminal(event:FilePluginEvent):void
		{
			if (ConstantsCoreVO.IS_MACOS)
			{
				print("%s", "Executing NSD kill process on Terminal window.");
				startOSAScript(event.file);
			}
			else
			{
				/*var command:String = "\""+ macNDSDefaultLookupPath +"\" -batch -kill";
				print("%s", command);
				start(
						new <String>[command],
						null
				);*/
			}
		}

		private function startOSAScript(path:FileLocation):void
		{
			if (nativeProcess.running && running)
			{
				warning("Build is running. Wait for finish...");
				return;
			}

			var openToPath:String = path.fileBridge.isDirectory ? path.fileBridge.nativePath :
					path.fileBridge.parent.fileBridge.nativePath;

			nativeProcess = new NativeProcess();
			nativeProcessStartupInfo = new NativeProcessStartupInfo();
			nativeProcessStartupInfo.executable = File.documentsDirectory.resolvePath("/usr/bin/osascript");

			var command:String = "tell application \"Terminal\" to activate do script \"cd \\\""+ openToPath +"\\\"\"";
			nativeProcessStartupInfo.arguments = Vector.<String>(["-e", command]);
			addNativeProcessEventListeners();
			nativeProcess.start(nativeProcessStartupInfo);
			running = true;
		}
	}
}