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
package actionScripts.utils
{
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.interfaces.IModulesFinder;
	import actionScripts.plugins.build.ConsoleBuildPluginBase;
	import actionScripts.valueObjects.ConstantsCoreVO;

	public class ModulesFinder extends ConsoleBuildPluginBase implements IModulesFinder
	{
		protected var onExitFunction:Function;
		protected var modulesFileList:Array;
		
		private var isError:Boolean;
		
		public function ModulesFinder()
		{
			super.activate();
		}
		
		public function search(projectFolder:FileLocation, sourceFolder:FileLocation, exitFn:Function):void
		{
			if (nativeProcess && nativeProcess.running) return;
			
			onExitFunction = exitFn;
			isError = false;
			
			var command:String;
			if (ConstantsCoreVO.IS_MACOS)
			{
				command = "/usr/bin/grep -ilR '<s:Module ' '"+ 
					(
						(!sourceFolder || projectFolder.fileBridge.nativePath == sourceFolder.fileBridge.nativePath) ? 
						projectFolder.fileBridge.nativePath : 
						projectFolder.fileBridge.getRelativePath(sourceFolder, true)
					) +"'";
			}
			else
			{
				command = '"c:\\Windows\\System32\\findstr.exe" /s /i /m /c:"<s:Module " ';
				command += '"'+ (sourceFolder ? sourceFolder.fileBridge.nativePath : projectFolder.fileBridge.nativePath) +'\\*"';
			}
			
			// run the command
			this.start(
				new <String>[command], projectFolder
			);
		}
		
		public function dispose():void
		{
			super.deactivate();
			
			onExitFunction = null;
			modulesFileList = null;
		}
		
		override protected function onNativeProcessStandardOutputData(event:ProgressEvent):void
		{
			modulesFileList = getDataFromBytes(nativeProcess.standardOutput).split(
				ConstantsCoreVO.IS_MACOS ? "\n" : "\r\n"
			);
			
			// result insert a blank row at the end
			modulesFileList.pop();
		}
		
		override protected function onNativeProcessExit(event:NativeProcessExitEvent):void
		{
			super.onNativeProcessExit(event);
			if (onExitFunction != null)
			{
				onExitFunction(modulesFileList, isError);
			}
		}
		
		override protected function onNativeProcessIOError(event:IOErrorEvent):void
		{
			super.onNativeProcessIOError(event);
			isError = true;
		}
		
		override protected function onNativeProcessStandardErrorData(event:ProgressEvent):void
		{
			super.onNativeProcessStandardErrorData(event);
			isError = true;
		}
	}
}