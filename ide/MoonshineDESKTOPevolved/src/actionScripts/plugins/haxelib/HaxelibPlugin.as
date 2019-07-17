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

	public class HaxelibPlugin extends PluginBase
	{
		private static const HAXELIB_LIME:String = "lime";

		public function HaxelibPlugin()
		{
		}

		override public function get name():String { return "Haxelib Plugin"; }
		override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team"; }
		override public function get description():String { return "Manage Haxelib dependencies."; }

		private var _checkStatusOfDependencyProcess:NativeProcess;
		private var _installDependencyProcess:NativeProcess;
		private var _dependencyIndex:int = 0;
		private var _project:HaxeProjectVO;
		private var _dependencies:Array = [];
		private var _currentDependency:ComponentVO = null;
		private var _haxelibFile:File;

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

		private function checkStatusOfNextDependency():void
		{
			_currentDependency = null;
			if(_dependencyIndex >= _dependencies.length)
			{
				_dependencyIndex = 0;
				installNextDependency();
				return;
			}
			_currentDependency = _dependencies[_dependencyIndex];
			_dependencyIndex++;

			var processArgs:Vector.<String> = new <String>[
				"path",
				_currentDependency.title
			];

			var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			processInfo.arguments = processArgs;
			processInfo.executable = _haxelibFile;
			
			_checkStatusOfDependencyProcess = new NativeProcess();
			_checkStatusOfDependencyProcess.addEventListener(NativeProcessExitEvent.EXIT, checkStatusOfDependencyProcess_exitHandler);
			_checkStatusOfDependencyProcess.start(processInfo);
		}

		private function installNextDependency():void
		{
			_currentDependency = null;
			if(_dependencyIndex >= _dependencies.length)
			{
				_project = null;
				_dependencies = null;
				_dependencyIndex = 0;
				dispatcher.dispatchEvent(new HaxelibEvent(HaxelibEvent.HAXELIB_INSTALL_COMPLETE, _project));
				return;
			}
			_currentDependency = _dependencies[_dependencyIndex];
			_dependencyIndex++;

			if(_currentDependency.isDownloaded)
			{
				installNextDependency();
				return;
			}

			ConsoleOutputter.formatOutput("Installing dependency " + _currentDependency.title + "...", "notice");

			var processArgs:Vector.<String> = new <String>[
				"install",
				_currentDependency.title
			];

			var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			processInfo.arguments = processArgs;
			processInfo.executable = _haxelibFile;
			
			_installDependencyProcess = new NativeProcess();
			_installDependencyProcess.addEventListener(NativeProcessExitEvent.EXIT, installDependencyProcess_exitHandler);
			_installDependencyProcess.start(processInfo);
		}

		private function haxelibInstallHandler(event:HaxelibEvent):void
		{
			var haxelibPath:String = UtilsCore.getHaxelibBinPath();
			if(!haxelibPath)
			{
				return;
			}
			_haxelibFile = new File(haxelibPath);
			if(!_haxelibFile.exists)
			{
				return;
			}

			_project = event.project;

			var projectFile:File = _project.folderLocation.resolvePath("project.xml").fileBridge.getFile as File;
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

			_dependencies = [];

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
				_dependencies.push(item);
			}
			if(_project.isLime && !foundLime)
			{
				//lime is always required for Lime projects, but some might not
				//list it as a dependency
				var limeItem:ComponentVO = new ComponentVO();
				limeItem.title = HAXELIB_LIME;
				limeItem.isDownloaded = false;
				_dependencies.unshift(limeItem);
			}

			_dependencyIndex = 0;
			checkStatusOfNextDependency();
		}

		private function checkStatusOfDependencyProcess_exitHandler(event:NativeProcessExitEvent):void
		{
			_checkStatusOfDependencyProcess.removeEventListener(NativeProcessExitEvent.EXIT, checkStatusOfDependencyProcess_exitHandler);
			_checkStatusOfDependencyProcess.exit();
			_checkStatusOfDependencyProcess = null;

			if(event.exitCode == 0)
			{
				_currentDependency.isDownloaded = true;
			}
			else
			{
				_currentDependency.isDownloaded = false;
			}

			checkStatusOfNextDependency();
		}

		private function installDependencyProcess_exitHandler(event:NativeProcessExitEvent):void
		{
			_installDependencyProcess.removeEventListener(NativeProcessExitEvent.EXIT, installDependencyProcess_exitHandler);
			_installDependencyProcess.exit();
			_installDependencyProcess = null;

			if(event.exitCode == 0)
			{
				_currentDependency.isDownloaded = true;
				installNextDependency();
			}
			else
			{
				_currentDependency.isDownloaded = false;
				_currentDependency.hasError = "Failed to install dependency: " + this._currentDependency.title;
				ConsoleOutputter.formatOutput(_currentDependency.hasError, "error");
			}

		}

	}
}
