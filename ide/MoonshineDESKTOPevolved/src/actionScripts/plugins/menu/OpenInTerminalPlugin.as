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
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	
	import actionScripts.events.FilePluginEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugins.build.ConsoleBuildPluginBase;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;

	public class OpenInTerminalPlugin extends ConsoleBuildPluginBase
	{
		public static var TERMINAL_THEMES:Array;

		override public function get name():String			{ return "OpenInTerminalPlugin"; }
		
		override public function activate():void 
		{
			if (activated) return;
			
			super.activate();
			dispatcher.addEventListener(FilePluginEvent.EVENT_OPEN_PATH_IN_TERMINAL, onOpenPathInTerminal, false, 0, true);

			if (ConstantsCoreVO.IS_MACOS)
			{
				retrieveThemeListOnTerminal();
			}
		}

		override public function deactivate():void
		{
			super.deactivate();
			dispatcher.removeEventListener(FilePluginEvent.EVENT_OPEN_PATH_IN_TERMINAL, onOpenPathInTerminal);
			for each (var theme:String in TERMINAL_THEMES)
			{
				dispatcher.removeEventListener("eventOpenInTerminal"+ theme, onOpenPathInTerminal);
			}
		}

		override protected function onNativeProcessStandardOutputData(event:ProgressEvent):void
		{
			var output:String = getDataFromBytes(nativeProcess.standardOutput);

			/* NOTE:
				The command returns NeXTSTEP string.
				Unfortunately, there's no easy way to convert
				NeXTSTEP to JSON or any other format, except using
				"plutil", but the utility do not come pre-installed
				on macOS.
				A simpler approach with using Regexp thus
				worked in this case.
			 */
			var tmpReg:RegExp = new RegExp("name = (.*?)\;", "gm"); // name = "Silver Aerogel"; or, name = Grass;
			var namedElements:Array = output.match(tmpReg);

			output = namedElements.join("");
			output = output.replace(/name = /g, ""); // removes `name = `;
			output = output.replace(/\"/g, ""); // removes double-quote
			output = output.replace(/\;/g, "|"); // replace ; with | for latter array.join
			if (output.charAt(output.length - 1) == "|")
			{
				output = output.substr(0, output.length - 1);
			}

			TERMINAL_THEMES = output.split("|");
			for each (var theme:String in TERMINAL_THEMES)
			{
				dispatcher.addEventListener("eventOpenInTerminal"+ theme, onOpenPathInTerminal, false, 0, true);
			}
		}

		private function retrieveThemeListOnTerminal():void
		{
			var command:String = "defaults read com.apple.Terminal \"Window Settings\"";
			start(
					new <String>[command],
					null
			);
		}
		
		private function onOpenPathInTerminal(event:FilePluginEvent):void
		{
			var openToPath:String = event.file.fileBridge.isDirectory ? event.file.fileBridge.nativePath :
				event.file.fileBridge.parent.fileBridge.nativePath;
			
			if (ConstantsCoreVO.IS_MACOS)
			{
				var themeName:String = (event.type as String).replace("eventOpenInTerminal", "");
				openInTerminal(openToPath, themeName);
			}
			else
			{
				openInCommandLine(openToPath);
			}
		}

		private function openInTerminal(openToPath:String, themeName:String):void
		{
			if (nativeProcess.running && running)
			{
				warning("Build is running. Wait for finish...");
				return;
			}

			nativeProcess = new NativeProcess();
			nativeProcessStartupInfo = new NativeProcessStartupInfo();
			nativeProcessStartupInfo.executable = File.documentsDirectory.resolvePath("/usr/bin/osascript");

			var scriptFile:File = File.applicationDirectory.resolvePath( "macOScripts/OpenInTerminal.scpt" );
			nativeProcessStartupInfo.arguments = Vector.<String>([scriptFile.nativePath, openToPath, themeName]);
			addNativeProcessEventListeners();
			nativeProcess.start(nativeProcessStartupInfo);
			running = true;
		}
		
		private function openInCommandLine(openToPath:String):void
		{
			var driveChar:String = "";
			if (openToPath.charAt(0).toLowerCase() != "c")
			{
				driveChar = openToPath.charAt(0) +":&&"
			}
			
			var command:String = "start cmd /k \""+ driveChar +"cd "+ UtilsCore.getEncodedForShell(openToPath) +"\"";
			start(
				new <String>[command],
				null
			);
		}
	}
}