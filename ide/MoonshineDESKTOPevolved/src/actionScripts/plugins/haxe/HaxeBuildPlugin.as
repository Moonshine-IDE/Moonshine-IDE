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
    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.errors.IllegalOperationError;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.utils.IDataInput;
    
    import actionScripts.events.ApplicationEvent;
    import actionScripts.events.DebugActionEvent;
    import actionScripts.events.ProjectEvent;
    import actionScripts.events.RefreshTreeEvent;
    import actionScripts.events.SdkEvent;
    import actionScripts.events.SettingsEvent;
    import actionScripts.events.StatusBarEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
    import actionScripts.plugin.core.compiler.HaxeBuildEvent;
    import actionScripts.plugin.haxe.hxproject.vo.HaxeOutputVO;
    import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;
    import actionScripts.plugin.settings.ISettingsProvider;
    import actionScripts.plugin.settings.vo.ISetting;
    import actionScripts.plugin.settings.vo.PathSetting;
    import actionScripts.plugins.build.ConsoleBuildPluginBase;
    import actionScripts.plugins.debugAdapter.events.DebugAdapterEvent;
    import actionScripts.plugins.haxelib.utils.HaxelibFinder;
    import actionScripts.plugins.httpServer.events.HttpServerEvent;
    import actionScripts.utils.CommandLineUtil;
    import actionScripts.utils.EnvironmentSetupUtils;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.EnvironmentExecPaths;
    import actionScripts.valueObjects.EnvironmentUtilsCusomSDKsVO;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.valueObjects.Settings;
    import actionScripts.valueObjects.WebBrowserVO;

    public class HaxeBuildPlugin extends ConsoleBuildPluginBase implements ISettingsProvider
    {
		private static const HXCPP_DEBUG_SERVER_ROOT_PATH:String = "elements/hxcpp-debug-adapter/hxcpp-debug-server";
        private static const HAXEFLAG_MACRO_INJECT_SERVER:String = "--haxeflag=\"--macro hxcpp.debug.jsonrpc.Macro.injectServer()\"";
        private static const DEBUG_SERVER_PORT:int = 3000;

		private var haxePathSetting:PathSetting;
		private var nekoPathSetting:PathSetting;
        private var defaultHaxePath:String;
        private var defaultNekoPath:String;
		private var isProjectHasInvalidPaths:Boolean;
        private var currentProject:HaxeProjectVO;
        private var pendingRunProject:HaxeProjectVO = null;
        private var pendingRunCommand:String = null;
        private var pendingRunFolder:String = null;
        private var pendingDebug:Boolean = false;
		
        public function HaxeBuildPlugin()
        {
            super();

			if(!ConstantsCoreVO.IS_MACOS || !ConstantsCoreVO.IS_APP_STORE_VERSION)
			{
                // because most users install Haxe to a standard installation
                // directory, we can try to use it as the default, if it exists.
                // if the user saves a different path (or clears the path) in
                // the settings, these default values will be safely ignored.
                var haxeDir:File = new File(ConstantsCoreVO.IS_MACOS ? "/usr/local/lib/haxe" : "C:\\HaxeToolkit\\haxe");
                var nekoDir:File = new File(ConstantsCoreVO.IS_MACOS ? "/usr/local/lib/neko" : "C:\\HaxeToolkit\\neko");
                defaultHaxePath = (haxeDir.exists && haxeDir.isDirectory) ? haxeDir.nativePath : null;
                defaultNekoPath = (nekoDir.exists && nekoDir.isDirectory) ? nekoDir.nativePath : null;
                if(defaultHaxePath && model.haxePath == null)
                {
                    model.haxePath = defaultHaxePath;
                }
                if(defaultNekoPath && model.nekoPath == null)
                {
                    model.nekoPath = defaultNekoPath;
                }
            }
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

        public function getSettingsList():Vector.<ISetting>
        {
			onSettingsClose();

			haxePathSetting = new PathSetting(this, 'haxePath', 'Haxe Home', true, haxePath, false, false, defaultHaxePath);
			nekoPathSetting = new PathSetting(this, 'nekoPath', 'Neko Home', true, nekoPath, false, false, defaultNekoPath);
			
			return Vector.<ISetting>([
				haxePathSetting,
                nekoPathSetting
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
                    {
                        if(!UtilsCore.isNodeAvailable())
                        {
                            error("A valid Node.js path must be defined to debug project \"" + project.name + "\" on platform \"" + project.limeTargetPlatform + "\".");
                            dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, "actionScripts.plugins.js::JavaScriptPlugin"));
                            return;
                        }
                        pendingRunProject = project;
                        pendingRunCommand = null;
                        pendingRunFolder = null;
                        pendingDebug = true;
			            this.start(new <String>[[EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH, "run", "lime", "build", project.limeTargetPlatform, "-debug"].join(" ")], project.folderLocation);
                        break;
                    }
                    case HaxeProjectVO.LIME_PLATFORM_WINDOWS:
                    case HaxeProjectVO.LIME_PLATFORM_MAC:
                    case HaxeProjectVO.LIME_PLATFORM_LINUX:
                    {
                        if(!UtilsCore.isNodeAvailable())
                        {
                            error("A valid Node.js path must be defined to debug project \"" + project.name + "\" on platform \"" + project.limeTargetPlatform + "\".");
                            dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, "actionScripts.plugins.js::JavaScriptPlugin"));
                            return;
                        }
                        pendingRunProject = project;
                        pendingRunCommand = null;
                        pendingRunFolder = null;
                        pendingDebug = true;
                        var commandParts:Array = [EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH, "run", "lime", "build", project.limeTargetPlatform, "-debug"];
			            var hxcppDebugServerFolder:File = File.applicationDirectory.resolvePath(HXCPP_DEBUG_SERVER_ROOT_PATH);
                        commandParts.push("--source=" + hxcppDebugServerFolder.nativePath);
                        commandParts.push(HAXEFLAG_MACRO_INJECT_SERVER);
			            this.start(new <String>[commandParts.join(" ")], project.folderLocation);
                        break;
                    }
                    case HaxeProjectVO.LIME_PLATFORM_HASHLINK:
                    {
                        if(ConstantsCoreVO.IS_MACOS)
                        {
                            error("Debugging HashLink on macOS is not supported yet. For details, see: https://github.com/vshaxe/hashlink-debugger/issues/28");
                            return;
                        }
                        pendingRunProject = project;
                        pendingRunCommand = null;
                        pendingRunFolder = null;
                        pendingDebug = true;
			            this.start(new <String>[[EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH, "run", "lime", "build", project.limeTargetPlatform, "-debug"].join(" ")], project.folderLocation);
                        break;
                    }
                    case HaxeProjectVO.LIME_PLATFORM_AIR:
                    case HaxeProjectVO.LIME_PLATFORM_FLASH:
                    {
                        pendingRunProject = project;
                        pendingRunCommand = null;
                        pendingRunFolder = null;
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
                switch(project.limeTargetPlatform)
                {
                    case HaxeProjectVO.LIME_PLATFORM_HTML5:
                    {
                        if(!UtilsCore.isNodeAvailable())
                        {
                            error("A valid Node.js path must be defined to run project \"" + project.name + "\" on platform \"" + project.limeTargetPlatform + "\".");
                            dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, "actionScripts.plugins.js::JavaScriptPlugin"));
                            return;
                        }
                        pendingRunProject = project;
                        pendingRunCommand = null;
                        pendingRunFolder = null;
                        pendingDebug = false;
                        this.start(new <String>[[EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH, "run", "lime", "build", project.limeTargetPlatform, "-release"].join(" ")], project.folderLocation);
                        break;
                    }
                    case HaxeProjectVO.LIME_PLATFORM_AIR:
                    case HaxeProjectVO.LIME_PLATFORM_FLASH:
                    {
                        pendingRunProject = project;
                        pendingRunCommand = null;
                        pendingRunFolder = null;
                        pendingDebug = false;
                        this.start(new <String>[[EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH, "run", "lime", "build", project.limeTargetPlatform, "-release"].join(" ")], project.folderLocation);
                        break;
                    }
                    default:
                    {
			            this.startLimeTest(new <String>[[EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH, "run", "lime", "test", project.limeTargetPlatform, "-release"].join(" ")], project.folderLocation);
                    }
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
                        pendingDebug = false;
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
                        pendingDebug = false;
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
                        pendingDebug = false;
			            this.start(new <String>[buildCommand], project.folderLocation);
                        break;
                    }
                    case HaxeOutputVO.PLATFORM_NEKO:
                    {
                        pendingRunProject = project;
                        pendingRunCommand = CommandLineUtil.joinOptions(new <String>[EnvironmentExecPaths.NEKO_ENVIRON_EXEC_PATH, project.haxeOutput.path.fileBridge.nativePath]);
                        pendingRunFolder = project.haxeOutput.path.fileBridge.parent.fileBridge.nativePath;
                        pendingDebug = false;
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
                var commandParts:Array = [EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH, "run", "lime", "build", project.limeTargetPlatform, "-debug"];
                switch(project.limeTargetPlatform)
                {
                    case HaxeProjectVO.LIME_PLATFORM_WINDOWS:
                    case HaxeProjectVO.LIME_PLATFORM_MAC:
                    case HaxeProjectVO.LIME_PLATFORM_LINUX:
			            var hxcppDebugServerFolder:File = File.applicationDirectory.resolvePath(HXCPP_DEBUG_SERVER_ROOT_PATH);
                        commandParts.push("--source=" + hxcppDebugServerFolder.nativePath);
                        commandParts.push(HAXEFLAG_MACRO_INJECT_SERVER);
                        break;
                }
			    this.start(new <String>[commandParts.join(" ")], project.folderLocation);
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

		override public function start(args:Vector.<String>, buildDirectory:*, customSDKs:EnvironmentUtilsCusomSDKsVO=null):void
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
        
        public function startLimeTest(args:Vector.<String>, buildDirectory:*):void
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
                dispatcher.addEventListener(DebugActionEvent.DEBUG_STOP, onDebugStop, false, 0, true);
			    dispatcher.addEventListener(ApplicationEvent.APPLICATION_EXIT, onApplicationExit, false, 0, true);
            }
		}

        private function startDebugAdapter(project:HaxeProjectVO, debug:Boolean):void
        {
            var debugCommand:String = "launch";
            var debugAdapterType:String = null;
            var launchArgs:Object = {};
            if(!debug)
            {
                launchArgs["noDebug"] = true;
            }
            if(project.isLime)
            {
                switch(project.limeTargetPlatform)
                {
                    case HaxeProjectVO.LIME_PLATFORM_HTML5:
                    {
                        launchArgs["name"] = "Moonshine Lime HTML5 Launch";
                        launchArgs["url"] = "http://localhost:" + DEBUG_SERVER_PORT;
			            launchArgs["webRoot"] = getLimeWebRoot(project).fileBridge.nativePath;
                        //enable for debug logging to a file
                        //launchArgs["trace"] = true;
                        for(var i:int = 0; i < ConstantsCoreVO.TEMPLATES_WEB_BROWSERS.length; i++)
                        {
                            var webBrowser:WebBrowserVO = WebBrowserVO(ConstantsCoreVO.TEMPLATES_WEB_BROWSERS.getItemAt(i));
                            if(webBrowser.name == project.runWebBrowser)
                            {
                                debugAdapterType = webBrowser.debugAdapterType;
                            }
                        }
                        if(debugAdapterType == null)
                        {
                            debugAdapterType = "chrome";
                        }
                        break;
                    }
                    case HaxeProjectVO.LIME_PLATFORM_WINDOWS:
                    case HaxeProjectVO.LIME_PLATFORM_MAC:
                    case HaxeProjectVO.LIME_PLATFORM_LINUX:
                    {
                        var cppExecutableName:String = project.name;
                        if(Settings.os == "win")
                        {
                            cppExecutableName += ".exe";
                        }
                        var cppExeFile:File = project.folderLocation.fileBridge
                            .resolvePath("bin" + File.separator + project.limeTargetPlatform + File.separator + "bin" + File.separator + cppExecutableName).fileBridge.getFile as File;
                        launchArgs["name"] = "Moonshine Lime HXCPP Launch";
                        launchArgs["program"] = cppExeFile.nativePath;
                        debugAdapterType = "hxcpp";
                        break;
                    }
                    case HaxeProjectVO.LIME_PLATFORM_HASHLINK:
                    {
                        var hlbootDatFile:File = project.folderLocation.fileBridge
                            .resolvePath("bin" + File.separator + "hl" + File.separator + "bin" + File.separator + "hlboot.dat").fileBridge.getFile as File;
                        launchArgs["name"] = "Moonshine Lime HashLink Launch";
                        launchArgs["program"] = hlbootDatFile.nativePath;
                        launchArgs["cwd"] = hlbootDatFile.parent.nativePath;
                        var hlClassPaths:Array = [];
                        project.classpaths.forEach(function(classPath:FileLocation, index:int, source:Vector.<FileLocation>):void
                        {
                            hlClassPaths[index] = classPath.fileBridge.nativePath;
                        });
                        launchArgs["classPaths"] = hlClassPaths;
                        debugAdapterType = "hl";
                        
                        HaxelibFinder.find("lime", function(limePath:String):void
                        {
                            if(!limePath)
                            {
                                error("Lime not found. HashLink debug launch failed.");
                                return;
                            }
                            var hlRoot:File = new File(limePath).resolvePath("templates/bin/hl");
                            var hlExe:File = null;
                            switch(Settings.os)
                            {
                                case "win":
                                {
                                    hlExe = hlRoot.resolvePath("windows/hl.exe");
                                    break;
                                }
                                case "mac":
                                {
                                    hlExe = hlRoot.resolvePath("mac/hl");
                                    break;
                                }
                                case "lin":
                                {
                                    hlExe = hlRoot.resolvePath("linux/hl");
                                    break;
                                }
                                default:
                                {
                                    error("Unknown operating system. HashLink debug launch failed.");
                                    return;
                                }
                            }
                            launchArgs["hl"] = hlExe.nativePath;
                            
                            dispatcher.dispatchEvent(new DebugAdapterEvent(DebugAdapterEvent.START_DEBUG_ADAPTER,
                                project, debugAdapterType, debugCommand, launchArgs));
                        });
                        return;
                        break;
                    }
                    case HaxeProjectVO.LIME_PLATFORM_AIR:
                    {
                        //switch to the Adobe AIR application descriptor XML file
                        var swfFile:File = project.folderLocation.fileBridge
                            .resolvePath("bin" + File.separator + "air" + File.separator + "bin" + File.separator + project.name + ".swf").fileBridge.getFile as File;
                        var appDescriptorFile:File = swfFile.parent.parent.resolvePath("application.xml");

                        launchArgs["name"] = "Moonshine Lime Adobe AIR Launch";
                        launchArgs["program"] = appDescriptorFile.nativePath;
                        launchArgs["rootDirectory"] = swfFile.parent.nativePath;
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

        private function getLimeWebRoot(project:HaxeProjectVO):FileLocation
        {
            return project.folderLocation.fileBridge
                            .resolvePath("bin" + File.separator + "html5" + File.separator + "bin");
        }

        private function runAfterBuild(project:HaxeProjectVO, runCommand:String, runFolder:String, debug:Boolean):void
        {
            warning("Launching Haxe project...");
            if(runCommand)
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
                return;
            }

            if(project.isLime)
            {
                switch(project.limeTargetPlatform)
                {
                    case HaxeProjectVO.LIME_PLATFORM_HTML5:
                    {
                        var httpServerEvent:HttpServerEvent = new HttpServerEvent(HttpServerEvent.START_HTTP_SERVER, getLimeWebRoot(project), DEBUG_SERVER_PORT);
                        dispatcher.dispatchEvent(httpServerEvent);
                        if(!httpServerEvent.isDefaultPrevented())
                        {
                            //debug adapter can launch/run without debugging
                            startDebugAdapter(project, debug);
                        }
                        break;
                    }
                    case HaxeProjectVO.LIME_PLATFORM_WINDOWS:
                    case HaxeProjectVO.LIME_PLATFORM_MAC:
                    case HaxeProjectVO.LIME_PLATFORM_LINUX:
                    case HaxeProjectVO.LIME_PLATFORM_HASHLINK:
                    case HaxeProjectVO.LIME_PLATFORM_AIR:
                    case HaxeProjectVO.LIME_PLATFORM_FLASH:
                    {
                        startDebugAdapter(project, debug);
                        break;
                    }
                    default:
                    {
                        error("Cannot run Haxe project \"" + project.name + "\" on platform \"" + project.limeTargetPlatform + "\".");
                    }
                }
            }
            else
            {
                switch(project.haxeOutput.platform)
                {
                    case HaxeOutputVO.PLATFORM_FLASH_PLAYER:
                    {
                        startDebugAdapter(project, debug);
                        break;
                    }
                    default:
                    {
                        
                        error("Cannot run Haxe project \"" + project.name + "\" on platform \"" + project.haxeOutput.platform + "\".");
                    }
                }
            }
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

			dispatcher.removeEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onProjectBuildTerminate);
			dispatcher.removeEventListener(DebugActionEvent.DEBUG_STOP, onDebugStop);
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
                dispatcher.dispatchEvent(new ProjectEvent(ActionScriptBuildEvent.POSTBUILD, project));
                if(debug || run)
                {
                    runAfterBuild(project, runCommand, runFolder, debug);
                }
            }
        }

        private function onProjectBuildTerminate(event:StatusBarEvent):void
        {
            stop();
        }

        private function onDebugStop(event:DebugActionEvent):void
        {
            stop();
        }

        private function onApplicationExit(event:ApplicationEvent):void
        {
            dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_TERMINATE));
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