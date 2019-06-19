////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.clean
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	import actionScripts.controllers.DataAgent;
	import actionScripts.events.RefreshTreeEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.plugin.core.compiler.ProjectActionEvent;
	import actionScripts.plugin.groovy.grailsproject.vo.GrailsProjectVO;
	import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
	import actionScripts.plugin.project.ProjectType;
	import actionScripts.plugins.build.ConsoleBuildPluginBase;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.EnvironmentExecPaths;
	import actionScripts.valueObjects.ProjectVO;
	
	import components.popup.SelectOpenedFlexProject;
	import components.views.project.TreeView;
	import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;

	public class CleanProject extends ConsoleBuildPluginBase implements IPlugin
	{
		private var loader: DataAgent;
		private var selectProjectPopup:SelectOpenedFlexProject;

		private var currentTargets:Array;
		private var folderCount:int;
		private var currentProjectName:String;
		private var currentCleanType:uint;

		override public function get name():String { return "Clean Project"; }
		override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String { return "Clean swf file from output dir."; }
		
		public function CleanProject()
		{
			super();

			currentTargets = [];
		}
		
		override public function activate():void 
		{
			super.activate();
			dispatcher.addEventListener(ProjectActionEvent.CLEAN_PROJECT, cleanSelectedProject);
		}
		
		override public function deactivate():void 
		{
			super.deactivate();
			dispatcher.removeEventListener(ProjectActionEvent.CLEAN_PROJECT, cleanSelectedProject);
		}

		private function cleanSelectedProject(e:Event):void
		{
			//check if any project is selected in project view or not
			checkProjectCount();	
		}
		
		private function checkProjectCount():void
		{
			if (model.projects.length > 1)
			{
				// check if user has selection/select any particular project or not
				if (model.mainView.isProjectViewAdded)
				{
					var tmpTreeView:TreeView = model.mainView.getTreeViewPanel();
					var projectReference:ProjectVO = tmpTreeView.getProjectBySelection();
					if (projectReference)
					{
						cleanActiveProject(projectReference);
						return;
					}
				}
				
				// if above is false open popup for project selection
				selectProjectPopup = new SelectOpenedFlexProject();
				PopUpManager.addPopUp(selectProjectPopup, FlexGlobals.topLevelApplication as DisplayObject, false);
				PopUpManager.centerPopUp(selectProjectPopup);
				selectProjectPopup.addEventListener(SelectOpenedFlexProject.PROJECT_SELECTED, onProjectSelected);
				selectProjectPopup.addEventListener(SelectOpenedFlexProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);				
			}
			else
			{
				cleanActiveProject(model.projects[0] as ProjectVO);	
			}
			
			/*
			* @local
			*/
			function onProjectSelected(event:Event):void
			{
				cleanActiveProject(selectProjectPopup.selectedProject);
				onProjectSelectionCancelled(null);
			}
			
			function onProjectSelectionCancelled(event:Event):void
			{
				selectProjectPopup.removeEventListener(SelectOpenedFlexProject.PROJECT_SELECTED, onProjectSelected);
				selectProjectPopup.removeEventListener(SelectOpenedFlexProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
				selectProjectPopup = null;
			}
		}
		private function cleanActiveProject(project:ProjectVO):void
		{
			cleanProjectData();

			//var pvo:ProjectVO = IDEModel.getInstance().activeProject;
			// Don't compile if there is no project. Don't warn since other compilers might take the job.
			if (!project) return;
			
			if (!ConstantsCoreVO.IS_AIR && !loader)
			{
				print("Clean project: "+ project.name +". Invoking compiler on remote server...");
			}
			else if (ConstantsCoreVO.IS_AIR)
			{
				currentProjectName = project.name;

				if (project is AS3ProjectVO)
				{
					currentCleanType = ProjectType.AS3PROJ_AS_AIR;
					cleanAS3Project(project as AS3ProjectVO);
				}
				else if (project is JavaProjectVO)
				{
					currentCleanType = ProjectType.JAVA;
					cleanJavaProject(project as JavaProjectVO);
				}
				else if (project is GrailsProjectVO)
				{
					currentCleanType = ProjectType.JAVA;
					cleanGrailsProject(project as GrailsProjectVO);
				}
				else if (project is HaxeProjectVO)
				{
					currentCleanType = ProjectType.HAXE;
					cleanHaxeProject(project as HaxeProjectVO);
				}
			}
		}

		private function cleanJavaProject(project:JavaProjectVO):void
		{
			if (project.hasGradleBuild())
			{
				if (UtilsCore.isGradleAvailable())
				{
					dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, project.projectName, "Cleaning ", false));
					start(Vector.<String>([EnvironmentExecPaths.GRADLE_ENVIRON_EXEC_PATH +" clean"]), project.folderLocation);
				}
				else
				{
					dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, "Project clean failed: Missing Gradle configuration in Moonshine settings.", false, false, ConsoleOutputEvent.TYPE_ERROR));
				}
			}
			else if (project.hasPom())
			{
				var target:FileLocation = project.folderLocation.resolvePath("target");
				if (target.fileBridge.exists)
				{
					currentTargets.push(target);
					
					target.fileBridge.getFile.addEventListener(IOErrorEvent.IO_ERROR, onCleanProjectIOException);
					target.fileBridge.getFile.addEventListener(Event.COMPLETE, onProjectFolderComplete);
					target.fileBridge.deleteDirectoryAsync(true);
				}
				else
				{
					success("Project files cleaned successfully : " + project.name);
				}
			}
		}
		
		private function cleanGrailsProject(project:GrailsProjectVO):void
		{
			if (UtilsCore.isGrailsAvailable())
			{
				dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, project.projectName, "Cleaning ", false));
				start(Vector.<String>([EnvironmentExecPaths.GRAILS_ENVIRON_EXEC_PATH +" clean"]), project.folderLocation);
			}
			else
			{
				dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, "Project clean failed: Missing Grails configuration in Moonshine settings.", false, false, ConsoleOutputEvent.TYPE_ERROR));
			}
		}

		private function cleanHaxeProject(haxeProject:HaxeProjectVO):void
		{
			//TODO: clean haxe project
		}
		
		override protected function onNativeProcessExit(event:NativeProcessExitEvent):void
		{
			super.onNativeProcessExit(event);
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
			
			if (event.exitCode == 0)
			{
				if (currentCleanType == ProjectType.JAVA)
				{
					dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, "Project cleaned succssfully."));
				}
			}
		}

		private function cleanAS3Project(as3Project:AS3ProjectVO):void
		{
			var outputFile:FileLocation;
			var swfPath:FileLocation;
			var swfFolderPath:FileLocation;

			if (as3Project.swfOutput.path)
			{
				outputFile = as3Project.swfOutput.path;
				swfFolderPath = outputFile.fileBridge.parent;
			}

			if (swfFolderPath.fileBridge.exists)
			{
				var directoryItems:Array = swfFolderPath.fileBridge.getDirectoryListing();
				for each (var directory:Object in directoryItems)
				{
					folderCount++;
					currentTargets.push(swfFolderPath);

					directory.addEventListener(IOErrorEvent.IO_ERROR, onCleanProjectIOException);
					directory.addEventListener(Event.COMPLETE, onProjectFolderComplete);

					if (directory.isDirectory)
					{
						directory.deleteDirectoryAsync(true);
					}
					else
					{
						directory.deleteFileAsync();
					}
				}
			}

			if (as3Project.isFlexJS || as3Project.isRoyale)
			{
				var binFolder:FileLocation = as3Project.folderLocation.resolvePath(as3Project.jsOutputPath).resolvePath("bin");
				if (!binFolder.fileBridge.exists)
				{
					binFolder = as3Project.folderLocation.fileBridge.resolvePath("bin");
				}

				if (binFolder.fileBridge.exists)
				{
					var timeoutValue:uint = setTimeout(function():void
					{
						var jsDebugFolder:FileLocation = binFolder.resolvePath("js-debug");
						var jsDebugFolderExists:Boolean = jsDebugFolder.fileBridge.exists;
						if (jsDebugFolderExists)
						{
							folderCount++;
							currentTargets.push(jsDebugFolder);
						}

						var jsReleaseFolder:FileLocation = binFolder.resolvePath("js-release");
						var jsReleaseFolderExists:Boolean = jsReleaseFolder.fileBridge.exists;
						if (jsReleaseFolderExists)
						{
							folderCount++;
							currentTargets.push(jsReleaseFolder);
						}

						if (jsDebugFolderExists)
						{
							jsDebugFolder.fileBridge.getFile.addEventListener(IOErrorEvent.IO_ERROR, onCleanProjectIOException);
							jsDebugFolder.fileBridge.getFile.addEventListener(Event.COMPLETE, onProjectFolderComplete);
							jsDebugFolder.fileBridge.deleteDirectoryAsync(true);
						}

						if (jsReleaseFolderExists)
						{
							jsReleaseFolder.fileBridge.getFile.addEventListener(IOErrorEvent.IO_ERROR, onCleanProjectIOException);
							jsReleaseFolder.fileBridge.getFile.addEventListener(Event.COMPLETE, onProjectFolderComplete);
							jsReleaseFolder.fileBridge.deleteDirectoryAsync(true);
						}

						if (folderCount == 0)
						{
							success("JavaScript project files cleaned successfully: " + as3Project.name);
						}

						clearTimeout(timeoutValue);
					}, 300);
				}
				else if ((!swfPath || !swfPath.fileBridge.exists) && !binFolder.fileBridge.exists)
				{
					success("Project files cleaned successfully: " + as3Project.name);
				}
			}
		}

		private function cleanProjectData():void
		{
			currentProjectName = null;
			currentTargets.splice(0, currentTargets.length);
			folderCount = 0;
		}

		private function onProjectFolderComplete(event:Event):void
		{
			event.target.removeEventListener(Event.COMPLETE, onProjectFolderComplete);
			event.target.removeEventListener(IOErrorEvent.IO_ERROR, onCleanProjectIOException);

			if (currentTargets)
			{
				folderCount--;
				if (folderCount <= 0)
				{
					for (var i:int = 0; i < currentTargets.length; i++)
					{
						dispatcher.dispatchEvent(new RefreshTreeEvent(currentTargets[i], true));
					}

					success("Project files cleaned successfully: " + currentProjectName);
					cleanProjectData();
				}
			}
		}

        private function onCleanProjectIOException(event:IOErrorEvent):void
        {
            event.target.removeEventListener(IOErrorEvent.IO_ERROR, onCleanProjectIOException);
			error("Cannot delete file or folder: " + event.target.nativePath + "\nError: " + event.text);
        }
	}
}