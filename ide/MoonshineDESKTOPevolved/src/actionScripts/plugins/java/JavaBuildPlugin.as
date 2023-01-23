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
package actionScripts.plugins.java
{
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.core.compiler.JavaBuildEvent;
    import actionScripts.events.MavenBuildEvent;
    import flash.events.Event;
    import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
    import actionScripts.events.GradleBuildEvent;
    import actionScripts.plugin.build.MavenBuildStatus;
    import actionScripts.utils.UtilsCore;
    import actionScripts.events.RunJavaProjectEvent;
    import actionScripts.valueObjects.ConstantsCoreVO;

    public class JavaBuildPlugin extends PluginBase
    {
        override public function get name():String
        {
            return "Java Build Setup";
        }

        override public function get author():String
        {
            return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team";
        }

        override public function get description():String
        {
            return "Java Build Plugin.";
        }

        public function JavaBuildPlugin()
        {
            super();
        }

        override public function activate():void
        {
            super.activate();

			dispatcher.addEventListener(JavaBuildEvent.JAVA_BUILD, javaBuildHandler);
			dispatcher.addEventListener(JavaBuildEvent.BUILD_AND_RUN, buildAndRunHandler);
			dispatcher.addEventListener(JavaBuildEvent.CLEAN, cleanHandler);
			dispatcher.addEventListener(MavenBuildEvent.MAVEN_BUILD_COMPLETE, mavenBuildCompleteHandler);
        }

        override public function deactivate():void
        {
            super.deactivate();

			dispatcher.removeEventListener(JavaBuildEvent.JAVA_BUILD, javaBuildHandler);
			dispatcher.removeEventListener(JavaBuildEvent.BUILD_AND_RUN, buildAndRunHandler);
			dispatcher.removeEventListener(JavaBuildEvent.CLEAN, cleanHandler);
			dispatcher.removeEventListener(MavenBuildEvent.MAVEN_BUILD_COMPLETE, mavenBuildCompleteHandler);
        }

		private function javaBuildHandler(event:Event):void
		{
			var javaProject:JavaProjectVO = model.activeProject as JavaProjectVO;
			if (javaProject && javaProject.hasGradleBuild())
			{
				dispatcher.dispatchEvent(new Event(GradleBuildEvent.START_GRADLE_BUILD));
			}
			else if (javaProject)
			{
				dispatcher.dispatchEvent(new Event(MavenBuildEvent.START_MAVEN_BUILD));
			}
		}

		private function buildAndRunHandler(event:Event):void
		{
			var javaProject:JavaProjectVO = model.activeProject as JavaProjectVO;
			if (javaProject)
			{
				if (!javaProject.mainClassName)
				{
					warning("Select main application class");
				}
				if (javaProject.hasGradleBuild())
				{
					dispatcher.dispatchEvent(new GradleBuildEvent(GradleBuildEvent.START_GRADLE_BUILD, model.activeProject.projectName,
							MavenBuildStatus.STARTED, javaProject.folderLocation.fileBridge.nativePath, null, javaProject.gradleBuildOptions.getCommandLine()));
				}
				else
				{
					dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.START_MAVEN_BUILD, model.activeProject.projectName,
							MavenBuildStatus.STARTED, javaProject.folderLocation.fileBridge.nativePath, null, javaProject.mavenBuildOptions.getCommandLine()));
				}
			}
		}

		private function cleanHandler(event:Event):void
		{
			var javaProject:JavaProjectVO = model.activeProject as JavaProjectVO;
			if (!javaProject)
			{
				return;
			}
			if (javaProject.hasGradleBuild())
			{
				dispatcher.dispatchEvent(new GradleBuildEvent(GradleBuildEvent.START_GRADLE_BUILD, null,
						MavenBuildStatus.STARTED, javaProject.folderLocation.fileBridge.nativePath, null, ["clean"]));
			}
			else if (javaProject.hasPom())
			{
				dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.START_MAVEN_BUILD, null,
						MavenBuildStatus.STARTED, javaProject.folderLocation.fileBridge.nativePath, null, ["clean"]));
			}
		}

		private function mavenBuildCompleteHandler(event:MavenBuildEvent):void
		{
			runJavaProjectByBuildId(event.buildId);
		}
		
		private function runJavaProjectByBuildId(value:String):void
		{
			var project:JavaProjectVO = UtilsCore.getProjectByName(value) as JavaProjectVO;
			if (project && project.projectName == value)
			{
				dispatcher.dispatchEvent(new RunJavaProjectEvent(RunJavaProjectEvent.RUN_JAVA_PROJECT, project));
			}
		}
	}
}