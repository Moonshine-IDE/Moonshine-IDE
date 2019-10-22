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
package actionScripts.plugins.haxelib
{
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;
	import actionScripts.plugins.haxelib.events.HaxelibEvent;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.ConstantsCoreVO;

	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.Dictionary;
	import flash.events.ProgressEvent;
	import flash.utils.IDataInput;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.utils.EnvironmentSetupUtils;
	import actionScripts.valueObjects.Settings;
	import actionScripts.valueObjects.EnvironmentExecPaths;
	import actionScripts.utils.CommandLineUtil;

	public class HaxelibPlugin extends PluginBase
	{
		private static const HAXELIB_LIME:String = "lime";
		private static const FILE_NAME_PROJECT_XML:String = "project.xml";

		public function HaxelibPlugin()
		{
		}

		override public function get name():String { return "Haxelib Plugin"; }
		override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team"; }
		override public function get description():String { return "Manage Haxelib dependencies."; }

		private var _processToStatus:Dictionary = new Dictionary();

		override public function activate():void
		{
			super.activate();
			dispatcher.addEventListener(HaxelibEvent.HAXELIB_INSTALL, haxelibInstallHandler);
		}

		override public function deactivate():void
		{
			super.deactivate();
			dispatcher.removeEventListener(HaxelibEvent.HAXELIB_INSTALL, haxelibInstallHandler);
		}

		private function checkStatusOfNextDependency(status:ProjectInstallStatus):void
		{
			if(status.currentIndex >= status.items.length)
			{
				status.currentIndex = 0;
				dispatcher.dispatchEvent(new StatusBarEvent(
					StatusBarEvent.LANGUAGE_SERVER_STATUS,
					"Haxe", "Installing Haxe dependencies...", false
				));
				installNextDependency(status);
				return;
			}

			var currentItem:ComponentVO = status.items[status.currentIndex];

			var pathCommand:Vector.<String> = new <String>[
				EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH,
				"path",
				currentItem.title
			];
			EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(function(value:String):void
			{
				var cmdFile:File = null;
				var processArgs:Vector.<String> = new <String>[];
				
				if (Settings.os == "win")
				{
					cmdFile = new File("c:\\Windows\\System32\\cmd.exe");
					processArgs.push("/c");
					processArgs.push(value);
				}
				else
				{
					cmdFile = new File("/bin/bash");
					processArgs.push("-c");
					processArgs.push(value);
				}

				var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				processInfo.arguments = processArgs;
				processInfo.executable = cmdFile;
			
				var process:NativeProcess = new NativeProcess();
				_processToStatus[process] = status;
				//we don't care about ProgressEvent.STANDARD_ERROR_DATA here
				//it only matters if the installation fails later
				process.addEventListener(NativeProcessExitEvent.EXIT, checkStatusOfDependencyProcess_exitHandler);
				process.start(processInfo);
			}, null, [CommandLineUtil.joinOptions(pathCommand)]);
		}

		private function installNextDependency(status:ProjectInstallStatus):void
		{
			if(status.currentIndex >= status.items.length)
			{
				dispatcher.dispatchEvent(new StatusBarEvent(
					StatusBarEvent.LANGUAGE_SERVER_STATUS
				));
				dispatcher.dispatchEvent(new HaxelibEvent(HaxelibEvent.HAXELIB_INSTALL_COMPLETE, status.project));
				return;
			}
			var currentItem:ComponentVO = status.items[status.currentIndex];

			if(currentItem.isDownloaded)
			{
				//this dependency is already installed, so we can skip it
				status.currentIndex++;
				installNextDependency(status);
				return;
			}

			ConsoleOutputter.formatOutput("Installing dependency " + currentItem.title + "...", "notice");
			var installCommand:Vector.<String> = new <String>[
				EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH,
				"install",
				currentItem.title,
				"--quiet"
			];
			EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(function(value:String):void
			{
				var cmdFile:File = null;
				var processArgs:Vector.<String> = new <String>[];
				
				if (Settings.os == "win")
				{
					cmdFile = new File("c:\\Windows\\System32\\cmd.exe");
					processArgs.push("/c");
					processArgs.push(value);
				}
				else
				{
					cmdFile = new File("/bin/bash");
					processArgs.push("-c");
					processArgs.push(value);
				}

				var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				processInfo.arguments = processArgs;
				processInfo.executable = cmdFile;

				var process:NativeProcess = new NativeProcess();
				_processToStatus[process] = status;
				process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, installDependencyProcess_standardOutputDataHandler);
				process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, installDependencyProcess_standardErrorDataHandler);
				process.addEventListener(NativeProcessExitEvent.EXIT, installDependencyProcess_exitHandler);
				process.start(processInfo);
			}, null, [CommandLineUtil.joinOptions(installCommand)]);
		}

		private function haxelibInstallHandler(event:HaxelibEvent):void
		{
			if(!UtilsCore.isHaxeAvailable() || !UtilsCore.isNekoAvailable())
			{
				return;
			}

			var project:HaxeProjectVO = event.project;
			var projectFile:File = project.folderLocation.resolvePath(FILE_NAME_PROJECT_XML).fileBridge.getFile as File;
			if(!projectFile.exists)
			{
				return;
			}

			var xml:XML = null;
			try
			{
				var stream:FileStream = new FileStream();
				stream.open(projectFile, FileMode.READ);
				var content:String = stream.readUTFBytes(stream.bytesAvailable);
				xml = new XML(content);
			}
			catch(e:Error)
			{
				return;
			}

			var items:Vector.<ComponentVO> = new <ComponentVO>[];

			var foundLime:Boolean = false;
			var haxelibList:XMLList = xml.elements("haxelib");
			var haxelibCount:int = haxelibList.length();
			for(var i:int = 0; i < haxelibCount; i++)
			{
				var haxelibXML:XML = haxelibList[i];
				var name:String = haxelibXML.attribute("name").toString();
				if(!foundLime && name == HAXELIB_LIME)
				{
					foundLime = true;
				}
				var item:ComponentVO = new ComponentVO();
				item.title = name;
				item.isDownloaded = false;
				items.push(item);
			}
			if(project.isLime && !foundLime)
			{
				//lime is always required for Lime projects, but some might not
				//list it as a dependency
				var limeItem:ComponentVO = new ComponentVO();
				limeItem.title = HAXELIB_LIME;
				limeItem.isDownloaded = false;
				items.unshift(limeItem);
			}

			var status:ProjectInstallStatus = new ProjectInstallStatus(project, items);
			checkStatusOfNextDependency(status);
		}

		private function checkStatusOfDependencyProcess_exitHandler(event:NativeProcessExitEvent):void
		{
			var process:NativeProcess = NativeProcess(event.currentTarget);
			var status:ProjectInstallStatus = _processToStatus[process];
			delete _processToStatus[status];
			process.removeEventListener(NativeProcessExitEvent.EXIT, checkStatusOfDependencyProcess_exitHandler);
			process.exit();

			var currentItem:ComponentVO = status.items[status.currentIndex];
			status.currentIndex++;

			if(event.exitCode == 0)
			{
				currentItem.isDownloaded = true;
			}
			else
			{
				currentItem.isDownloaded = false;
			}

			checkStatusOfNextDependency(status);
		}

		private function installDependencyProcess_standardOutputDataHandler(event:ProgressEvent):void
		{
			var process:NativeProcess = NativeProcess(event.currentTarget);
			var output:IDataInput = process.standardOutput;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			ConsoleOutputter.formatOutput(data, "notice");
			trace(data);
		}

		private function installDependencyProcess_standardErrorDataHandler(event:ProgressEvent):void
		{
			var process:NativeProcess = NativeProcess(event.currentTarget);
			var output:IDataInput = process.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			ConsoleOutputter.formatOutput(data, "error");
			trace(data);
		}

		private function installDependencyProcess_exitHandler(event:NativeProcessExitEvent):void
		{
			var process:NativeProcess = NativeProcess(event.currentTarget);
			var status:ProjectInstallStatus = _processToStatus[process];
			delete _processToStatus[status];
			process.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, installDependencyProcess_standardOutputDataHandler);
			process.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, installDependencyProcess_standardErrorDataHandler);
			process.removeEventListener(NativeProcessExitEvent.EXIT, installDependencyProcess_exitHandler);
			process.exit();

			var currentItem:ComponentVO = status.items[status.currentIndex];
			status.currentIndex++;

			if(event.exitCode == 0)
			{
				currentItem.isDownloaded = true;
				installNextDependency(status);
			}
			else
			{
				dispatcher.dispatchEvent(new StatusBarEvent(
					StatusBarEvent.LANGUAGE_SERVER_STATUS
				));

				currentItem.isDownloaded = false;
				currentItem.hasError = "Failed to install dependency: " + currentItem.title;
				ConsoleOutputter.formatOutput(currentItem.hasError, "error");
			}

		}

	}
}

import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;
import actionScripts.valueObjects.ComponentVO;

class ProjectInstallStatus
{
	public function ProjectInstallStatus(project:HaxeProjectVO, items:Vector.<ComponentVO>)
	{
		this.project = project;
		this.items = items;
	}

	public var project:HaxeProjectVO;
	public var items:Vector.<ComponentVO>;
	public var currentIndex:int = 0;

}