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