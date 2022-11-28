////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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
package actionScripts.plugins.build
{
	import actionScripts.interfaces.IJavaProject;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.java.javaproject.vo.JavaTypes;
	import actionScripts.valueObjects.ProjectVO;

	import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.utils.IDataInput;
    
    import actionScripts.factory.FileLocation;
    import actionScripts.utils.EnvironmentSetupUtils;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.EnvironmentUtilsCusomSDKsVO;
    import actionScripts.valueObjects.Settings;

    public class ConsoleBuildPluginBase extends CompilerPluginBase
    {
        protected var nativeProcess:NativeProcess;
		protected var nativeProcessStartupInfo:NativeProcessStartupInfo;

        public function ConsoleBuildPluginBase()
        {
            super();
        }

        private var _running:Boolean;
        protected function get running():Boolean
        {
            return _running;
        }

        protected function set running(value:Boolean):void
        {
            _running = value;
        }

        override public function activate():void
        {
            super.activate();

            var console:FileLocation = new FileLocation(UtilsCore.getConsolePath());
            nativeProcess = new NativeProcess();
            nativeProcessStartupInfo = new NativeProcessStartupInfo();

            var executable:* = console.fileBridge.getFile;
            nativeProcessStartupInfo.executable = executable;

            addNativeProcessEventListeners();
        }

        override public function deactivate():void
        {
            super.deactivate();

            removeNativeProcessEventListeners();

            nativeProcess = null;
            nativeProcessStartupInfo = null;
        }

        public function start(args:Vector.<String>, buildDirectory:*=null, customSDKs:EnvironmentUtilsCusomSDKsVO=null):void
        {
            if (nativeProcess.running && _running)
            {
                warning("Build is running. Wait for finish...");
                return;
            }
            
			// remove -c or /c 
			// we'll use them later
			var firstArgument:String = args ? args[0].toLowerCase() : null;
			if (firstArgument && 
				(firstArgument == "/c" || firstArgument == "-c"))
			{
				args.shift();
			}
			
			var newArray:Array = new Array().concat(args);
			EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(onEnvironmentPrepared, customSDKs, newArray);
			
			/*
			* @local
			*/
			function onEnvironmentPrepared(value:String):void
			{
                // Check if value is null which is defined by EnvironmentSetupUtils.executeOSX()
                if ( !value ) return;

                if ( !nativeProcess ) {

                    nativeProcess = new NativeProcess();

                } else {

                    if (nativeProcess.running)
                    {
                        removeNativeProcessEventListeners();
                        nativeProcess = new NativeProcess();
                    }

                }
                    
				var processArgs:Vector.<String> = new Vector.<String>;
				if (Settings.os == "win")
				{
					processArgs.push("/c");
					processArgs.push(value);
				}
				else
				{
					processArgs.push("-c");
					processArgs.push(value);
				}
				
				addNativeProcessEventListeners();
				
				//var workingDirectory:File = currentSDK.resolvePath("bin/");
				nativeProcessStartupInfo.arguments = processArgs;
				if (buildDirectory) 
				{
					if (buildDirectory is FileLocation)	nativeProcessStartupInfo.workingDirectory = buildDirectory.fileBridge.getFile;
					else if (buildDirectory is File) nativeProcessStartupInfo.workingDirectory = buildDirectory;
				}
				
				nativeProcess.start(nativeProcessStartupInfo);
				running = true;
			}
        }

        public function stop(forceStop:Boolean = false):void
        {
            if (running || forceStop)
            {
                nativeProcess.exit(forceStop);
            }

            running = false;
        }

        public function complete():void
        {
            running = false;
        }

        protected function stopConsoleBuildHandler(event:Event):void
        {

        }

        protected function startConsoleBuildHandler(event:Event):void
        {

        }

        protected function onNativeProcessStandardOutputData(event:ProgressEvent):void
        {
            print("%s", getDataFromBytes(nativeProcess.standardOutput));
        }

        protected function onNativeProcessIOError(event:IOErrorEvent):void
        {
            error("%s", event.text);
        }

        protected function onNativeProcessStandardErrorData(event:ProgressEvent):void
        {
            error("%s", getDataFromBytes(nativeProcess.standardError));
        }

        protected function onNativeProcessStandardInputClose(event:Event):void
        {

        }

        protected function onNativeProcessExit(event:NativeProcessExitEvent):void
        {
			removeNativeProcessEventListeners();
        }

        protected function getDataFromBytes(data:IDataInput):String
        {
            return data.readUTFBytes(data.bytesAvailable);
        }

        protected function addNativeProcessEventListeners():void
        {
            nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onNativeProcessStandardOutputData);
            nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onNativeProcessStandardErrorData);
            nativeProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onNativeProcessIOError);
            nativeProcess.addEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR, onNativeProcessIOError);
            nativeProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onNativeProcessIOError);
            nativeProcess.addEventListener(Event.STANDARD_INPUT_CLOSE, onNativeProcessStandardInputClose);
            nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, onNativeProcessExit);
        }

        protected function removeNativeProcessEventListeners():void
        {
            nativeProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onNativeProcessStandardOutputData);
            nativeProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, onNativeProcessStandardErrorData);
            nativeProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onNativeProcessIOError);
            nativeProcess.removeEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR, onNativeProcessIOError);
            nativeProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onNativeProcessIOError);
            nativeProcess.removeEventListener(NativeProcessExitEvent.EXIT, onNativeProcessExit);
			running = false;
        }

		public static function checkRequireJava(project:ProjectVO=null):Boolean
		{
			if (!project)
            {
                project = IDEModel.getInstance().activeProject;
            }

            var javaProject:IJavaProject = project as IJavaProject;
			if (javaProject)
			{
				if ((javaProject.jdkType == JavaTypes.JAVA_DEFAULT) &&
                    !UtilsCore.isJavaForTypeaheadAvailable())
				{
					return false;
				}
				if ((javaProject.jdkType == JavaTypes.JAVA_8) &&
                    !UtilsCore.isJava8Present())
				{
					return false;
				}
			}

			if ((project is AS3ProjectVO) &&
					(project as AS3ProjectVO).isDominoVisualEditorProject)
			{
				if (((project as AS3ProjectVO).jdkType == JavaTypes.JAVA_8) &&
						!UtilsCore.isJava8Present())
				{
					return false;
				}
			}

			return true;
		}
    }
}
