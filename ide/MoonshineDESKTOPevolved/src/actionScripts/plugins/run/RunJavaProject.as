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
package actionScripts.plugins.run
{
    import flash.events.Event;
    import flash.events.NativeProcessExitEvent;
    
    import actionScripts.events.RunJavaProjectEvent;
    import actionScripts.events.StatusBarEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
    import actionScripts.plugins.build.ConsoleBuildPluginBase;
    import actionScripts.utils.MavenPomUtil;
    import actionScripts.valueObjects.ConstantsCoreVO;

    public class RunJavaProject extends ConsoleBuildPluginBase
    {
        public function RunJavaProject()
        {
            super();
        }

        override public function get name():String
        {
            return "Run Java Project";
        }

        override public function get author():String
        {
            return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team";
        }

        override public function get description():String
        {
            return "Java build plugin.";
        }

        override public function activate():void
        {
            super.activate();

            dispatcher.addEventListener(RunJavaProjectEvent.RUN_JAVA_PROJECT, startConsoleBuildHandler);
        }

        override public function deactivate():void
        {
            super.deactivate();

            dispatcher.removeEventListener(RunJavaProjectEvent.RUN_JAVA_PROJECT, startConsoleBuildHandler);
        }

        override protected function startConsoleBuildHandler(event:Event):void
        {
			var tmpJavaProject:JavaProjectVO = event ? (event as RunJavaProjectEvent).project : null;
			var javaCommand:Vector.<String>;
            if (tmpJavaProject)
            {
				dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED,
					tmpJavaProject.name,
					"Running "));
				
				// maven project
				warning("Starting application: " + tmpJavaProject.projectName);
				
				var pomPathLocation:FileLocation = new FileLocation(tmpJavaProject.mavenBuildOptions.buildPath)
					.resolvePath("pom.xml");
				
				var projectVersion:String = MavenPomUtil.getProjectVersion(pomPathLocation);
				var jarName:String = tmpJavaProject.projectName.concat("-", projectVersion, ".jar");
				var jarLocation:FileLocation = tmpJavaProject.folderLocation
					.resolvePath("target" + model.fileCore.separator + jarName);
				
				if (jarLocation.fileBridge.exists)
				{
					javaCommand = Vector.<String>(["java -classpath " + jarLocation.fileBridge.nativePath +
						" " + tmpJavaProject.mainClassName]);
					this.start(javaCommand, tmpJavaProject.projectFolder.file);
				}
				else
				{
					error("Project .jar file does not exist: " + jarLocation.fileBridge.nativePath);
				}
            }
        }

        override protected function onNativeProcessExit(event:NativeProcessExitEvent):void
        {
            super.onNativeProcessExit(event);
			
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
            if (!isNaN(event.exitCode))
            {
                var info:String = "Application exited with code: " + event.exitCode;
                warning(info);
            }
        }
    }
}
