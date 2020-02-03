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

	public class JavaProjectPlugin extends PluginBase
	{
		override public function get name():String 			{ return "Java Project Plugin"; }
		override public function get author():String 		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String 	{ return "Java project importing, exporting & scaffolding."; }

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
		
		private function createNewProjectHandler(event:NewProjectEvent):void
		{
			if(!canCreateProject(event))
			{
				return;
			}
			
			model.javaCore.createProject(event);
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