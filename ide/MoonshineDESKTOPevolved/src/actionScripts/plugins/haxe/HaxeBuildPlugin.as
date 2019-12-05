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
    import actionScripts.events.RefreshTreeEvent;
    import actionScripts.utils.CommandLineUtil;
    import actionScripts.plugin.haxe.hxproject.vo.HaxeOutputVO;
    import actionScripts.plugins.swflauncher.event.SWFLaunchEvent;
    import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
    import actionScripts.events.ProjectEvent;
    import actionScripts.plugins.debugAdapter.events.DebugAdapterEvent;
    import flash.errors.IllegalOperationError;
    import actionScripts.factory.FileLocation;

    public class HaxeBuildPlugin extends ConsoleBuildPluginBase implements ISettingsProvider
    {
		private var haxePathSetting:PathSetting;
		private var nekoPathSetting:PathSetting;
		private var nodePathSetting:PathSetting;
		private var isProjectHasInvalidPaths:Boolean;
        private var limeHTMLServerNativeProcess:NativeProcess;
        private var currentProject:HaxeProjectVO;
        private var pendingRunProject:HaxeProjectVO = null;
        private var pendingRunCommand:String = null;
        private var pendingRunFolder:String = null;
        private var pendingDebug:Boolean = false;
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

			dispatcher.addEventListener(ActionScriptBuildEvent.BUILD_AND_DEBUG, haxeBuildAndDebugHandler);
			dispatcher.addEventListener(HaxeBuildEvent.BUILD_AND_RUN, haxeBuildAndRunHandler);
			dispatcher.addEventListener(HaxeBuildEvent.BUILD_DEBUG, haxeBuildDebugHandler);
			dispatcher.addEventListener(HaxeBuildEvent.BUILD_RELEASE, haxeBuildReleaseHandler);
        }

        override public function deactivate():void
        {
            super.deactivate();

			dispatcher.removeEventListener(ActionScriptBuildEvent.BUILD_AND_DEBUG, haxeBuildAndDebugHandler);
			dispatcher.removeEventListener(HaxeBuildEvent.BUILD_AND_RUN, haxeBuildAndRunHandler);
			dispatcher.removeEventListener(HaxeBuildEvent.BUILD_DEBUG, haxeBuildDebugHandler);
			dispatcher.removeEventListener(HaxeBuildEvent.BUILD_RELEASE, haxeBuildReleaseHandler);
        }
		
		private function haxeBuildAndDebugHandler(event:Event):void
		{
            var project:HaxeProjectVO = model.activeProject as HaxeProjectVO;
            if (!project)
            {
                return;
            }
            pendingRunProject = null;
            pendingRunCommand = null;
            pendingRunFolder = null;
            pendingDebug = false;
            clearOutput();

            if(project.isLime)
            {
                switch(project.limeTargetPlatform)
                {
                    case HaxeProjectVO.LIME_PLATFORM_HTML5:
                    case HaxeProjectVO.LIME_PLATFORM_AIR:
                    case HaxeProjectVO.LIME_PLATFORM_FLASH:
                    {
                        pendingDebug = true;
			            this.start(new <String>[[EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH, "run", "lime", "build", project.limeTargetPlatform, "-debug"].join(" ")], project.folderLocation);
                        break;
                    }
                    default:
                    {
                        error("Haxe Lime/OpenFL build and debug failed. This command is not supported on platform \"" + project.limeTargetPlatform + "\".");
                    }
                }
            }
            else
            {
                switch(project.haxeOutput.platform)
                {
                    case HaxeOutputVO.PLATFORM_FLASH_PLAYER:
                    {
                        pendingDebug = true;
                        this.start(new <String>[[EnvironmentExecPaths.HAXE_ENVIRON_EXEC_PATH, "--debug", "-D", "fdb", project.getHXML().split("\n").join(" ")].join(" ")], project.folderLocation);
                        break;
                    }
                    default:
                    {
                        error("Haxe build and debug failed. This command is not supported on platform \"" + project.haxeOutput.platform + "\".");
                    }
                }
            }
        }
		
		private function haxeBuildAndRunHandler(event:Event):void
		{
            var project:HaxeProjectVO = model.activeProject as HaxeProjectVO;
            if (!project)
            {
                return;
            }
            pendingRunProject = null;
            pendingRunCommand = null;
            pendingRunFolder = null;
            pendingDebug = false;
            clearOutput();

            if(project.isLime)
            {
                if(project.limeTargetPlatform == HaxeProjectVO.LIME_PLATFORM_HTML5)
                {
                    //for some reason, we can't use startDebug() here because
                    //exiting the NativeProcess with stop() or stop(true) won't
                    //work correctly. the server keeps running, and the port
                    //cannot be used again.
                    //similarly, if we launch npx.cmd directly on Windows, it
                    //still will not exit the server.
                    //instead, we need run Node directly and run the npx script
                    //file. that seems to exit with stop(true).
                    pendingRunProject = project;
                    pendingRunCommand = null;
                    pendingRunFolder = null;
			        this.start(new <String>[[EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH, "run", "lime", "build", project.limeTargetPlatform, "-debug"].join(" ")], project.folderLocation);
                }
                else
                {
			        this.startDebug(new <String>[[EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH, "run", "lime", "test", project.limeTargetPlatform].join(" ")], project.folderLocation);
                }
            }
            else
            {
                var buildCommand:String = [EnvironmentExecPaths.HAXE_ENVIRON_EXEC_PATH, project.getHXML().split("\n").join(" ")].join(" ");
                switch(project.haxeOutput.platform)
                {
                    case HaxeOutputVO.PLATFORM_CSHARP:
                    {
                        var csharpExecutableName:String = project.name + "-Debug";
                        if(Settings.os == "win")
                        {
                            csharpExecutableName += ".exe";
                        }
                        pendingRunProject = project;
                        pendingRunCommand = CommandLineUtil.joinOptions(new <String>[project.haxeOutput.path.fileBridge.resolvePath("bin" + File.separator + csharpExecutableName).fileBridge.nativePath]);
                        pendingRunFolder = project.haxeOutput.path.fileBridge.resolvePath("bin").fileBridge.nativePath;
			            this.start(new <String>[buildCommand], project.folderLocation);
                        break;
                    }
                    case HaxeOutputVO.PLATFORM_CPP:
                    {
                        var cppExecutableName:String = project.name;
                        if(Settings.os == "win")
                        {
                            cppExecutableName += ".exe";
                        }
                        pendingRunProject = project;
                        pendingRunCommand = CommandLineUtil.joinOptions(new <String>[project.haxeOutput.path.fileBridge.resolvePath(cppExecutableName).fileBridge.nativePath]);
                        pendingRunFolder = project.haxeOutput.path.fileBridge.nativePath;
			            this.start(new <String>[buildCommand], project.folderLocation);
                        break;
                    }
                    case HaxeOutputVO.PLATFORM_FLASH_PLAYER:
                    {
                        pendingRunProject = project;
			            this.start(new <String>[buildCommand], project.folderLocation);
                        break;
                    }
                    case HaxeOutputVO.PLATFORM_JAVA:
                    {
                        var jarName:String = project.name + "-Debug.jar";
                        pendingRunProject = project;
                        pendingRunCommand = CommandLineUtil.joinOptions(new <String>[EnvironmentExecPaths.JAVA_ENVIRON_EXEC_PATH, "-jar", project.haxeOutput.path.fileBridge.resolvePath(jarName).fileBridge.nativePath]);
                        pendingRunFolder = project.haxeOutput.path.fileBridge.nativePath;
			            this.start(new <String>[buildCommand], project.folderLocation);
                        break;
                    }
                    case HaxeOutputVO.PLATFORM_NEKO:
                    {
                        pendingRunProject = project;
                        pendingRunCommand = CommandLineUtil.joinOptions(new <String>[EnvironmentExecPaths.NEKO_ENVIRON_EXEC_PATH, project.haxeOutput.path.fileBridge.nativePath]);
                        pendingRunFolder = project.haxeOutput.path.fileBridge.parent.fileBridge.nativePath;
			            this.start(new <String>[buildCommand], project.folderLocation);
                        break;
                    }
                    default:
                    {
                        error("Haxe build and run failed. This command is not supported on platform \"" + project.haxeOutput.platform + "\".");
                    }
                }
            }
		}
		
		private function haxeBuildDebugHandler(event:Event):void
		{
            var project:HaxeProjectVO = model.activeProject as HaxeProjectVO;
            if (!project)
            {
                return;
            }
            pendingRunProject = null;
            pendingRunCommand = null;
            pendingRunFolder = null;
            pendingDebug = false;
            clearOutput();

            if(project.isLime)
            {
			    this.start(new <String>[[EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH, "run", "lime", "build", project.limeTargetPlatform, "-debug"].join(" ")], project.folderLocation);
            }
            else
            {
                var buildCommand:String = [EnvironmentExecPaths.HAXE_ENVIRON_EXEC_PATH, "--debug", project.getHXML().split("\n").join(" ")].join(" ");
                if(project.haxeOutput.platform == HaxeOutputVO.PLATFORM_FLASH_PLAYER ||
                    project.haxeOutput.platform == HaxeOutputVO.PLATFORM_AIR ||
                    project.haxeOutput.platform == HaxeOutputVO.PLATFORM_AIR_MOBILE)
                {
                    //required for Flash/AIR debugger
                    buildCommand += " -D fdb";
                }
			    this.start(new <String>[buildCommand], project.folderLocation);
            }
		}
		
		private function haxeBuildReleaseHandler(event:Event):void
		{
            var project:HaxeProjectVO = model.activeProject as HaxeProjectVO;
            if (!project)
            {
                return;
            }
            pendingRunProject = null;
            pendingRunCommand = null;
            pendingRunFolder = null;
            pendingDebug = false;
            clearOutput();

            if(project.isLime)
            {
			    this.start(new <String>[[EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH, "run", "lime", "build", project.limeTargetPlatform, "-final"].join(" ")], project.folderLocation);
            }
            else
            {
			    this.start(new <String>[[EnvironmentExecPaths.HAXE_ENVIRON_EXEC_PATH, project.getHXML().split("\n").join(" ")].join(" ")], project.folderLocation);
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
			
            currentProject = model.activeProject as HaxeProjectVO;
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

            currentProject = model.activeProject as HaxeProjectVO;
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

        private function debugAfterBuild(project:HaxeProjectVO):void
        {
            var debugCommand:String = "launch";
            var debugAdapterType:String = null;
            var launchArgs:Object = {};
            if(project.isLime)
            {
                switch(project.limeTargetPlatform)
                {
                    case HaxeProjectVO.LIME_PLATFORM_HTML5:
                    {
                        var webRoot:FileLocation = project.folderLocation.fileBridge
                            .resolvePath("bin" + File.separator + "html5" + File.separator + "bin");
                        launchArgs["name"] = "Moonshine Chrome Launch";
                        launchArgs["file"] = webRoot.resolvePath("index.html").fileBridge.nativePath;
                        //launchArgs["url"] = "http://localhost:3000";
			            //launchArgs["webRoot"] = webRoot.fileBridge.nativePath;
                        //enable for debug logging to a file
                        //launchArgs["trace"] = true;
                        debugAdapterType = "chrome";
                        break;
                    }
                    case HaxeProjectVO.LIME_PLATFORM_AIR:
                    {
                        //switch to the Adobe AIR application descriptor XML file
                        var swfFile:File = project.folderLocation.fileBridge
                            .resolvePath("bin" + File.separator + "air" + File.separator + "bin" + File.separator + project.name + ".swf").fileBridge.getFile as File;
                        var appDescriptorFile:File = swfFile.parent.resolvePath("application.xml");
                        var generatedAppDescriptorFile:File = swfFile.parent.parent.resolvePath("application.xml");
                        generatedAppDescriptorFile.copyTo(appDescriptorFile, true);

                        launchArgs["name"] = "Moonshine Lime Adobe AIR Launch";
                        launchArgs["program"] = appDescriptorFile.nativePath;
                        debugAdapterType = "swf";
                        break;
                    }
                    case HaxeProjectVO.LIME_PLATFORM_FLASH:
                    {
                        swfFile = project.folderLocation.fileBridge
                            .resolvePath("bin" + File.separator + "flash" + File.separator + "bin" + File.separator + project.name + ".swf").fileBridge.getFile as File;
                        launchArgs["name"] = "Moonshine Lime Flash Player Launch";
                        launchArgs["program"] = swfFile.nativePath;
                        debugAdapterType = "swf";
                        break;
                    }
                    default:
                    {
                        throw new IllegalOperationError("Debugging not supported on Lime target platform: " + project.limeTargetPlatform);
                    }
                }
            }
            else // plain Haxe project
            {
                switch(project.haxeOutput.platform)
                {
                    case HaxeOutputVO.PLATFORM_AIR:
                    case HaxeOutputVO.PLATFORM_AIR_MOBILE:
                    case HaxeOutputVO.PLATFORM_FLASH_PLAYER:
                    {
                        launchArgs["name"] = "Moonshine Haxe Launch";
                        launchArgs["program"] = project.haxeOutput.path.fileBridge.nativePath;
                        debugAdapterType = "swf";
                        break;
                    }
                    default:
                    {
                        throw new IllegalOperationError("Debugging not supported on Haxe target platform: " + project.haxeOutput.platform);
                    }
                }
            }
            dispatcher.dispatchEvent(new DebugAdapterEvent(DebugAdapterEvent.START_DEBUG_ADAPTER,
                project, debugAdapterType, debugCommand, launchArgs));
        }

        private function runAfterBuild(project:HaxeProjectVO, runCommand:String, runFolder:String):void
        {
            warning("Launching Haxe project...");
            if(project.isLime && project.limeTargetPlatform == HaxeProjectVO.LIME_PLATFORM_HTML5)
            {
                findLimeLibpath(project);
            }
            else if(project.haxeOutput.platform == HaxeOutputVO.PLATFORM_FLASH_PLAYER)
            {
                var swfFile:File = project.haxeOutput.path.fileBridge.getFile as File;
				dispatcher.dispatchEvent(
					new SWFLaunchEvent(SWFLaunchEvent.EVENT_LAUNCH_SWF, swfFile, project)
				);
            }
            else if(runCommand)
            {
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
                    if(runFolder)
                    {
                        processInfo.workingDirectory = new File(runFolder);
                    }
                    
                    var process:NativeProcess = new NativeProcess();
                    process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, runProjectProcess_standardOutputDataHandler);
                    process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, runProjectProcess_standardErrorDataHandler);
                    process.addEventListener(NativeProcessExitEvent.EXIT, runProjectProcess_exitHandler);
                    process.start(processInfo);
                }, null, [runCommand]);
            }
            else
            {
                error("Unknown debug command for project: " + project.name);
            }
        }

        private function findLimeLibpath(project:HaxeProjectVO):void
        {
            pendingRunProject = project;
            pendingRunCommand = null;
            pendingRunFolder = null;
            pendingDebug = false;

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
				processInfo.workingDirectory = project.folderLocation.fileBridge.getFile as File;
				
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

            var project:HaxeProjectVO = pendingRunProject;
            var runCommand:String = pendingRunCommand;
            var runFolder:String = pendingRunFolder;
            var run:Boolean = pendingRunProject != null;
            var debug:Boolean = pendingDebug;
            if(!project)
            {
                project = currentProject;
            }
            pendingRunProject = null;
            pendingRunCommand = null;
            pendingRunFolder = null;
            pendingDebug = false;
            currentProject = null;

            if(isLimeHTMLServer)
            {
                dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_DEBUG_ENDED));
                limeHTMLServerNativeProcess = null;
                if(isNaN(event.exitCode))
                {
                    warning("Haxe HTML5 server has been terminated.");
                }
                else if(event.exitCode != 0)
                {
                    warning("Haxe HTML5 server has been terminated with exit code: " + event.exitCode);
                }
            }
            else
            {
                dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
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
                    success("Haxe build has completed successfully.");
                    if(project != null)
                    {
                        dispatcher.dispatchEvent(new RefreshTreeEvent(project.haxeOutput.path.fileBridge.parent));
                    }
                    if(debug)
                    {
                        dispatcher.dispatchEvent(new ProjectEvent(ActionScriptBuildEvent.POSTBUILD, project));
                        debugAfterBuild(project);
                    }
                    else if(run)
                    {
                        runAfterBuild(project, runCommand, runFolder);
                    }
                }
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

            var project:HaxeProjectVO = pendingRunProject;
            pendingRunProject = null;
            pendingRunCommand = null;
            pendingRunFolder = null;
            pendingDebug = false;

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

        private function runProjectProcess_standardOutputDataHandler(event:ProgressEvent):void
        {
            var process:NativeProcess = NativeProcess(event.currentTarget);
            var output:IDataInput = process.standardOutput;
            var data:String = output.readUTFBytes(output.bytesAvailable);
            notice(data);
        }

        private function runProjectProcess_standardErrorDataHandler(event:ProgressEvent):void
        {
            var process:NativeProcess = NativeProcess(event.currentTarget);
            var output:IDataInput = process.standardError;
            var data:String = output.readUTFBytes(output.bytesAvailable);
            error(data);
        }

        private function runProjectProcess_exitHandler(event:NativeProcessExitEvent):void
        {
            running = false;

            if(isNaN(event.exitCode))
            {
                warning("Haxe project has been terminated.");
            }
            else if(event.exitCode != 0)
            {
                warning("Haxe project has been terminated with exit code: " + event.exitCode);
            }
            else
            {
                success("Haxe project has been terminated with exit code: 0");
            }
        }
	}
}