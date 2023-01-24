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
package actionScripts.plugin.actionscript.as3project
{
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.OpenProjectOptionsVO;

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
	import actionScripts.plugin.genericproj.events.GenericProjectEvent;
	import actionScripts.plugin.project.ProjectTemplateType;
	import actionScripts.plugin.project.ProjectType;
	import actionScripts.plugin.templating.TemplatingHelper;
	import actionScripts.plugin.templating.TemplatingPlugin;
	import actionScripts.plugin.templating.event.TemplateEvent;
	import actionScripts.utils.FileCoreUtil;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.GenericSelectableObject;
	import actionScripts.valueObjects.ProjectVO;
	
	import components.popup.NativeExtensionMessagePopup;
	import components.popup.OpenFlexProject;
	import components.popup.ProjectsToOpenSelectionPopup;
	import actionScripts.plugin.IProjectTypePlugin;
	import actionScripts.plugin.actionscript.as3project.importer.FlashBuilderImporter;
	import actionScripts.plugin.actionscript.as3project.importer.FlashDevelopImporter;
	
	import moonshine.plugin.workspace.events.WorkspaceEvent;
	import actionScripts.ui.menu.vo.MenuItem;
	import actionScripts.ui.menu.vo.ProjectMenuTypes;
	import actionScripts.events.PreviewPluginEvent;
	import actionScripts.events.DominoEvent;
	import actionScripts.events.OnDiskBuildEvent;
	import actionScripts.events.ExportVisualEditorProjectEvent;
	import flash.ui.Keyboard;
	import actionScripts.events.RoyaleApiReportEvent;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	import actionScripts.plugin.core.compiler.ProjectActionEvent;
	import actionScripts.events.MavenBuildEvent;
	import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
	
	public class AS3ProjectPlugin extends PluginBase implements IProjectTypePlugin
	{
		public static const AS3PROJ_AS_AIR:uint = 1;
		public static const AS3PROJ_AS_WEB:uint = 2;
		public static const AS3PROJ_AS_ANDROID:uint = 3;
		public static const AS3PROJ_AS_IOS:uint = 4;
		public static const AS3PROJ_JS_WEB:uint = 5;
		
		public var activeType:uint = ProjectType.AS3PROJ_AS_AIR;
		
		// projectvo:templatedir
		private var importProjectPopup:OpenFlexProject;
		private var flashBuilderProjectFile:FileLocation;
		private var flashDevelopProjectFile:FileLocation;
		private var nonProjectFolderLocation:FileLocation;
		private var aneMessagePopup:NativeExtensionMessagePopup;
		private var worker:IDEWorker = IDEWorker.getInstance();
		private var projectOpenSelection:ProjectsToOpenSelectionPopup;
		private var projectOpeningOptions:OpenProjectOptionsVO;
		private var actionScriptMenu:Vector.<MenuItem>;
		private var libraryMenu:Vector.<MenuItem>;
		private var royaleMenu:Vector.<MenuItem>;
		private var dominoMenu:Vector.<MenuItem>;
		private var veFlex:Vector.<MenuItem>;
		private var vePrimeFaces:Vector.<MenuItem>;
        private var resourceManager:IResourceManager = ResourceManager.getInstance();
		
		override public function get name():String 			{return "AS3 Project Plugin";}
		override public function get author():String 		{return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team";}
		override public function get description():String 	{return "AS3 project importing, exporting & scaffolding.";}

		public function get projectClass():Class
		{
			return AS3ProjectVO;
		}
		
		public function AS3ProjectPlugin()
		{
			super();
		}

		public function getProjectMenuItems(project:ProjectVO):Vector.<MenuItem>
		{
			var as3Project:AS3ProjectVO = AS3ProjectVO(project);
			if (as3Project.isLibraryProject)
			{
				return getASLibraryMenuItems();
			}
			else if (as3Project.isRoyale)
			{
				return getRoyaleMenuItems();
			}
			else if (as3Project.isVisualEditorProject)
			{
				if (as3Project.isPrimeFacesVisualEditorProject)
				{
					return getVisualEditorMenuPrimeFacesItems(as3Project);
				}
				else if(as3Project.isDominoVisualEditorProject)
				{
					return getDominoMenuItems();
				}

				return getVisualEditorMenuFlexItems();
			}
			else
			{
				return getASProjectMenuItems();
			}
		}
		
		override public function activate():void
		{
			dispatcher.addEventListener(NewProjectEvent.CREATE_NEW_PROJECT, createAS3Project);
			dispatcher.addEventListener(ProjectEvent.EVENT_IMPORT_FLASHBUILDER_PROJECT, importProject);
			dispatcher.addEventListener(ProjectEvent.EVENT_IMPORT_PROJECT_ARCHIVE, importArchiveProject);
			dispatcher.addEventListener(ProjectEvent.EVENT_GENERATE_APACHE_ROYALE_PROJECT, generateApacheRoyaleProject);
			//EVENT_GENERATE_APACHE_ROYALE_PROJECT
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
			dispatcher.removeEventListener(ProjectEvent.EVENT_GENERATE_APACHE_ROYALE_PROJECT, generateApacheRoyaleProject);
			dispatcher.removeEventListener(ProjectEvent.EVENT_IMPORT_PROJECT_NO_BROWSE_DIALOG, importProjectWithoutDialog);
			dispatcher.removeEventListener(TemplateEvent.REQUEST_ADDITIONAL_DATA, handleTemplatingDataRequest);
			dispatcher.removeEventListener(AS3ProjectVO.NATIVE_EXTENSION_MESSAGE, onNativeExtensionMessage);
			dispatcher.removeEventListener(ProjectEvent.SEARCH_PROJECTS_IN_DIRECTORIES, handleEventSearchForProjectsInDirectories);
			
			super.deactivate();
		}

		public function testProjectDirectory(dir:FileLocation):FileLocation
		{
			var flashDevelopSettingsFile:FileLocation = FlashDevelopImporter.test(dir);
			if (flashDevelopSettingsFile)
			{
				return flashDevelopSettingsFile;
			}
			return FlashBuilderImporter.test(dir);
		}

		public function parseProject(projectFolder:FileLocation, projectName:String = null, settingsFileLocation:FileLocation = null):ProjectVO
		{
			var flashDevelopSettingsFile:FileLocation = FlashDevelopImporter.test(projectFolder);
			if (flashDevelopSettingsFile)
			{
				return FlashDevelopImporter.parse(flashDevelopSettingsFile, projectName);
			}
			return FlashBuilderImporter.parse(projectFolder);
		}
		
		// If user opens project file, open project automagically
		private function importFDProject(projectFile:FileLocation=null, openWithChoice:Boolean=false, openByProject:ProjectVO=null):void
		{
			// Is file in an already opened project?
			if (checkIfProjectIsAlreadyOpened(projectFile.fileBridge.parent.fileBridge.nativePath)) return;
			
			//check if need auto convert to domino dxl 
			autoConvertXmlToDominoForm(projectFile);

			// Assume user wants to open project by clicking settings file
			openProject(projectFile, openWithChoice, openByProject);

			
		}
		
		private function importFBProject(openWithChoice:Boolean=false):void
		{
			// Is file in an already opened project?
			if (checkIfProjectIsAlreadyOpened(flashBuilderProjectFile.fileBridge.nativePath)) return;
			
			var p:AS3ProjectVO = FlashBuilderImporter.parse(flashBuilderProjectFile);
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
			var project:ProjectVO = openByProject ? openByProject : FlashDevelopImporter.parse(projectFile);
			project.projectFile = projectFile;

			dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.ADD_PROJECT, project, (openWithChoice) ? ProjectEvent.LAST_OPENED_AS_FD_PROJECT : null));
		}

		private function autoConvertXmlToDominoForm(projectFile:FileLocation):void
		{
			model.flexCore.convertFlashDevelopToDomino(projectFile);
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

		private function generateApacheRoyaleProject(event:Event):void
		{
			//1. generate the royale projects
			//2. import the project to editor
			var extension:String = null;
			var settingsFile:FileLocation = null;
			var projectTemplates:Array = TemplatingPlugin.projectTemplates;

			for each (var projectTemplate:FileLocation in projectTemplates)
			{
				var lbl:String = TemplatingHelper.getTemplateLabel(projectTemplate);
				if(lbl == ProjectTemplateType.ROYALE_DOMINO_EXPORT_PROJECT)
				{
					settingsFile = TemplatingPlugin.getSettingsTemplateFileLocation(projectTemplate);
					extension = settingsFile ? TemplatingHelper.getExtension(settingsFile) : null;
					var proposedProjectName:String = model.activeProject.name + "_Royale";
					var newProjectEvent:NewProjectEvent = new NewProjectEvent(NewProjectEvent.CREATE_NEW_PROJECT,extension, settingsFile, projectTemplate, null, proposedProjectName);
					createRoyalVisualProject(newProjectEvent);

					break;
				}
			}
		}
		
		private function importProjectWithoutDialog(event:ProjectEvent):void
		{
			if (!event.anObject) return;

			projectOpeningOptions = null;
			if (event.extras && (event.extras.length != 0) && (event.extras[0] is OpenProjectOptionsVO))
			{
				projectOpeningOptions = event.extras[0] as OpenProjectOptionsVO;
			}

			if (projectOpeningOptions && projectOpeningOptions.isLoadProjectAsWorkspaceChanged)
			{
				openProjectByDirectory(event.anObject);
			}
			else
			{
				// rest of the case
				searchForProjectsByDirectory(event.anObject);
			}
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
			if (!dir) 
			{
				return;
			}
			// TODO: this probably shouldn't be in the AS3ProjectPlugin
			// because it is meant to load all languages
			var invalidProjectFile:Boolean = false;
			try
			{
				var projectCoreProject:ProjectVO = model.projectCore.parseProject(new FileLocation(dir.nativePath));
				if (projectCoreProject)
				{
					importFDProject(
							new FileLocation(dir.nativePath),
							false,
							projectCoreProject
					);
					return;
				}
			}
			catch(e:Error)
			{
				error("Failed to open project: " + dir.nativePath);
				error(e.message +"\n"+ e.getStackTrace());
				invalidProjectFile = true;
			}
			if(invalidProjectFile)
			{
				Alert.show("Can't import: Not a valid " + ConstantsCoreVO.MOONSHINE_IDE_LABEL + " project directory.", "Error!");
				return;
			}

			nonProjectFolderLocation = new FileLocation(dir.nativePath);
			Alert.yesLabel = "Create project with source";
			Alert.noLabel = "Open as generic project";
			Alert.buttonWidth = 170;
			Alert.show("This directory is missing the Moonshine project configuration files. Do you want to generate a new project by locating existing source?", "Error!", Alert.YES|Alert.NO|Alert.CANCEL, null, onExistingSourceProjectConfirm);
		}
		
		private function onExistingSourceProjectConfirm(event:CloseEvent):void
		{
			Alert.yesLabel = "Yes";
			Alert.noLabel = "No";
			Alert.buttonWidth = 65;
			if (event.detail == Alert.YES)
			{
				createAS3Project(new NewProjectEvent("", "as3proj", null, nonProjectFolderLocation));
			}
			else if (event.detail == Alert.NO)
			{
				dispatcher.dispatchEvent(new GenericProjectEvent(GenericProjectEvent.EVENT_OPEN_PROJECT, nonProjectFolderLocation));
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
			if (canCreateProject(event))
			{
				model.flexCore.createProject(event);
			}
		}

		private function createRoyalVisualProject(event:NewProjectEvent):void
		{	
			if(event.settingsFile){
				model.flexCore.createProject(event);
			}else{
				Alert.show("Not have setting files");
			}
		
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
			return projectTemplateName.indexOf(ProjectTemplateType.ACTIONSCRIPT) != -1 ||
				projectTemplateName.indexOf(ProjectTemplateType.FLEX) != -1 ||
				projectTemplateName.indexOf(ProjectTemplateType.ROYALE_VISUAL_PROJECT) != -1 ||
				projectTemplateName.indexOf(ProjectTemplateType.AWAY3D) != -1 ||
				projectTemplateName.indexOf(ProjectTemplateType.FEATHERS_SDK) != -1 ||
				projectTemplateName.indexOf(ProjectTemplateType.LIBRARY_PROJECT) != -1 ||
				projectTemplateName.indexOf(ProjectTemplateType.ROYALE_PROJECT) != -1;
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
			if (projectOpeningOptions && projectOpeningOptions.needProjectSelection)
			{
				prepareOpenProjectSelectionWindow(workerData);
			}
			else if (projectFiles.length == 0)
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
				prepareOpenProjectSelectionWindow(workerData);
			}

			projectOpeningOptions = null;
		}

		private function prepareOpenProjectSelectionWindow(workerData:Object):void
		{
			var projectFiles:Array = workerData.foundProjectsInDirectories;
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
		
		private function openProjectSelectionWindow(collection:ArrayCollection, repositoryRootFile:Object):void
		{
			if (!projectOpenSelection)
			{
				projectOpenSelection = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, ProjectsToOpenSelectionPopup, true) as ProjectsToOpenSelectionPopup;
				projectOpenSelection.title = "Select Projects to Open";
				projectOpenSelection.projects = collection;
				projectOpenSelection.repositoryRoot = repositoryRootFile.nativePath;
				if (projectOpeningOptions && projectOpeningOptions.needWorkspace)
				{
					projectOpenSelection.targetWorkspace = projectOpeningOptions.needWorkspace;
				}
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

        private function getASProjectMenuItems():Vector.<MenuItem>
        {
            if (actionScriptMenu == null)
            {
                actionScriptMenu = Vector.<MenuItem>([
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_PROJECT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.JS_ROYALE], ProjectActionEvent.BUILD,
                            'b', [Keyboard.COMMAND],
                            'b', [Keyboard.CONTROL]),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_AND_RUN'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE], ProjectActionEvent.BUILD_AND_RUN,
                            "\r\n", [Keyboard.COMMAND],
                            "\n", [Keyboard.CONTROL]),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_RELEASE'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], ProjectActionEvent.BUILD_RELEASE),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_ANT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], "selectedProjectAntBuild"),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_MAVEN'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES, ProjectMenuTypes.JAVA], MavenBuildEvent.START_MAVEN_BUILD),
                    new MenuItem(resourceManager.getString('resources', 'ROYALE_API_REPORT'), null, [ProjectMenuTypes.FLEX_AS], RoyaleApiReportEvent.LAUNCH_REPORT_CONFIGURATION),
                    new MenuItem(resourceManager.getString('resources', 'CLEAN_PROJECT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], ProjectActionEvent.CLEAN_PROJECT)
                ]);
                actionScriptMenu.forEach(makeDynamic);
            }

            return actionScriptMenu;
        }

        private function getASLibraryMenuItems():Vector.<MenuItem>
        {
            if (libraryMenu == null)
            {
                libraryMenu = Vector.<MenuItem>([
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_PROJECT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.JS_ROYALE], ActionScriptBuildEvent.BUILD,
                            'b', [Keyboard.COMMAND],
                            'b', [Keyboard.CONTROL]),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_RELEASE'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], ActionScriptBuildEvent.BUILD_RELEASE),
                    new MenuItem(resourceManager.getString('resources', 'CLEAN_PROJECT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], ActionScriptBuildEvent.CLEAN),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_ANT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], "selectedProjectAntBuild"),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_MAVEN'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES, ProjectMenuTypes.JAVA], MavenBuildEvent.START_MAVEN_BUILD)
                ]);
                libraryMenu.forEach(makeDynamic);
            }

            return libraryMenu;
        }

        private function getRoyaleMenuItems():Vector.<MenuItem>
        {
            if (royaleMenu == null)
            {
                royaleMenu = Vector.<MenuItem>([
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_PROJECT'), null, [ProjectMenuTypes.JS_ROYALE], ProjectActionEvent.BUILD,
                            'b', [Keyboard.COMMAND],
                            'b', [Keyboard.CONTROL]),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_AND_RUN'), null, [ProjectMenuTypes.JS_ROYALE], ProjectActionEvent.BUILD_AND_RUN,
                            "\r\n", [Keyboard.COMMAND],
							"\n", [Keyboard.CONTROL]),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_RELEASE'), null, [ProjectMenuTypes.JS_ROYALE], ProjectActionEvent.BUILD_RELEASE),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_ANT'), null, [ProjectMenuTypes.JS_ROYALE], "selectedProjectAntBuild"),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_MAVEN'), null, [ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES, ProjectMenuTypes.JAVA], MavenBuildEvent.START_MAVEN_BUILD),
                    new MenuItem(resourceManager.getString('resources', 'CLEAN_PROJECT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], ProjectActionEvent.CLEAN_PROJECT),
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'DEPLOY_ROYALE_TO_VAGRANT'), null, [ProjectMenuTypes.JS_ROYALE], OnDiskBuildEvent.DEPLOY_ROYALE_TO_VAGRANT),
                    new MenuItem(resourceManager.getString('resources', 'EXPORT_TO_EXTERNAL_PROJECT'), null, [ProjectMenuTypes.JS_ROYALE], ProjectEvent.EVENT_EXPORT_TO_EXTERNAL_PROJECT)
                ]);
                royaleMenu.forEach(makeDynamic);
            }

            return royaleMenu;
        }

        private function getVisualEditorMenuFlexItems():Vector.<MenuItem>
        {
            if (veFlex == null)
            {
                veFlex = Vector.<MenuItem>([
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT'), [
                        new MenuItem(resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT_TO_FLEX'), null, [ProjectMenuTypes.VISUAL_EDITOR_FLEX], ExportVisualEditorProjectEvent.EVENT_INIT_EXPORT_VISUALEDITOR_PROJECT_TO_FLEX,
                                null, null, null, null, null, null, null, true),
                        new MenuItem(resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT_TO_PRIMEFACES'), null, [ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES], ExportVisualEditorProjectEvent.EVENT_EXPORT_VISUALEDITOR_PROJECT_TO_PRIMEFACES,
                                null, null, null, null, null, null, null, true)
                    ])
                ]);

                veFlex.forEach(makeDynamic);
            }

            return veFlex;
        }

        private function getVisualEditorMenuPrimeFacesItems(project:AS3ProjectVO):Vector.<MenuItem>
        {
            if (vePrimeFaces == null)
            {
                vePrimeFaces = Vector.<MenuItem>([
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT'), [
                        new MenuItem(resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT_TO_FLEX'), null, [ProjectMenuTypes.VISUAL_EDITOR_FLEX], ExportVisualEditorProjectEvent.EVENT_INIT_EXPORT_VISUALEDITOR_PROJECT_TO_FLEX,
                                    null, null, null, null, null, null, null, true),
                        new MenuItem(resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT_TO_PRIMEFACES'), null, [ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES], ExportVisualEditorProjectEvent.EVENT_EXPORT_VISUALEDITOR_PROJECT_TO_PRIMEFACES,
                                    null, null, null, null, null, null, null, true)
                    ]),
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'START_PREVIEW'), null, [ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES], PreviewPluginEvent.START_VISUALEDITOR_PREVIEW)
                ]);

                var as3Project:AS3ProjectVO = project as AS3ProjectVO;
                var veMenuItem:MenuItem = vePrimeFaces[vePrimeFaces.length - 1];
                if (as3Project.isPreviewRunning)
                {
                    veMenuItem.label = resourceManager.getString('resources', 'STOP_PREVIEW');
                    veMenuItem.event = PreviewPluginEvent.STOP_VISUALEDITOR_PREVIEW;
                }
                else
                {
                    veMenuItem.label = resourceManager.getString('resources', 'START_PREVIEW');
                    veMenuItem.event = PreviewPluginEvent.START_VISUALEDITOR_PREVIEW;
                }

                vePrimeFaces.forEach(makeDynamic);
            }

            return vePrimeFaces;
        }

        private function getDominoMenuItems():Vector.<MenuItem>
        {
            if (dominoMenu == null)
            {           
                dominoMenu = Vector.<MenuItem>([
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources','GENERATE_JAVA_AGENTS'), null, null, ExportVisualEditorProjectEvent.EVENT_GENERATE_DOMINO_JAVA_AGENTS_OUT_OF_VISUALEDITOR_PROJECT),
                    new MenuItem(resourceManager.getString('resources', 'DEPLOY_DOMINO_DATABASE'), null, null, OnDiskBuildEvent.DEPLOY_DOMINO_DATABASE),
                    new MenuItem(resourceManager.getString('resources','GENERATE_APACHE_ROYALE_PROJECT'), null, null, ProjectEvent.EVENT_GENERATE_APACHE_ROYALE_PROJECT),
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_MAVEN'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES, ProjectMenuTypes.JAVA,ProjectMenuTypes.VISUAL_EDITOR_DOMINO], MavenBuildEvent.START_MAVEN_BUILD),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_ON_VAGRANT'), null, null, DominoEvent.EVENT_BUILD_ON_VAGRANT),
                    new MenuItem(resourceManager.getString('resources', 'CLEAN_PROJECT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS,ProjectMenuTypes.JAVA,ProjectMenuTypes.VISUAL_EDITOR_DOMINO], ProjectActionEvent.CLEAN_PROJECT)
                ]);
                addNSDKillOption(dominoMenu);
                dominoMenu.forEach(makeDynamic);
            }

            return dominoMenu;
        }

        private function makeDynamic(item:MenuItem, index:int, vector:Vector.<MenuItem>):void
        {
            item.dynamicItem = true;
        }

        private function addNSDKillOption(menu:Vector.<MenuItem>):void
        {
            menu.push(new MenuItem(null));
            menu.push(new MenuItem(resourceManager.getString('resources', 'NSD_KILL'), null, [ProjectMenuTypes.VISUAL_EDITOR_DOMINO, ProjectMenuTypes.ON_DISK, ProjectMenuTypes.JAVA], DominoEvent.NDS_KILL))
        }
	}
}