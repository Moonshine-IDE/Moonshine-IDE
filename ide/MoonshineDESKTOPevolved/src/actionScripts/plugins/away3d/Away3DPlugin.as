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
package actionScripts.plugins.away3d
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.SettingsEvent;
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.SettingsView;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.ui.IContentWindow;
	import actionScripts.valueObjects.Settings;
	
	public class Away3DPlugin extends PluginBase implements IPlugin, ISettingsProvider
	{
		public static const OPEN_AWAY3D_BUILDER:String = "OPEN_AWAY3D_BUILDER";
		
		public var executablePath:String;
		
		override public function get name():String { return "Away3D"; }
		override public function get author():String { return "Moonshine Project Team"; }
		override public function get description():String { return "The Away3D Moonshine Plugin."; }
		
		private var customProcess:NativeProcess;
		private var customInfo:NativeProcessStartupInfo;
		private var awdFileObject:File;
		
		override public function activate():void
		{
			super.activate();
			
			dispatcher.addEventListener(OPEN_AWAY3D_BUILDER, openAway3DBuilder, false, 0, true);
			dispatcher.addEventListener(ProjectEvent.ADD_PROJECT_AWAY3D, onAway3DProjectCreated, false, 0, true);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			
			dispatcher.removeEventListener(OPEN_AWAY3D_BUILDER, openAway3DBuilder);
			dispatcher.removeEventListener(ProjectEvent.ADD_PROJECT_AWAY3D, onAway3DProjectCreated);
		}
		
		override public function resetSettings():void
		{
			awdFileObject = null;
		}
		
		public function getSettingsList():Vector.<ISetting>
		{
			return Vector.<ISetting>([
				new PathSetting(this, 'executablePath', 'Away3D Builder', false, null, false, false)
				]);
		}
		
		private function openAway3DBuilder(event:Event):void
		{
			if (!executablePath) Alert.show("Application unavailable. Please locate the Away3D Builder to run.", "Error!", Alert.OK, FlexGlobals.topLevelApplication as Sprite, locateHandler);
			else runHandler();
			
			function locateHandler(value:CloseEvent):void
			{
				dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, "actionScripts.plugins.away3d::Away3DPlugin"));
				
				for each (var tab:IContentWindow in model.editors)
				{
					if (tab["className"] == "SettingsView")
					{
						tab.addEventListener(SettingsView.EVENT_SAVE, onAway3DSettingsUpdated, false, 0, true);
						tab.addEventListener(SettingsView.EVENT_CLOSE, onAway3DSettingsCanceled, false, 0, true);
						return;
					}
				}
			}
			
			function runHandler():void
			{
				runAwdFile(); // no parameter to open the application only
			}
		}
		
		private function onAway3DSettingsUpdated(event:Event):void
		{
			if (executablePath) runAwdFile(awdFileObject);
			else error("Application unavailable. Terminating.");
		}
		
		private function onAway3DSettingsCanceled(event:Event):void
		{
			event.target.removeEventListener(SettingsView.EVENT_SAVE, onAway3DSettingsUpdated);
			event.target.removeEventListener(SettingsView.EVENT_CLOSE, onAway3DSettingsCanceled);
		}
		
		private function onAway3DProjectCreated(event:ProjectEvent):void
		{
			var files:Array = event.project.folderLocation.fileBridge.getDirectoryListing();
			for each (var file:File in files)
			{
				// get the first instance of the awd file and run it
				if (file.extension == "awd")
				{
					awdFileObject = file;
					break;
				}
			}
			
			if (awdFileObject) 
			{
				if (!executablePath) openAway3DBuilder(null);
				else runAwdFile(awdFileObject);
			}
			else error("No Away3D file found.");
		}
		
		private function runAwdFile(withFile:File=null):void
		{
			var executableFile:File = (Settings.os == "win") ? new File("c:\\Windows\\System32\\cmd.exe") : new File("/bin/bash");
			var processArgs:Vector.<String> = new Vector.<String>;
			customInfo = new NativeProcessStartupInfo();
			
			if (Settings.os == "win") processArgs.push("/c");
			else processArgs.push("-c");
			processArgs.push(executablePath);
			if (withFile) processArgs.push(withFile.nativePath);
			
			customInfo.arguments = processArgs;
			customInfo.executable = executableFile;
			
			if (customProcess) startShell(false);
			startShell(true);
		}
		
		private function startShell(start:Boolean):void 
		{
			if (start)
			{
				customProcess = new NativeProcess();
				customProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
				customProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
				customProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
				customProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
				customProcess.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
				customProcess.start(customInfo);
			}
			else
			{
				if (!customProcess) return;
				if (customProcess.running) customProcess.exit();
				customProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
				customProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
				customProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
				customProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
				customProcess.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
				customProcess = null;
			}
		}
		
		private function shellError(e:ProgressEvent):void 
		{
			if (customProcess)
			{
				var output:IDataInput = customProcess.standardError;
				var data:String = output.readUTFBytes(output.bytesAvailable);
				
				var syntaxMatch:Array;
				var generalMatch:Array;
				var initMatch:Array;
				
				syntaxMatch = data.match(/(.*?)\((\d*)\): col: (\d*) Error: (.*).*/);
				if (syntaxMatch) {
					var pathStr:String = syntaxMatch[1];
					var lineNum:int = syntaxMatch[2];
					var colNum:int = syntaxMatch[3];
					var errorStr:String = syntaxMatch[4];
				}
				
				generalMatch = data.match(/(.*?): Error: (.*).*/);
				if (!syntaxMatch && generalMatch)
				{ 
					pathStr = generalMatch[1];
					errorStr  = generalMatch[2];
					pathStr = pathStr.substr(pathStr.lastIndexOf("/")+1);
					debug("%s", data);
				}
				else
				{
					debug("%s", data);
				}
				
				startShell(false);
			}
		}
		
		private function shellExit(e:NativeProcessExitEvent):void 
		{
			startShell(false);
		}
		
		private function shellData(e:ProgressEvent):void 
		{
			var output:IDataInput = customProcess.standardOutput;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			
			debug("%s", data);
		}
	}
}