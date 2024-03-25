////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
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
    import actionScripts.plugin.console.ConsoleEvent;
    import actionScripts.plugin.core.compiler.ProjectActionEvent;

    public class HaxeBuildPlugin extends ConsoleBuildPluginBase implements ISettingsProvider
    {
        public static var NAMESPACE:String = "actionScripts.plugins.haxe::HaxeBuildPlugin";

		private static const HXCPP_DEBUG_SERVER_ROOT_PATH:String = "elements/hxcpp-debug-adapter/hxcpp-debug-server";
        private static const HAXEFLAG_MACRO_INJECT_SERVER:String = "--haxeflag=\"--macro hxcpp.debug.jsonrpc.Macro.injectServer()\"";
        private static const DEBUG_SERVER_PORT:int = 3000;

		private var haxePathSetting:PathSetting;
		private var nekoPathSetting:PathSetting;
		private var isProjectHasInvalidPaths:Boolean;
        private var currentProject:HaxeProjectVO;
        private var pendingRunProject:HaxeProjectVO = null;
        private var pendingRunCommand:String = null;
        private var pendingRunFolder:String = null;
        private var pendingDebug:Boolean = false;
		
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
			    //dispatcher.dispatchEvent(new SdkEvent(SdkEvent.CHANGE_HAXE_SDK));
            }
        }

        public function getSettingsList():Vector.<ISetting>
        {
			onSettingsClose();

			haxePathSetting = new PathSetting(this, 'haxePath', 'Haxe Home', true, haxePath, false, false);
			nekoPathSetting = new PathSetting(this, 'nekoPath', 'Neko Home', true, nekoPath, false, false);
			
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

			dispatcher.addEventListener(ProjectActionEvent.BUILD_AND_DEBUG, haxeBuildAndDebugHandler);
			dispatcher.addEventListener(HaxeBuildEvent.BUILD_AND_RUN, haxeBuildAndRunHandler);
			dispatcher.addEventListener(HaxeBuildEvent.BUILD_DEBUG, haxeBuildDebugHandler);
			dispatcher.addEventListener(HaxeBuildEvent.BUILD_RELEASE, haxeBuildReleaseHandler);
			dispatcher.addEventListener(HaxeBuildEvent.CLEAN, haxeCleanHandler);
        }

        override public function deactivate():void
        {
            super.deactivate();

			dispatcher.removeEventListener(ProjectActionEvent.BUILD_AND_DEBUG, haxeBuildAndDebugHandler);
			dispatcher.removeEventListener(HaxeBuildEvent.BUILD_AND_RUN, haxeBuildAndRunHandler);
			dispatcher.removeEventListener(HaxeBuildEvent.BUILD_DEBUG, haxeBuildDebugHandler);
			dispatcher.removeEventListener(HaxeBuildEvent.BUILD_RELEASE, haxeBuildReleaseHandler);
			dispatcher.removeEventListener(HaxeBuildEvent.CLEAN, haxeCleanHandler);
        }

		override protected function checkProjectForInvalidPaths(project:ProjectVO):void
		{
			invalidPaths = [];
			var tmpLocation:FileLocation;

			var hxProject:HaxeProjectVO = project as HaxeProjectVO;
			if (!hxProject)
			{
				return;
			}
			var tmpLocation:FileLocation;
			invalidPaths = [];
			
			checkPathFileLocation(hxProject.folderLocation, "Location");
			if (hxProject.sourceFolder) checkPathFileLocation(hxProject.sourceFolder, "Source Folder");
			
			for each (tmpLocation in hxProject.classpaths)
			{
				checkPathFileLocation(tmpLocation, "Classpath");
			}
			
			onProjectPathsValidated((invalidPaths.length > 0) ? invalidPaths : null);
		}

        private function haxeCleanHandler(event:Event):void
        {
            var project:HaxeProjectVO = model.activeProject as HaxeProjectVO;
            if (!project)
            {
                return;
            }
            if (!UtilsCore.isHaxeAvailable())
            {
                error("Project clean failed: Missing Haxe configuration in Moonshine settings.");
                return;
            }
            if (project.isLime)
            {
                dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, project.projectName, "Cleaning ", false));
                start(Vector.<String>([[EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH, "run", "openfl", "clean", project.limeTargetPlatform].join(" ")]), project.folderLocation);
            }
            else
            {
                error("Project clean not available for this type of Haxe project");
            }
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
			            start(new <String>[[EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH, "run", "lime", "build", project.limeTargetPlatform, "-debug"].join(" ")], project.folderLocation);
                        break;
                    }
                    case HaxeProjectVO.LIME_PLATFORM_WINDOWS:
                    case HaxeProjectVO.LIME_PLATFORM_MACOS:
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
                        commandParts.push("--source=\"" + hxcppDebugServerFolder.nativePath + "\"");
                        commandParts.push(HAXEFLAG_MACRO_INJECT_SERVER);
			            start(new <String>[commandParts.join(" ")], project.folderLocation);
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
			            start(new <String>[[EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH, "run", "lime", "build", project.limeTargetPlatform, "-debug"].join(" ")], project.folderLocation);
                        break;
                    }
                    case HaxeProjectVO.LIME_PLATFORM_AIR:
                    case HaxeProjectVO.LIME_PLATFORM_FLASH:
                    {
                        pendingRunProject = project;
                        pendingRunCommand = null;
                        pendingRunFolder = null;
                        pendingDebug = true;
			            start(new <String>[[EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH, "run", "lime", "build", project.limeTargetPlatform, "-debug"].join(" ")], project.folderLocation);
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
                        start(new <String>[[EnvironmentExecPaths.HAXE_ENVIRON_EXEC_PATH, "--debug", "-D", "fdb", project.getHXML().split("\n").join(" ")].join(" ")], project.folderLocation);
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
                        start(new <String>[[EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH, "run", "lime", "build", project.limeTargetPlatform, "-release"].join(" ")], project.folderLocation);
                        break;
                    }
                    case HaxeProjectVO.LIME_PLATFORM_AIR:
                    case HaxeProjectVO.LIME_PLATFORM_FLASH:
                    {
                        pendingRunProject = project;
                        pendingRunCommand = null;
                        pendingRunFolder = null;
                        pendingDebug = false;
                        start(new <String>[[EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH, "run", "lime", "build", project.limeTargetPlatform, "-release"].join(" ")], project.folderLocation);
                        break;
                    }
                    default:
                    {
			            startLimeTest(new <String>[[EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH, "run", "lime", "test", project.limeTargetPlatform, "-release"].join(" ")], project.folderLocation);
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
			            start(new <String>[buildCommand], project.folderLocation);
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
			            start(new <String>[buildCommand], project.folderLocation);
                        break;
                    }
                    case HaxeOutputVO.PLATFORM_FLASH_PLAYER:
                    {
                        pendingRunProject = project;
			            start(new <String>[buildCommand], project.folderLocation);
                        break;
                    }
                    case HaxeOutputVO.PLATFORM_JAVA:
                    {
                        var jarName:String = project.name + "-Debug.jar";
                        pendingRunProject = project;
                        pendingRunCommand = CommandLineUtil.joinOptions(new <String>[EnvironmentExecPaths.JAVA_ENVIRON_EXEC_PATH, "-jar", project.haxeOutput.path.fileBridge.resolvePath(jarName).fileBridge.nativePath]);
                        pendingRunFolder = project.haxeOutput.path.fileBridge.nativePath;
                        pendingDebug = false;
			            start(new <String>[buildCommand], project.folderLocation);
                        break;
                    }
                    case HaxeOutputVO.PLATFORM_NEKO:
                    {
                        pendingRunProject = project;
                        pendingRunCommand = CommandLineUtil.joinOptions(new <String>[EnvironmentExecPaths.NEKO_ENVIRON_EXEC_PATH, project.haxeOutput.path.fileBridge.nativePath]);
                        pendingRunFolder = project.haxeOutput.path.fileBridge.parent.fileBridge.nativePath;
                        pendingDebug = false;
			            start(new <String>[buildCommand], project.folderLocation);
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
                    case HaxeProjectVO.LIME_PLATFORM_MACOS:
                    case HaxeProjectVO.LIME_PLATFORM_LINUX:
			            var hxcppDebugServerFolder:File = File.applicationDirectory.resolvePath(HXCPP_DEBUG_SERVER_ROOT_PATH);
                        commandParts.push("--source=\"" + hxcppDebugServerFolder.nativePath + "\"");
                        commandParts.push(HAXEFLAG_MACRO_INJECT_SERVER);
                        break;
                }
			    start(new <String>[commandParts.join(" ")], project.folderLocation);
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
			    start(new <String>[buildCommand], project.folderLocation);
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
			    start(new <String>[[EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH, "run", "lime", "build", project.limeTargetPlatform, "-final"].join(" ")], project.folderLocation);
            }
            else
            {
			    start(new <String>[[EnvironmentExecPaths.HAXE_ENVIRON_EXEC_PATH, project.getHXML().split("\n").join(" ")].join(" ")], project.folderLocation);
            }
		}

		override public function start(args:Vector.<String>, buildDirectory:*=null, customSDKs:EnvironmentUtilsCusomSDKsVO=null):void
		{
            dispatcher.dispatchEvent(new ConsoleEvent(ConsoleEvent.SHOW_CONSOLE));
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
                dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, project.projectName, "Building "));
                dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onProjectBuildTerminate);
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
                //these are Lime's defaults if custom values aren't specified
                var outputPath:String = "bin";
                var outputFileNameWithoutExtension:String = "MyApplication";
                var projectFile:FileLocation = project.folderLocation.resolvePath("project.xml");
                if (projectFile.fileBridge.exists)
                {
                    try
                    {
                        var projectXML:XML = new XML(projectFile.fileBridge.read());
                        var xmlOutputPath:String = projectXML.elements("app").attribute("path").toString();
                        if (xmlOutputPath)
                        {
                            outputPath = xmlOutputPath;
                        }
                        var xmlFileName:String = projectXML.elements("app").@file.toString();
                        if (xmlFileName)
                        {
                            outputFileNameWithoutExtension = xmlFileName;
                        }
                        trace(xmlOutputPath, xmlFileName);
                    }
                    catch (e:Error) {}
                }
                switch(project.limeTargetPlatform)
                {
                    case HaxeProjectVO.LIME_PLATFORM_HTML5:
                    {
                        launchArgs["name"] = "Moonshine Lime HTML5 Launch";
                        launchArgs["url"] = "http://localhost:" + DEBUG_SERVER_PORT;
			            launchArgs["webRoot"] = getLimeWebRoot(project, outputPath).fileBridge.nativePath;
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
                    case HaxeProjectVO.LIME_PLATFORM_MACOS:
                    case HaxeProjectVO.LIME_PLATFORM_LINUX:
                    {
                        var cppExecutableRelativePath:String = outputFileNameWithoutExtension;
                        if(Settings.os == "win")
                        {
                            cppExecutableRelativePath += ".exe";
                        }
                        else if (Settings.os == "mac")
                        {
                            cppExecutableRelativePath += ".app" + File.separator + "Contents" + File.separator + "MacOS" + File.separator + cppExecutableRelativePath;
                        }
                        cppExecutableRelativePath = outputPath + File.separator + project.limeTargetPlatform + File.separator + "bin" + File.separator + cppExecutableRelativePath;
                        var cppExeFile:File = project.folderLocation.fileBridge
                            .resolvePath(cppExecutableRelativePath).fileBridge.getFile as File;
                        launchArgs["name"] = "Moonshine Lime HXCPP Launch";
                        launchArgs["program"] = cppExeFile.nativePath;
                        debugAdapterType = "hxcpp";
                        break;
                    }
                    case HaxeProjectVO.LIME_PLATFORM_HASHLINK:
                    {
                        var hlbootDatFile:File = project.folderLocation.fileBridge
                            .resolvePath(outputPath + File.separator + "hl" + File.separator + "bin" + File.separator + "hlboot.dat").fileBridge.getFile as File;
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
                            .resolvePath(outputPath + File.separator + "air" + File.separator + "bin" + File.separator + outputFileNameWithoutExtension + ".swf").fileBridge.getFile as File;
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
                            .resolvePath(outputPath + File.separator + "flash" + File.separator + "bin" + File.separator + outputFileNameWithoutExtension + ".swf").fileBridge.getFile as File;
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

        private function getLimeWebRoot(project:HaxeProjectVO, outputPath:String):FileLocation
        {
            return project.folderLocation.fileBridge
                            .resolvePath(outputPath + File.separator + "html5" + File.separator + "bin");
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
                        //this is Lime's default if a custom value isn't specified
                        var outputPath:String = "bin"; 
                        var projectFile:FileLocation = project.folderLocation.resolvePath("project.xml");
                        if (projectFile.fileBridge.exists)
                        {
                            try
                            {
                                var projectXML:XML = new XML(projectFile.fileBridge.read());
                                var xmlOutputPath:String = projectXML.elements("app").attribute("path").toString();
                                if (xmlOutputPath)
                                {
                                    outputPath = xmlOutputPath;
                                }
                            }
                            catch (e:Error) {}
                        }
                        var webRoot:FileLocation = getLimeWebRoot(project, outputPath);
                        var httpServerEvent:HttpServerEvent = new HttpServerEvent(HttpServerEvent.START_HTTP_SERVER, webRoot, DEBUG_SERVER_PORT);
                        dispatcher.dispatchEvent(httpServerEvent);
                        if(!httpServerEvent.isDefaultPrevented())
                        {
                            //debug adapter can launch/run without debugging
                            startDebugAdapter(project, debug);
                        }
                        break;
                    }
                    case HaxeProjectVO.LIME_PLATFORM_WINDOWS:
                    case HaxeProjectVO.LIME_PLATFORM_MACOS:
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
            stop();
            dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
        }

        override protected function onNativeProcessStandardErrorData(event:ProgressEvent):void
        {
			super.onNativeProcessStandardErrorData(event);
            //stop();
			//dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
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
            else if (event.exitCode != 0)
            {
                warning("Haxe build has been terminated with exit code: " + event.exitCode);
            }
            else
            {
                success("Haxe build has completed successfully.");
                if(project != null && project.haxeOutput.path)
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