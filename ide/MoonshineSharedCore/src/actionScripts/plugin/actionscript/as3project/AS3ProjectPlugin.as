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
package actionScripts.plugin.actionscript.as3project
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import actionScripts.events.GeneralEvent;
	import actionScripts.events.MenuEvent;
	import actionScripts.events.NewProjectEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.events.WorkerEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEWorker;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.project.ProjectTemplateType;
	import actionScripts.plugin.project.ProjectType;
	import actionScripts.plugin.templating.TemplatingHelper;
	import actionScripts.plugin.templating.event.TemplateEvent;
	import actionScripts.utils.FileCoreUtil;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.GenericSelectableObject;
	import actionScripts.valueObjects.ProjectVO;
	
	import components.popup.NativeExtensionMessagePopup;
	import components.popup.OpenFlexProject;
	import components.popup.ProjectsToOpenSelectionPopup;
	
	public class AS3ProjectPlugin extends PluginBase
	{
		public static const AS3PROJ_AS_AIR:uint = 1;
		public static const AS3PROJ_AS_WEB:uint = 2;
		public static const AS3PROJ_AS_ANDROID:uint = 3;
		public static const AS3PROJ_AS_IOS:uint = 4;
		
		public var activeType:uint = ProjectType.AS3PROJ_AS_AIR;
		
		// projectvo:templatedir
		private var importProjectPopup:OpenFlexProject;
		private var flashBuilderProjectFile:FileLocation;
		private var flashDevelopProjectFile:FileLocation;
		private var nonProjectFolderLocation:FileLocation;
		private var aneMessagePopup:NativeExtensionMessagePopup;
		private var worker:IDEWorker = IDEWorker.getInstance();
		private var projectOpenSelection:ProjectsToOpenSelectionPopup;
		
		override public function get name():String 			{return "AS3 Project Plugin";}
		override public function get author():String 		{return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team";}
		override public function get description():String 	{return "AS3 project importing, exporting & scaffolding.";}
		
		public function AS3ProjectPlugin()
		{
			super();
		}
		
		override public function activate():void
		{
			dispatcher.addEventListener(NewProjectEvent.CREATE_NEW_PROJECT, createAS3Project);
			dispatcher.addEventListener(ProjectEvent.EVENT_IMPORT_FLASHBUILDER_PROJECT, importProject);
			dispatcher.addEventListener(ProjectEvent.EVENT_IMPORT_PROJECT_ARCHIVE, importArchiveProject);
			dispatcher.addEventListener(ProjectEvent.EVENT_IMPORT_PROJECT_NO_BROWSE_DIALOG, importProjectWithoutDialog);
			dispatcher.addEventListener(TemplateEvent.REQUEST_ADDITIONAL_DATA, handleTemplatingDataRequest);
			dispatcher.addEventListener(AS3ProjectVO.NATIVE_EXTENSION_MESSAGE, onNativeExtensionMessage);
			dispatcher.addEventListener(ProjectEvent.SEARCH_PROJECTS_IN_DIRECTORIES, handleEventSearchForProjectsInDirectories, false, 0, true);
			
			super.activate();
		}
		
		override public function deactivate():void
		{
			dispatcher.removeEventListener(NewProjectEvent.CREATE_NEW_PROJECT, createAS3Project);
			dispatcher.removeEventListener(ProjectEvent.EVENT_IMPORT_FLASHBUILDER_PROJECT, importProject);
			dispatcher.removeEventListener(ProjectEvent.EVENT_IMPORT_PROJECT_ARCHIVE, importArchiveProject);
			dispatcher.removeEventListener(ProjectEvent.EVENT_IMPORT_PROJECT_NO_BROWSE_DIALOG, importProjectWithoutDialog);
			dispatcher.removeEventListener(TemplateEvent.REQUEST_ADDITIONAL_DATA, handleTemplatingDataRequest);
			dispatcher.removeEventListener(AS3ProjectVO.NATIVE_EXTENSION_MESSAGE, onNativeExtensionMessage);
			dispatcher.removeEventListener(ProjectEvent.SEARCH_PROJECTS_IN_DIRECTORIES, handleEventSearchForProjectsInDirectories);
			
			super.deactivate();
		}
		
		// If user opens project file, open project automagically
		private function importFDProject(projectFile:FileLocation=null, openWithChoice:Boolean=false, openByProject:ProjectVO=null):void
		{
			// Is file in an already opened project?
			if (checkIfProjectIsAlreadyOpened(projectFile.fileBridge.parent.fileBridge.nativePath)) return;
			
			// Assume user wants to open project by clicking settings file
			openProject(projectFile, openWithChoice, openByProject);
		}
		
		private function importFBProject(openWithChoice:Boolean=false):void
		{
			// Is file in an already opened project?
			if (checkIfProjectIsAlreadyOpened(flashBuilderProjectFile.fileBridge.nativePath)) return;
			
			var p:AS3ProjectVO = model.flexCore.parseFlashBuilder(flashBuilderProjectFile);
			dispatcher.dispatchEvent(
				new ProjectEvent(ProjectEvent.ADD_PROJECT, p, (openWithChoice) ? ProjectEvent.LAST_OPENED_AS_FB_PROJECT : null)
			);
		}
		
		private function checkIfProjectIsAlreadyOpened(path:String):Boolean
		{
			for each (var p:ProjectVO in model.projects)
			{
				if (path == p.folderLocation.fileBridge.nativePath)
				{
					warning("Project already opened. Ignoring.");
					return true;
				}
			}
			
			// project is not opened
			return false;
		}
		
		private function openProject(projectFile:FileLocation, openWithChoice:Boolean=false, openByProject:ProjectVO=null):void
		{
			var project:ProjectVO = openByProject ? openByProject : model.flexCore.parseFlashDevelop(null, projectFile);
			project.projectFile = projectFile;
			
			dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.ADD_PROJECT, project, (openWithChoice) ? ProjectEvent.LAST_OPENED_AS_FD_PROJECT : null));
		}
		
		private function importProject(event:Event):void
		{
			// for AIR
			if (ConstantsCoreVO.IS_AIR)
			{
				model.fileCore.browseForDirectory("Project Directory", searchForProjectsByDirectory, onFileSelectionCancelled);
			}
				// for WEB
			else
			{
				importProjectPopup = new OpenFlexProject();
				importProjectPopup.jumptToLoadProject = MenuEvent(event).data;
				PopUpManager.addPopUp(importProjectPopup, FlexGlobals.topLevelApplication as DisplayObject, false);
				PopUpManager.centerPopUp(importProjectPopup);
			}
		}
		
		private function importArchiveProject(event:Event):void
		{
			model.flexCore.importArchiveProject();
		}
		
		private function importProjectWithoutDialog(event:ProjectEvent):void
		{
			if (!event.anObject) return;
			
			openProjectByDirectory(event.anObject);
		}
		
		private function searchForProjectsByDirectory(dir:Object):void
		{
			if (!worker.hasEventListener(IDEWorker.WORKER_VALUE_INCOMING))
			{
				worker.addEventListener(IDEWorker.WORKER_VALUE_INCOMING, onWorkerValueIncoming, false, 0, true);
			}
			
			// send path instead of file as sending file is expensive
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, null, "Searching for projects", false));
			worker.sendToWorker(WorkerEvent.SEARCH_PROJECTS_IN_DIRECTORIES, getObject());
			
			/*
			* @local
			*/
			function getObject():Object
			{
				var tmpObj:Object = new Object();
				tmpObj.path = (dir is FileLocation) ? (dir as FileLocation).fileBridge.nativePath : dir.nativePath;
				tmpObj.maxDepthCount = ConstantsCoreVO.MAX_DEPTH_COUNT_IN_PROJECT_SEARCH;
				return tmpObj;
			}
		}
		
		private function onFileSelectionCancelled():void
		{
			/*event.target.removeEventListener(Event.SELECT, openFile);
			event.target.removeEventListener(Event.CANCEL, onFileSelectionCancelled);*/
		}
		
		private function openProjectByDirectory(dir:Object):void
		{
			//onFileSelectionCancelled(event);
			// probable termination due to error at objC side
			if (!dir) return;
			
			var isFBProject: Boolean;
			var isFDProject: Boolean;
			flashDevelopProjectFile = model.flexCore.testFlashDevelop(dir);
			flashBuilderProjectFile = model.flexCore.testFlashBuilder(dir);
			if (flashBuilderProjectFile) isFBProject = true;
			if (flashDevelopProjectFile) isFDProject = true;
			
			// for Java, Grails, and Haxe projects
			if (!flashBuilderProjectFile && !flashDevelopProjectFile)
			{
				flashDevelopProjectFile = model.javaCore.testJava(dir);
				if (flashDevelopProjectFile)
				{
					importFDProject(flashDevelopProjectFile, false, model.javaCore.parseJava(new FileLocation(dir.nativePath)));
					return;
				}
				flashDevelopProjectFile = model.groovyCore.testGrails(dir);
				if (flashDevelopProjectFile)
				{
					importFDProject(flashDevelopProjectFile, false, model.groovyCore.parseGrails(new FileLocation(dir.nativePath), null, flashDevelopProjectFile));
					return;
				}
				flashDevelopProjectFile = model.haxeCore.testHaxe(dir);
				if (flashDevelopProjectFile)
				{
					importFDProject(flashDevelopProjectFile, false, model.haxeCore.parseHaxe(new FileLocation(dir.nativePath)));
					return;
				}
			}
			
			if (!isFBProject && !isFDProject)
			{
				nonProjectFolderLocation = new FileLocation(dir.nativePath);
				Alert.show("This directory is missing the Moonshine project configuration files. Do you want to generate a new project by locating existing source?", "Error!", Alert.YES|Alert.NO, null, onExistingSourceProjectConfirm);
			}
			else if (isFBProject && isFDProject)
			{
				// @devsena
				// check change log in AS3ProjectVO.as against
				// commenting the following process
				
				/*Alert.okLabel = "Flash Builder Project";
				Alert.yesLabel = "FlashDevelop Project";
				Alert.buttonWidth = 150;
				
				Alert.show("Project directory contains different types of Flex projects. Please, choose an option how you want it to be open.", "Project Type Choice", Alert.OK|Alert.YES|Alert.CANCEL, null, projectChoiceHandler);
				Alert.okLabel = "OK";
				Alert.yesLabel = "YES";
				Alert.buttonWidth = 65;*/
				
				importFDProject(flashDevelopProjectFile);
			}
			else if (isFBProject)
			{
				importFBProject();
			}
			else if (isFDProject)
			{
				importFDProject(flashDevelopProjectFile);
			}
		}
		
		private function onExistingSourceProjectConfirm(event:CloseEvent):void
		{
			if (event.detail == Alert.YES)
			{
				createAS3Project(new NewProjectEvent("", "as3proj", null, nonProjectFolderLocation));
			}
			
			nonProjectFolderLocation = null;
		}
		
		private function projectChoiceHandler(event:CloseEvent):void
		{
			setTimeout(function():void
			{
				if (event.detail == Alert.OK) importFBProject(true);
				else if (event.detail == Alert.YES) importFDProject(flashDevelopProjectFile, true);
			}, 300);
		}
		
		private function handleTemplatingDataRequest(event:TemplateEvent):void
		{
			if (TemplatingHelper.getExtension(event.template) == "as")
			{
				if (ConstantsCoreVO.IS_AIR && event.location)
				{
					// Find project it belongs to
					for each (var project:ProjectVO in model.projects)
					{
						if (project is AS3ProjectVO && project.projectFolder.containsFile(event.location))
						{
							// Populate templating data
							event.templatingData = getTemplatingData(event.location, project as AS3ProjectVO);
							return;
						}
					}
				}
				
				// If nothing is found - guess the data
				event.templatingData = {};
				event.templatingData['$projectName'] = "New";
				event.templatingData['$packageName'] = "";
				event.templatingData['$fileName'] = "New";
			}
		}
		
		private function getTemplatingData(file:FileLocation, project:AS3ProjectVO):Object
		{
			var toRet:Object = {};
			toRet['$projectName'] = project.name;
			
			// Figure out package name
			if (ConstantsCoreVO.IS_AIR)
			{
				for each (var dir:FileLocation in project.classpaths)
				{
					if (FileCoreUtil.contains(dir, flashBuilderProjectFile))
					{
						// Convert path to package name in dot-style
						var relativePath:String = dir.fileBridge.getRelativePath(flashBuilderProjectFile);
						var packagePath:String = relativePath.substring(0, relativePath.indexOf(flashBuilderProjectFile.fileBridge.name));
						if (packagePath.charAt(packagePath.length-1) == model.fileCore.separator)
						{
							packagePath = packagePath.substring(0, packagePath.length-1);
						}
						var packageName:String = packagePath.split(model.fileCore.separator).join(".");
						toRet['$packageName'] = packageName; 
						break;
					}
				}
				
				var name:String = flashBuilderProjectFile.fileBridge.name.split(".")[0];
				toRet['$fileName'] = name;
			}
			
			return toRet;
		}
		
		// Create new AS3 Project
		private function createAS3Project(event:NewProjectEvent):void
		{
			if (!canCreateProject(event) && event.settingsFile)
			{
				return;
			}
			
			model.flexCore.createProject(event);
		}
		
		private function onNativeExtensionMessage(event:Event):void
		{
			if (!aneMessagePopup)
			{
				aneMessagePopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, NativeExtensionMessagePopup) as NativeExtensionMessagePopup;
				aneMessagePopup.addEventListener(CloseEvent.CLOSE, onAneMessageClosed, false, 0, true);
				PopUpManager.centerPopUp(aneMessagePopup);
			}
			else
			{
				PopUpManager.bringToFront(aneMessagePopup);
			}
		}
		
		private function onAneMessageClosed(event:CloseEvent):void
		{
			aneMessagePopup.removeEventListener(CloseEvent.CLOSE, onAneMessageClosed);
			aneMessagePopup = null;
		}
		
		private function canCreateProject(event:NewProjectEvent):Boolean
		{
			var projectTemplateName:String = event.templateDir.fileBridge.name;
			return projectTemplateName.indexOf(ProjectTemplateType.VISUAL_EDITOR) == -1 &&
				projectTemplateName.indexOf(ProjectTemplateType.JAVA) == -1 &&
				projectTemplateName.indexOf(ProjectTemplateType.GRAILS) == -1 &&
				projectTemplateName.indexOf(ProjectTemplateType.HAXE) == -1;
		}
		
		protected function handleEventSearchForProjectsInDirectories(event:ProjectEvent):void
		{
			searchForProjectsByDirectory(event.anObject);
		}
		
		protected function onWorkerValueIncoming(event:GeneralEvent):void
		{
			switch (event.value.event)
			{
				case WorkerEvent.FOUND_PROJECTS_IN_DIRECTORIES:
					// remove the listener 
					// we'll re-add when again needed
					worker.removeEventListener(IDEWorker.WORKER_VALUE_INCOMING, onWorkerValueIncoming);
					
					dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
					loadOrReportOnRepositoryProjects(event.value.value.value);
					break;
			}
		}
		
		private function loadOrReportOnRepositoryProjects(workerData:Object):void
		{
			var projectFiles:Array = workerData.foundProjectsInDirectories;
			if (projectFiles.length == 0)
			{
				openProjectByDirectory(model.fileCore.getFileByPath(workerData.path));
			}
			else if ((projectFiles.length == 1) && projectFiles[0].isRoot)
			{
				// open the only project to sidebar
				openProjectByDirectory(model.fileCore.getFileByPath(projectFiles[0].projectFile.nativePath).parent);
			}
			else
			{
				var tmpCollection:ArrayCollection = new ArrayCollection();
				var tmpSelectableObject:GenericSelectableObject;
				var repositoryRootFile:Object = model.fileCore.getFileByPath(workerData.path);
				var configurationParent:Object;
				for each (var projectRefFile:Object in projectFiles)
				{
					configurationParent = model.fileCore.getFileByPath(projectRefFile.projectFile.nativePath).parent;
					tmpSelectableObject = new GenericSelectableObject(true);
					tmpSelectableObject.data = {
						name: repositoryRootFile.getRelativePath(configurationParent, true),
							path: projectRefFile.projectFile.nativePath
					};
					tmpCollection.addItem(tmpSelectableObject);
				}
				
				openProjectSelectionWindow(tmpCollection, repositoryRootFile);
			}
		}
		
		private function openProjectSelectionWindow(collection:ArrayCollection, repositoryRootFile:Object):void
		{
			if (!projectOpenSelection)
			{
				projectOpenSelection = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, ProjectsToOpenSelectionPopup, true) as ProjectsToOpenSelectionPopup;
				projectOpenSelection.title = "Select Projects to Open";
				projectOpenSelection.projects = collection;
				projectOpenSelection.repositoryRoot = repositoryRootFile.nativePath;
				projectOpenSelection.addEventListener(CloseEvent.CLOSE, onOpenProjectsWindowClosed);
				
				PopUpManager.centerPopUp(projectOpenSelection);
			}
			else
			{
				PopUpManager.bringToFront(projectOpenSelection);
			}
		}
		
		private function onOpenProjectsWindowClosed(event:CloseEvent):void
		{
			if (projectOpenSelection.isSubmit)
			{
				var projects:ArrayCollection = projectOpenSelection.projects;
				for each (var item:GenericSelectableObject in projects)
				{
					if (item.isSelected)
					{
						openProjectByDirectory(model.fileCore.getFileByPath(item.data.path).parent);
					}
				}
			}
			
			projectOpenSelection.removeEventListener(CloseEvent.CLOSE, onOpenProjectsWindowClosed);
			projectOpenSelection = null;
		}
	}
}