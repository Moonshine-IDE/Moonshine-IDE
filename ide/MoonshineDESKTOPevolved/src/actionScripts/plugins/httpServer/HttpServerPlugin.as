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
package actionScripts.plugins.httpServer
{
	import actionScripts.events.SettingsEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugins.build.ConsoleBuildPluginBase;
	import actionScripts.plugins.httpServer.events.HttpServerEvent;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;

	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.File;
	import flash.events.Event;
	import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
	import actionScripts.events.ApplicationEvent;
	import actionScripts.events.DebugActionEvent;

	public class HttpServerPlugin extends ConsoleBuildPluginBase
	{
        private static const HTTP_SERVER_MODULE_PATH:String = "elements/http-server/bin/http-server";

		private var currentProject:ProjectVO;

        override public function get name():String
        {
            return "HTTP Server";
        }

        override public function get author():String
        {
            return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team";
        }

        override public function get description():String
        {
            return "Local HTTP Server Plugin.";
        }

        override public function activate():void
        {
            super.activate();

			dispatcher.addEventListener(HttpServerEvent.START_HTTP_SERVER, startHttpServerHandler);
			dispatcher.addEventListener(DebugActionEvent.DEBUG_STOP, debugStopHandler);
			dispatcher.addEventListener(ApplicationEvent.APPLICATION_EXIT, applicationExitHandler);
        }

        override public function deactivate():void
        {
            super.deactivate();

			dispatcher.removeEventListener(HttpServerEvent.START_HTTP_SERVER, startHttpServerHandler);
			dispatcher.removeEventListener(DebugActionEvent.DEBUG_STOP, debugStopHandler);
			dispatcher.removeEventListener(ApplicationEvent.APPLICATION_EXIT, applicationExitHandler);
        }

		private function startHttpServerHandler(event:HttpServerEvent):void
		{
            currentProject = model.activeProject as ProjectVO;
            if (!currentProject)
            {
				event.preventDefault();
                return;
            }
			if(!UtilsCore.isNodeAvailable())
			{
				event.preventDefault();
				error("A valid Node.js path must be defined to start an HTTP server for project \"" + currentProject.name + "\".");
				dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, "actionScripts.plugins.js::JavaScriptPlugin"));
				return;
			}
			if(running)
			{
				event.preventDefault();
				error("An HTTP server is already running.");
				return;
			}
			running = true;
			var webRoot:FileLocation = event.webRoot;
			var port:int = event.port;
			if(event.webRoot == null)
			{
				webRoot = currentProject.folderLocation;
			}
			if(event.port == -1)
			{
				event.port = 8080;
			}

			var nodePath:String = UtilsCore.getNodeBinPath();
            var httpServerPath:FileLocation = model.fileCore.resolveApplicationDirectoryPath(HTTP_SERVER_MODULE_PATH);
            
            var args:Vector.<String> = new <String>[
                httpServerPath.fileBridge.nativePath,
                webRoot.fileBridge.nativePath,
                "-p",
                port.toString()
            ];
            var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
            processInfo.executable = new File(nodePath);
            processInfo.arguments = args;
    
            print("Command: %s", nodePath + " " + args.join(" "));
            processInfo.workingDirectory = new File(webRoot.fileBridge.nativePath);
            nativeProcess = new NativeProcess();
            addNativeProcessEventListeners();
            nativeProcess.start(processInfo);
		}

        override protected function onNativeProcessExit(event:NativeProcessExitEvent):void
        {
			running = false;
            super.onNativeProcessExit(event);
			currentProject = null;

			if(isNaN(event.exitCode))
			{
				warning("HTTP server has been terminated.");
			}
			else if(event.exitCode != 0)
			{
				warning("HTTP server has been terminated with exit code: " + event.exitCode);
			}
        }

        private function debugStopHandler(event:DebugActionEvent):void
        {
			//this seems to be required to stop the http-server on Windows
			//otherwise, it will keep running and the port won't be released
			stop(running);
		}

        private function applicationExitHandler(event:ApplicationEvent):void
        {
			stop(running);
		}
	}
}