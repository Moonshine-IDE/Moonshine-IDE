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
package actionScripts.plugins.haxe
{
    import actionScripts.events.SettingsEvent;
    import actionScripts.events.StatusBarEvent;
    import actionScripts.plugin.core.compiler.HaxeBuildEvent;
    import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;
    import actionScripts.plugin.settings.ISettingsProvider;
    import actionScripts.plugin.settings.vo.AbstractSetting;
    import actionScripts.plugin.settings.vo.ISetting;
    import actionScripts.plugin.settings.vo.PathSetting;
    import actionScripts.plugins.build.ConsoleBuildPluginBase;
    import actionScripts.utils.HelperUtils;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.ComponentTypes;
    import actionScripts.valueObjects.ComponentVO;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.ProjectVO;

    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.events.ApplicationEvent;
    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.filesystem.File;
    import actionScripts.events.SdkEvent;

    public class HaxeBuildPlugin extends ConsoleBuildPluginBase implements ISettingsProvider
    {
		private var haxePathSetting:PathSetting;
		private var nodePathSetting:PathSetting;
		private var isProjectHasInvalidPaths:Boolean;
        private var limeHTMLServerNativeProcess:NativeProcess;
        private var projectWaitingToStartHTMLDebugServer:HaxeProjectVO = null;
		
        public function HaxeBuildPlugin()
        {
            super();
        }
		
		override protected function onProjectPathsValidated(paths:Array):void
		{
			if (paths)
			{
				isProjectHasInvalidPaths = true;
				error("Following path(s) are invalid or does not exists:\n"+ paths.join("\n"));
			}
		}

        override public function get name():String
        {
            return "Haxe Build Setup";
        }

        override public function get author():String
        {
            return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team";
        }

        override public function get description():String
        {
            return "Haxe Build Plugin.";
        }

        public function get haxePath():String
        {
            return model ? model.haxePath : null;
        }

        public function set haxePath(value:String):void
        {
            if (model.haxePath != value)
            {
                model.haxePath = value;
			    dispatcher.dispatchEvent(new SdkEvent(SdkEvent.CHANGE_HAXE_SDK));
            }
        }

        public function get nodePath():String
        {
            return model ? model.nodePath : null;
        }

        public function set nodePath(value:String):void
        {
            if (model.nodePath != value)
            {
                model.nodePath = value;
            }
        }

        public function getSettingsList():Vector.<ISetting>
        {
			onSettingsClose();

			haxePathSetting = new PathSetting(this, 'haxePath', 'Haxe Home', true, haxePath);
            
			nodePathSetting = new PathSetting(this, 'nodePath', 'Node.js Home', true, nodePath);
			
			return Vector.<ISetting>([
				haxePathSetting,
                nodePathSetting
			]);
        }
		
		override public function onSettingsClose():void
		{
			if (haxePathSetting)
			{
				haxePathSetting = null;
			}
			if (nodePathSetting)
			{
				nodePathSetting = null;
			}
		}

        override public function activate():void
        {
            super.activate();

			dispatcher.addEventListener(HaxeBuildEvent.BUILD_AND_RUN, haxeBuildAndRunHandler);
			dispatcher.addEventListener(HaxeBuildEvent.BUILD_DEBUG, haxeBuildDebugHandler);
			dispatcher.addEventListener(HaxeBuildEvent.BUILD_RELEASE, haxeBuildReleaseHandler);
        }

        override public function deactivate():void
        {
            super.deactivate();

			dispatcher.removeEventListener(HaxeBuildEvent.BUILD_AND_RUN, haxeBuildAndRunHandler);
			dispatcher.removeEventListener(HaxeBuildEvent.BUILD_DEBUG, haxeBuildDebugHandler);
			dispatcher.removeEventListener(HaxeBuildEvent.BUILD_RELEASE, haxeBuildReleaseHandler);
        }
		
		private function haxeBuildAndRunHandler(event:Event):void
		{
            var project:HaxeProjectVO = model.activeProject as HaxeProjectVO;
            if (!project)
            {
                return;
            }
            if(project.isLime)
            {
                var projectFolder:FileLocation = project.folderLocation;
                if(project.targetPlatform == HaxeProjectVO.PLATFORM_HTML5)
                {
                    //for some reason, we can't use startDebug() here because
                    //exiting the NativeProcess with stop() or stop(true) won't
                    //work correctly. the server keeps running, and the port
                    //cannot be used again.
                    //similarly, if we launch npx.cmd directly on Windows, it
                    //still will not exit the server.
                    //instead, we need run Node directly and run the npx script
                    //file. that seems to exit with stop(true).
                    projectWaitingToStartHTMLDebugServer = project;
			        this.start(new <String>[["\"" + UtilsCore.getHaxelibBinPath() + "\"", "run", "lime", "build", project.targetPlatform, "-debug"].join(" ")], model.activeProject.folderLocation);
                }
                else
                {
			        this.startDebug(new <String>[["\"" + UtilsCore.getHaxelibBinPath() + "\"", "run", "lime", "test", project.targetPlatform].join(" ")], projectFolder);
                }
            }
            else
            {
                error("Haxe debug without Lime not implemented yet");
            }
		}
		
		private function haxeBuildDebugHandler(event:Event):void
		{
            var project:HaxeProjectVO = model.activeProject as HaxeProjectVO;
            if (!project)
            {
                return;
            }
            if(project.isLime)
            {
			    this.start(new <String>[["\"" + UtilsCore.getHaxelibBinPath() + "\"", "run", "lime", "build", project.targetPlatform, "-debug"].join(" ")], model.activeProject.folderLocation);
            }
            else
            {
                error("Haxe build without Lime not implemented yet");
            }
		}
		
		private function haxeBuildReleaseHandler(event:Event):void
		{
            var project:HaxeProjectVO = model.activeProject as HaxeProjectVO;
            if (!project)
            {
                return;
            }
            if(project.isLime)
            {
			    this.start(new <String>[["\"" + UtilsCore.getHaxelibBinPath() + "\"", "run", "lime", "build", project.targetPlatform, "-final"].join(" ")], model.activeProject.folderLocation);
            }
            else
            {
                error("Haxe build without Lime not implemented yet");
            }
		}

		override public function start(args:Vector.<String>, buildDirectory:*):void
		{
            if (nativeProcess.running && running)
            {
                warning("Build is running. Wait for finish...");
                return;
            }

            if (!haxePath)
            {
                error("Specify path to Haxe folder.");
                stop(true);
                dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, "actionScripts.plugins.haxe::HaxeBuildPlugin"));
                return;
            }
			
            warning("Starting Haxe build...");

			super.start(args, buildDirectory);
			
            print("Haxe build directory: %s", buildDirectory.fileBridge.nativePath);
            print("Command: %s", args.join(" "));

            var project:ProjectVO = model.activeProject;
            if (project)
            {
                dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, project.projectName, "Building "));
                dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onProjectBuildTerminate);
            }
		}
        
        public function startDebug(args:Vector.<String>, buildDirectory:*):void
		{
            if (nativeProcess.running && running)
            {
                warning("Build is running. Wait for finish...");
                return;
            }

            if (!haxePath)
            {
                error("Specify path to Haxe folder.");
                stop(true);
                dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, "actionScripts.plugins.haxe::HaxeBuildPlugin"));
                return;
            }

			super.start(args, buildDirectory);
			
            print("Command: %s", args.join(" "));

            var project:ProjectVO = model.activeProject;
            if (project)
            {
                dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_DEBUG_STARTED, project.projectName, "Debug "));
                dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onProjectBuildTerminate, false, 0, true);
			    dispatcher.addEventListener(ApplicationEvent.APPLICATION_EXIT, onApplicationExit, false, 0, true);
            }
		}

        private function startLimeHTMLDebugServer(project:HaxeProjectVO):void
        {
            var nodeExePath:String = UtilsCore.getNodeBinPath();
            var args:Vector.<String> = new <String>[
                model.nodePath + "/node_modules/npm/bin/npx-cli.js",
                "http-server@0.9.0",
                "bin/html5/bin",
                "-p",
                "3000",
                "-o"
            ];
            var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
            processInfo.executable = new File(nodeExePath);
            processInfo.arguments = args
    
            print("Command: %s", nodeExePath + " " + args.join(" "));
            processInfo.workingDirectory = new File(project.projectFolder.nativePath);
            nativeProcess = new NativeProcess();
            limeHTMLServerNativeProcess = nativeProcess;
            addNativeProcessEventListeners();
            nativeProcess.start(processInfo);
            running = true;
            dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_DEBUG_STARTED, project.projectName, "Running "));
            dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onProjectBuildTerminate, false, 0, true);
            dispatcher.addEventListener(ApplicationEvent.APPLICATION_EXIT, onApplicationExit, false, 0, true);
        }

        override protected function onNativeProcessIOError(event:IOErrorEvent):void
        {
            super.onNativeProcessIOError(event);
            dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
        }

        override protected function onNativeProcessStandardErrorData(event:ProgressEvent):void
        {
			super.onNativeProcessStandardErrorData(event);
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
		}

        override protected function onNativeProcessExit(event:NativeProcessExitEvent):void
        {
            super.onNativeProcessExit(event);
            var isLimeHTMLServer:Boolean = event.currentTarget == limeHTMLServerNativeProcess;
			dispatcher.removeEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onProjectBuildTerminate);
			dispatcher.removeEventListener(ApplicationEvent.APPLICATION_EXIT, onApplicationExit);

            var allowLimeHTMLServerLaunch:Boolean = false;
            if(isLimeHTMLServer)
            {
                limeHTMLServerNativeProcess = null;
                if(isNaN(event.exitCode))
                {
                    warning("Haxe debug has been terminated.");
                }
                else if(event.exitCode != 0)
                {
                    warning("Haxe debug has been terminated with exit code: " + event.exitCode);
                }
            }
            else
            {
                if(isNaN(event.exitCode))
                {
                    warning("Haxe build has been terminated.");
                }
                else if(event.exitCode != 0)
                {
                    warning("Haxe build has been terminated with exit code: " + event.exitCode);
                }
                else
                {
                    allowLimeHTMLServerLaunch = projectWaitingToStartHTMLDebugServer != null;
                    success("Haxe build has completed successfully.");
                }
            }

            if(isLimeHTMLServer)
            {
                dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_DEBUG_ENDED));
            }
            else
            {
                dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
            }

            var project:HaxeProjectVO = projectWaitingToStartHTMLDebugServer;
            projectWaitingToStartHTMLDebugServer = null;
            if(allowLimeHTMLServerLaunch)
            {
                startLimeHTMLDebugServer(project);
            }
        }

        private function onProjectBuildTerminate(event:StatusBarEvent):void
        {
            if(limeHTMLServerNativeProcess && limeHTMLServerNativeProcess.running)
            {
                //this seems to be required to stop the http-server on Windows
                //otherwise, it will keep running and the port won't be released
                stop(true);
            }
            else
            {
                stop();
            }
        }

        private function onApplicationExit(event:ApplicationEvent):void
        {
            dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_TERMINATE));
        }
	}
}