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
    import actionScripts.events.ApplicationEvent;
    import actionScripts.events.SdkEvent;
    import actionScripts.events.SettingsEvent;
    import actionScripts.events.StatusBarEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.core.compiler.HaxeBuildEvent;
    import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;
    import actionScripts.plugin.settings.ISettingsProvider;
    import actionScripts.plugin.settings.vo.ISetting;
    import actionScripts.plugin.settings.vo.PathSetting;
    import actionScripts.plugins.build.ConsoleBuildPluginBase;
    import actionScripts.utils.EnvironmentSetupUtils;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.EnvironmentExecPaths;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.valueObjects.Settings;

    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.utils.IDataInput;
    import actionScripts.utils.CommandLineUtil;

    public class HaxeBuildPlugin extends ConsoleBuildPluginBase implements ISettingsProvider
    {
		private var haxePathSetting:PathSetting;
		private var nekoPathSetting:PathSetting;
		private var nodePathSetting:PathSetting;
		private var isProjectHasInvalidPaths:Boolean;
        private var limeHTMLServerNativeProcess:NativeProcess;
        private var projectWaitingToStartHTMLDebugServer:HaxeProjectVO = null;
        private var limeLibpathProcess:NativeProcess;
        private var limeLibPath:String = null;
		
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

        public function get nekoPath():String
        {
            return model ? model.nekoPath : null;
        }

        public function set nekoPath(value:String):void
        {
            if (model.nekoPath != value)
            {
                model.nekoPath = value;
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
			nekoPathSetting = new PathSetting(this, 'nekoPath', 'Neko Home', true, nekoPath);
			nodePathSetting = new PathSetting(this, 'nodePath', 'Node.js Home', true, nodePath);
			
			return Vector.<ISetting>([
				haxePathSetting,
                nekoPathSetting,
                nodePathSetting
			]);
        }
		
		override public function onSettingsClose():void
		{
			if (haxePathSetting)
			{
				haxePathSetting = null;
			}
			if (nekoPathSetting)
			{
				nekoPathSetting = null;
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
			        this.start(new <String>[[EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH, "run", "lime", "build", project.targetPlatform, "-debug"].join(" ")], model.activeProject.folderLocation);
                }
                else
                {
			        this.startDebug(new <String>[[EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH, "run", "lime", "test", project.targetPlatform].join(" ")], projectFolder);
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
			    this.start(new <String>[[EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH, "run", "lime", "build", project.targetPlatform, "-debug"].join(" ")], model.activeProject.folderLocation);
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
			    this.start(new <String>[[EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH, "run", "lime", "build", project.targetPlatform, "-final"].join(" ")], model.activeProject.folderLocation);
            }
            else
            {
                error("Haxe build without Lime not implemented yet");
            }
		}

		override public function start(args:Vector.<String>, buildDirectory:*):void
		{
            if (running)
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

            if (!nekoPath)
            {
                error("Specify path to Neko folder.");
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
            if (running)
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

            if (!nekoPath)
            {
                error("Specify path to Neko folder.");
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

        private function findLimeLibpath():void
        {
			this.limeLibPath = "";
            var libpathCommand:Vector.<String> = new <String>[
                EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH,
                "libpath",
                "lime"
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

                running = true;

				var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				processInfo.arguments = processArgs;
				processInfo.executable = cmdFile;
				processInfo.workingDirectory = projectWaitingToStartHTMLDebugServer.folderLocation.fileBridge.getFile as File;
				
				limeLibpathProcess = new NativeProcess();
				limeLibpathProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, limeLibpathProcess_standardOutputDataHandler);
				limeLibpathProcess.addEventListener(NativeProcessExitEvent.EXIT, limeLibpathProcess_exitHandler);
				limeLibpathProcess.start(processInfo);
			}, null, [CommandLineUtil.joinOptions(libpathCommand)]);
        }

        private function startLimeHTMLDebugServer(project:HaxeProjectVO):void
        {
            running = true;

            var nodeExePath:String = UtilsCore.getNodeBinPath();
            var limeFolder:File = new File(this.limeLibPath);
            var httpServerPath:String = limeFolder.resolvePath("templates/bin/node/http-server/bin/http-server").nativePath;
            var args:Vector.<String> = new <String>[
                httpServerPath,
                "bin/html5/bin",
                "-p",
                "3000",
                "-o"
            ];
            var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
            processInfo.executable = new File(nodeExePath);
            processInfo.arguments = args;
    
            print("Command: %s", nodeExePath + " " + args.join(" "));
            processInfo.workingDirectory = new File(project.projectFolder.nativePath);
            nativeProcess = new NativeProcess();
            limeHTMLServerNativeProcess = nativeProcess;
            addNativeProcessEventListeners();
            nativeProcess.start(processInfo);
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

            if(allowLimeHTMLServerLaunch)
            {
                findLimeLibpath();
            }
            else
            {
                projectWaitingToStartHTMLDebugServer = null;
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

        private function limeLibpathProcess_standardOutputDataHandler(event:ProgressEvent):void
        {
            var process:NativeProcess = NativeProcess(event.currentTarget);
            var output:IDataInput = process.standardOutput;
            var data:String = output.readUTFBytes(output.bytesAvailable);
            this.limeLibPath += data.replace(/[\r\n]/g, "");
        }
		
		private function limeLibpathProcess_exitHandler(event:NativeProcessExitEvent):void
		{
            running = false;

            var project:HaxeProjectVO = projectWaitingToStartHTMLDebugServer;
            projectWaitingToStartHTMLDebugServer = null;

			limeLibpathProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, limeLibpathProcess_standardOutputDataHandler);
			limeLibpathProcess.removeEventListener(NativeProcessExitEvent.EXIT, limeLibpathProcess_exitHandler);
			limeLibpathProcess.exit();
			limeLibpathProcess = null;

			if(event.exitCode == 0)
			{
				startLimeHTMLDebugServer(project);
			}
			else
			{
                this.limeLibPath = "";
				error("Failed to load Lime libpath. Run cancelled.");
			}
        }
	}
}