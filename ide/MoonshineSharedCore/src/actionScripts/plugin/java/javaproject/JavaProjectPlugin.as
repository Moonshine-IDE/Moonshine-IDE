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
package actionScripts.plugin.java.javaproject
{
	import flash.events.Event;
	
	import actionScripts.events.GradleBuildEvent;
	import actionScripts.events.MavenBuildEvent;
	import actionScripts.events.NewProjectEvent;
	import actionScripts.events.RunJavaProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.build.MavenBuildStatus;
	import actionScripts.plugin.core.compiler.JavaBuildEvent;
	import actionScripts.plugin.core.compiler.ProjectActionEvent;
	import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
	import actionScripts.plugin.project.ProjectTemplateType;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.plugin.IProjectTypePlugin;
	import actionScripts.plugin.java.javaproject.importer.JavaImporter;
	import flash.filesystem.File;
	import actionScripts.valueObjects.ProjectVO;

	public class JavaProjectPlugin extends PluginBase implements IProjectTypePlugin
	{
		override public function get name():String 			{ return "Java Project Plugin"; }
		override public function get author():String 		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String 	{ return "Java project importing, exporting & scaffolding."; }
		
        protected var executeCreateJavaProject:CreateJavaProject;

		override public function activate():void
		{
			dispatcher.addEventListener(NewProjectEvent.CREATE_NEW_PROJECT, createNewProjectHandler);
			dispatcher.addEventListener(JavaBuildEvent.JAVA_BUILD, javaBuildHandler);
			dispatcher.addEventListener(JavaBuildEvent.BUILD_AND_RUN, buildAndRunHandler);
			dispatcher.addEventListener(ProjectActionEvent.SET_DEFAULT_APPLICATION, setDefaultApplicationHandler);
			dispatcher.addEventListener(MavenBuildEvent.MAVEN_BUILD_COMPLETE, mavenBuildCompleteHandler);

			super.activate();
		}

		override public function deactivate():void
		{
			dispatcher.removeEventListener(NewProjectEvent.CREATE_NEW_PROJECT, createNewProjectHandler);
			dispatcher.removeEventListener(JavaBuildEvent.JAVA_BUILD, javaBuildHandler);
			dispatcher.removeEventListener(JavaBuildEvent.BUILD_AND_RUN, buildAndRunHandler);
			dispatcher.removeEventListener(ProjectActionEvent.SET_DEFAULT_APPLICATION, setDefaultApplicationHandler);
			dispatcher.removeEventListener(MavenBuildEvent.MAVEN_BUILD_COMPLETE, mavenBuildCompleteHandler);

			super.deactivate();
		}

		public function testProjectDirectory(dir:FileLocation):FileLocation
		{
			var result:FileLocation = JavaImporter.test(dir);
			if (!result)
			{
				return null;
			}
			return JavaImporter.getSettingsFile(dir);
		}

		public function parseProject(projectFolder:FileLocation, projectName:String = null, settingsFileLocation:FileLocation = null):ProjectVO
		{
			return JavaImporter.parse(projectFolder, projectName, settingsFileLocation);
		}
		
		private function createNewProjectHandler(event:NewProjectEvent):void
		{
			if(!canCreateProject(event))
			{
				return;
			}
			
			executeCreateJavaProject = new CreateJavaProject(event);
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

		private function setDefaultApplicationHandler(event:ProjectActionEvent):void
		{
			var javaProject:JavaProjectVO = model.activeProject as JavaProjectVO;
			if (javaProject)
			{
				var nameWithoutExtension:String = (event.value as FileLocation).fileBridge.nameWithoutExtension;
				if (javaProject.mainClassName != nameWithoutExtension)
				{
					javaProject.mainClassName = nameWithoutExtension;
					javaProject.mainClassPath = (event.value as FileLocation).fileBridge.nativePath;
					javaProject.saveSettings();
				}
			}
		}

		private function canCreateProject(event:NewProjectEvent):Boolean
        {
            var projectTemplateName:String = event.templateDir.fileBridge.name;
            return projectTemplateName.indexOf(ProjectTemplateType.JAVA) != -1;
        }
	}
}