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
package actionScripts.plugin.project
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.net.SharedObject;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayList;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.managers.PopUpManager;

	import actionScripts.data.FileWrapperHierarchicalCollection;
	import actionScripts.events.AddTabEvent;
	import actionScripts.events.CustomCommandsEvent;
	import actionScripts.events.DeleteFileEvent;
	import actionScripts.events.DuplicateEvent;
	import actionScripts.events.FileCopyPasteEvent;
	import actionScripts.events.FilePluginEvent;
	import actionScripts.events.HiddenFilesEvent;
	import actionScripts.events.NewFileEvent;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.events.PreviewPluginEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.RefreshTreeEvent;
	import actionScripts.events.RefreshVisualEditorSourcesEvent;
	import actionScripts.events.RenameApplicationEvent;
	import actionScripts.events.RenameEvent;
	import actionScripts.events.RunANTScriptEvent;
	import actionScripts.events.ShowSettingsEvent;
	import actionScripts.events.TreeMenuItemEvent;
	import actionScripts.events.WatchedFileChangeEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.core.compiler.ProjectActionEvent;
	import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.SettingsView;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	import actionScripts.plugin.templating.TemplatingHelper;
	import actionScripts.plugin.workspace.WorkspacePlugin;
	import actionScripts.ui.LayoutModifier;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.menu.MenuPlugin;
	import actionScripts.ui.renderers.FileWrapperHierarchicalItemRenderer;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.utils.FileCoreUtil;
	import actionScripts.utils.SharedObjectUtil;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.FileWrapper;
	import actionScripts.valueObjects.ProjectReferenceVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.URLDescriptorVO;

	import components.popup.NewFolderPopup;
	import components.popup.RunCommandPopup;
	import components.views.project.OpenResourceView;
	import components.views.project.ProjectTreeContextMenuItem;

	import feathers.data.ArrayCollection;
	import actionScripts.ui.project.ProjectTreeView;
	import actionScripts.data.FlexListCollection;
	import actionScripts.ui.IPanelWindow;

	public class ProjectPlugin extends PluginBase implements IPlugin, ISettingsProvider
	{
		public static const EVENT_PROJECT_SETTINGS:String = "projectSettingsEvent";
		public static const EVENT_SHOW_OPEN_RESOURCE:String = "showOpenResource";
		
		override public function get name():String 	{return "Project Plugin";}
		override public function get author():String 		{return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team";}
		override public function get description():String 	{return "Provides project settings.";}
		
		private var treeView:ProjectTreeView;
		private var openResourceView:OpenResourceView;
		private var lastActiveProjectMenuType:String;
		private var customCommandPopup:RunCommandPopup;
		private var newFolderWindow:NewFolderPopup;

		private var creatingItemIn:FileWrapper;
		private var deleteFileWrapper:FileWrapper;
		private var fileCollection:Array;

		private var _refreshDebounceTimeoutID:uint = uint.MAX_VALUE;
		private var _refreshQueue:Array = [];

		public function ProjectPlugin()
		{
			treeView = new ProjectTreeView();
			treeView.addEventListener(Event.CHANGE, onTreeViewChange);
			treeView.addEventListener(Event.CLOSE, onTreeViewClose);
			treeView.addEventListener(TreeMenuItemEvent.RIGHT_CLICK_ITEM_SELECTED, handleNativeMenuItemClick);
			ChangeWatcher.watch(model, 'activeEditor', onActiveEditorChange);
		}

		override public function activate():void
		{
			super.activate(); 
			_activated = true;

			model.projects.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleProjectsChange, false, 0, true);
			model.selectedprojectFolders.addEventListener(CollectionEvent.COLLECTION_CHANGE, onSelectedProjectFoldersChange);
			WorkspacePlugin.workspacesForViews.addEventListener(CollectionEvent.COLLECTION_CHANGE, onWorkspacesForViewsChange);
			
			dispatcher.addEventListener(ProjectEvent.ADD_PROJECT, handleAddProject);
			dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, handleRemoveProject);

			dispatcher.addEventListener(ProjectEvent.SHOW_PREVIOUSLY_OPENED_PROJECTS, handleShowPreviouslyOpenedProjects);
            dispatcher.addEventListener(ProjectEvent.SCROLL_FROM_SOURCE, handleScrollFromSource);
			dispatcher.addEventListener(ProjectEvent.SHOW_PROJECT_VIEW, handleShowProjectView);
			
			dispatcher.addEventListener(EVENT_SHOW_OPEN_RESOURCE, handleShowOpenResource);
			
			dispatcher.addEventListener(ShowSettingsEvent.EVENT_SHOW_SETTINGS, handleShowSettings);		
			dispatcher.addEventListener(EVENT_PROJECT_SETTINGS, handleMenuShowSettings);
			
			dispatcher.addEventListener(RefreshTreeEvent.EVENT_REFRESH, handleTreeRefresh);
			dispatcher.addEventListener(CustomCommandsEvent.OPEN_CUSTOM_COMMANDS_ON_SDK, onCustomCommandInterface);

			dispatcher.addEventListener(WatchedFileChangeEvent.FILE_CREATED, handleWatchedFileCreatedEvent);
			dispatcher.addEventListener(WatchedFileChangeEvent.FILE_DELETED, handleWatchedFileDeletedEvent);

			dispatcher.addEventListener(ProjectEvent.CLOSE_PROJECT, onCloseProjectRequest, false, 0, true);
			dispatcher.addEventListener(ProjectEvent.PROJECT_FILES_UPDATES, onProjectFilesUpdates, false, 0, true);
			dispatcher.addEventListener(ProjectEvent.TREE_DATA_UPDATES, onProjectTreeUpdates, false, 0, true);
			dispatcher.addEventListener(RenameApplicationEvent.RENAME_APPLICATION_FOLDER, onProjectRenameRequest, false, 0, true);
			dispatcher.addEventListener(TreeMenuItemEvent.NEW_FILE_CREATED, onFileNewFolderCreationRequested, false, 0, true);
			dispatcher.addEventListener(TreeMenuItemEvent.NEW_FILES_FOLDERS_COPIED, onNewFilesFoldersCopied, false, 0, true);

			model.selectedprojectFolders.removeAll();

			var dataSortField:SortField = new SortField("name", true);
			var dataSort:Sort = new Sort();
			dataSort.fields = [dataSortField];
			model.selectedprojectFolders.sort = dataSort;
			
			model.selectedprojectFolders.refresh();
			
			setFeathersTreeViewData(model.selectedprojectFolders);
			setFeathersWorkspaceData(WorkspacePlugin.workspacesForViews);
		}

		override public function deactivate():void
		{
			super.deactivate();
			_activated = false;
			
			model.projects.removeEventListener(CollectionEvent.COLLECTION_CHANGE, handleProjectsChange);
			
			dispatcher.removeEventListener(EVENT_SHOW_OPEN_RESOURCE, handleShowOpenResource);

			dispatcher.removeEventListener(ProjectEvent.CLOSE_PROJECT, onCloseProjectRequest);
			dispatcher.removeEventListener(ProjectEvent.PROJECT_FILES_UPDATES, onProjectFilesUpdates);
			dispatcher.removeEventListener(ProjectEvent.TREE_DATA_UPDATES, onProjectTreeUpdates);
			dispatcher.removeEventListener(RenameApplicationEvent.RENAME_APPLICATION_FOLDER, onProjectRenameRequest);
			dispatcher.removeEventListener(TreeMenuItemEvent.NEW_FILE_CREATED, onFileNewFolderCreationRequested);
			dispatcher.removeEventListener(TreeMenuItemEvent.NEW_FILES_FOLDERS_COPIED, onNewFilesFoldersCopied);
		}
		
		public function getSettingsList():Vector.<ISetting>	
		{
			return new Vector.<ISetting>();
		}

		private function setFeathersTreeViewData(folders:mx.collections.ArrayCollection):void
		{
			var roots:Array = folders.source.slice();
			treeView.dataProvider = new FileWrapperHierarchicalCollection(roots);

			treeView.projects = new FlexListCollection(model.projects);
		}

		private function setFeathersWorkspaceData(workspaces:ArrayList):void
		{
			treeView.workspaces = new FlexListCollection(workspaces);
		}
		
		private function showProjectPanel():void
		{
			if (!treeView.stage) 
			{
				LayoutModifier.attachSidebarSections(treeView);
			}
		}
		
		private function onCustomCommandInterface(event:CustomCommandsEvent):void
		{
			if (!model.activeProject) 
			{
				error("Error: Command is require to execute against a project.");
				return;
			}
			
			if (!customCommandPopup)
			{
				customCommandPopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, RunCommandPopup, true) as RunCommandPopup;
				customCommandPopup.commands = event.commands;
				customCommandPopup.selectedCommand = event.selectedCommand;
				customCommandPopup.executableNameToDisplay = event.executableNameToDisplay;
				customCommandPopup.origin = event.origin;
				customCommandPopup.addEventListener(CloseEvent.CLOSE, onCustomRunCommandClosed);
				PopUpManager.centerPopUp(customCommandPopup);
			}
		}
		
		private function onCustomRunCommandClosed(event:CloseEvent):void
		{
			customCommandPopup.origin = null;
			customCommandPopup.removeEventListener(CloseEvent.CLOSE, onCustomRunCommandClosed);
			customCommandPopup = null;
		}

		private function handleShowSettings(event:ShowSettingsEvent):void
		{
			showSettings(event.project, event.jumpToSection);
		}
		
		private function handleMenuShowSettings(event:Event):void
		{
			var project:ProjectVO = model.activeProject;
			if (project)
			{
				showSettings(model.activeProject);
			} 
		}
		
		private function showSettings(project:ProjectVO, jumpToSection:String=null):void
		{
			// Don't spawn two identical settings views.
			for (var i:int = 0; i < model.editors.length; i++)
			{
				var view:SettingsView = model.editors as SettingsView;
				if (view && view.associatedData == project)
				{
					model.activeEditor = view;
					return;
				}
			}

			var settingsLabel:String = project.folderLocation.fileBridge.name + " settings";

			// Create settings view & fetch project settings
			var settingsView:SettingsView = new SettingsView();
			settingsView.Width = 230;
			settingsView.addCategory(settingsLabel);
			
			var categories:Vector.<SettingsWrapper> = project.getSettings();
			for each (var category:SettingsWrapper in categories)
			{
				settingsView.addSetting(category, settingsLabel);
				if (jumpToSection && jumpToSection.toLowerCase() == category.name.toLowerCase())
				{
					settingsView.currentRequestedSelectedItem = category;
                }
			}
			
			settingsView.label = settingsLabel;
			settingsView.associatedData = project;
			
			// Listen for save/cancel
			settingsView.addEventListener(SettingsView.EVENT_SAVE, settingsSave);
			settingsView.addEventListener(SettingsView.EVENT_CLOSE, settingsClose);
			
			dispatcher.dispatchEvent(
				new AddTabEvent(settingsView)
			);
		}

        private function settingsClose(event:Event):void
		{
			var settings:SettingsView = event.target as SettingsView;
			
			// Close the tab
			dispatcher.dispatchEvent(
				new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, settings)
			);
			
			// notify project
			if (!settings.isSaved && (settings.associatedData is ProjectVO))
			{
				(settings.associatedData as ProjectVO).cancelledSettings();
			}
			
			settings.removeEventListener(SettingsView.EVENT_CLOSE, settingsClose);
			settings.removeEventListener(SettingsView.EVENT_SAVE, settingsSave);
		}
		
		private function settingsSave(event:Event):void
		{
			var view:SettingsView = event.target as SettingsView;
			
			if (view && view.associatedData is ProjectVO)
			{
				var pvo:ProjectVO = view.associatedData as ProjectVO;
				
				if (model.projects.getItemIndex(pvo) == -1)
				{
					// Newly created project, add it to project explorer & show it
					model.projects.addItem(pvo);
                    model.activeProject = pvo;
					
					if (lastActiveProjectMenuType != pvo.menuType)
					{
	                    dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.ACTIVE_PROJECT_CHANGED, model.activeProject));
						lastActiveProjectMenuType = pvo.menuType;
					}

					showProjectPanel();
					
					dispatcher.dispatchEvent( 
						new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, view) 
					);
				}
				else
				{
					// Save
					pvo.saveSettings();
					if (pvo is ProjectVO) 
					{
						(pvo as ProjectVO).closedSettings();
					}
				}
				dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.SAVE_PROJECT_SETTINGS, pvo));
			}
		}

		private function handleAddProject(event:ProjectEvent):void
		{
			showProjectPanel();
			// Is file in an already opened project?
			for each (var p:ProjectVO in model.projects)	
			{
				if (event.project.folderLocation.fileBridge.nativePath == p.folderLocation.fileBridge.nativePath)
				{
					return;
				}
			}
			
			if (model.projects.getItemIndex(event.project) == -1)
			{
				model.projects.addItemAt(event.project, 0);

				if (event.project is AS3ProjectVO && lastActiveProjectMenuType != event.project.menuType)
				{
					dispatcher.dispatchEvent(new Event(MenuPlugin.REFRESH_MENU_STATE));
					lastActiveProjectMenuType = event.project.menuType;
				}
			}

            openRecentlyUsedFiles(event.project);
			SharedObjectUtil.saveProjectForOpen(event.project.folderLocation.fileBridge.nativePath, event.project.projectName);
		}
		
		private function handleRemoveProject(event:ProjectEvent):void
		{
			var idx:int = model.projects.getItemIndex(event.project);
			if (idx > -1)
			{
				model.projects.removeItemAt(idx);
			}
			
			if (model.activeProject == event.project)
			{
				if (model.projects.length == 0)
				{
					model.activeProject = null;
                }
				
				if (!model.activeProject || (model.activeProject is AS3ProjectVO && lastActiveProjectMenuType != AS3ProjectVO(model.activeProject).menuType))
				{
					dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.ACTIVE_PROJECT_CHANGED, model.activeProject));
					if(model.activeProject is AS3ProjectVO)
					{
						lastActiveProjectMenuType = model.activeProject ? model.activeProject.menuType : null;
					}
					else
					{
						lastActiveProjectMenuType = null;
					}
				}
			}

            SharedObjectUtil.removeProjectFromOpen(event.project.folderLocation.fileBridge.nativePath, event.project.projectName);
		}
		
		private function handleShowOpenResource(event:Event):void
		{
			if (!openResourceView)
			{
				openResourceView = new OpenResourceView();
			}
			
			// If it's not showing, spin it into view
			if (!openResourceView.stage)
			{
				openResourceView.setFileList(model.selectedprojectFolders);
				openResourceView.setFocus();
			}
		}
		
		private function handleShowProjectView(event:Event):void
		{
			showProjectPanel();
		}

		private function handleTreeRefresh(event:RefreshTreeEvent):void
		{
			treeView.refresh(event.dir, event.shallMarkedForDelete);
		}

		private function queueRefresh(directoryToRefresh:String):void
		{
			// when a file system watcher event is received, we need to refresh
			// the treeview, but we queue them up because calling
			// treeView.refresh() too often brutally hurts performance.
			// this queue helps in two ways:
			// 1) we skip updating duplicate paths, meaning fewer refreshes
			// 2) the short pause allows rendering to happen, keeping the app responsive
			if (_refreshQueue.indexOf(directoryToRefresh) != -1) {
				// this directory is already queued for refresh
				// no need to refresh it multiple times
				return;
			}
			_refreshQueue.push(directoryToRefresh);
			if (_refreshDebounceTimeoutID != uint.MAX_VALUE) {
				clearTimeout(_refreshDebounceTimeoutID);
				_refreshDebounceTimeoutID = uint.MAX_VALUE;
			}
			_refreshDebounceTimeoutID = setTimeout(handleQueuedRefreshes, 250);
		}

		private function handleQueuedRefreshes():void
		{
			_refreshDebounceTimeoutID = uint.MAX_VALUE;
			for each(var directoryToRefresh:String in _refreshQueue) {
				treeView.refresh(new FileLocation(directoryToRefresh));
			}
			_refreshQueue.length = 0;
		}

		private function handleWatchedFileCreatedEvent(event:WatchedFileChangeEvent):void
		{
			//need to refresh the parent directory listing
			var directoryToRefresh:String = event.file.fileBridge.parent.fileBridge.nativePath;
			queueRefresh(directoryToRefresh);
		}

		private function handleWatchedFileDeletedEvent(event:WatchedFileChangeEvent):void
		{
			//need to refresh the parent directory listing
			var directoryToRefresh:String = event.file.fileBridge.parent.fileBridge.nativePath;
			//refreshes are queued because calling treeView.refresh() too often
			//is brutal for performance
			queueRefresh(directoryToRefresh);
		}

        private function handleShowPreviouslyOpenedProjects(event:ProjectEvent):void
        {
            openPreviouslyOpenedProject();
        }

        private function openRecentlyUsedFiles(project:ProjectVO):void
		{
            var cookie:SharedObject = SharedObjectUtil.getMoonshineIDEProjectSO("projectFiles");
			if (!cookie) return;

            var projectFilesForOpen:Array = cookie.data["projectFiles" + project.name];
            if (projectFilesForOpen)
            {
                for (var i:int = 0; i < projectFilesForOpen.length; i++)
                {
                    var itemForOpen:Object = projectFilesForOpen[i];
                    for (var item:Object in itemForOpen)
                    {
                        var fileLocation:FileLocation = new FileLocation(itemForOpen[item]);
                        if (fileLocation.fileBridge.exists)
                        {
                            var as3Project:AS3ProjectVO = (project as AS3ProjectVO);
                            var customSDKPath:String = as3Project ? as3Project.buildOptions.customSDKPath : "";
                            var projectReferenceVO: ProjectReferenceVO = new ProjectReferenceVO();
                            //projectReferenceVO.name = project.name;
                            projectReferenceVO.sdk = customSDKPath ? customSDKPath :
                                    (model.defaultSDK ? model.defaultSDK.fileBridge.nativePath : null);

                            projectReferenceVO.path = project.folderLocation.fileBridge.nativePath;
							projectReferenceVO.sourceFolder = project.sourceFolder;

                            var fileWrapper:FileWrapper = new FileWrapper(fileLocation, false, projectReferenceVO);
							dispatcher.dispatchEvent(new OpenFileEvent(OpenFileEvent.OPEN_FILE, [fileLocation], -1, [fileWrapper]));
                        }
						else
						{
							SharedObjectUtil.removeLocationOfClosingProjectFile(
									fileLocation.name,
									fileLocation.fileBridge.nativePath,
									project.projectFolder.nativePath);
						}
                    }
                }
            }
		}

        private function openPreviouslyOpenedProject():void
        {
            dispatcher.removeEventListener(ProjectEvent.SHOW_PREVIOUSLY_OPENED_PROJECTS, handleShowPreviouslyOpenedProjects);
			
			// check if any startup invoke-arguments are pending
			if (model.startupInvokeEvent)
			{
				dispatcher.dispatchEvent(model.startupInvokeEvent);
				model.startupInvokeEvent = null;
			}
			
            var cookie:SharedObject = SharedObjectUtil.getMoonshineIDEProjectSO("projects");
            if (!cookie) 
			{
				return;
			}
			
            var projectsForOpen:Array = cookie.data["projects"];
            if (projectsForOpen && projectsForOpen.length > 0)
            {
                var projectLocationInfo:Object = {};
				ConstantsCoreVO.STARTUP_PROJECT_OPEN_QUEUE_LEFT = projectsForOpen.length;
                for (var i:int = 0; i < projectsForOpen.length; i++)
                {
                    var project:ProjectVO;
                    for (var item:Object in projectsForOpen[i])
                    {
                        projectLocationInfo.path = item;
                        projectLocationInfo.name = projectsForOpen[i][item];
                    }

                    var projectLocation:FileLocation = new FileLocation(projectLocationInfo.path);
                    var projectFile:Object = projectLocation.fileBridge.getFile;
					var projectFileLocation:FileLocation = null;
					
					if (!project)
					{
						try
						{
							project = model.projectCore.parseProject(projectLocation);
						}
						catch(e:Error)
						{
							project = null;
							error("Failed to open project: " + projectLocation.fileBridge.nativePath);
							error(e.message +"\n"+ e.getStackTrace());
						}
					}

                    if (project)
                    {
                        dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.ADD_PROJECT, project));
                        project = null;
                    }
					else
					{
						var pr:Object = projectsForOpen[i];
						SharedObjectUtil.removeProjectFromOpen(projectLocationInfo.path, projectLocationInfo.name);
						SharedObjectUtil.removeProjectTreeItemFromOpenedItems(projectLocationInfo, "name", "path");
					}

                    projectLocationInfo.projectPath = null;
                    projectLocationInfo.projectName = null;
                }
            }
        }

		private function onActiveEditorChange(event:Event):void
		{
			var fileLocation:FileLocation = null;
			if (model.activeEditor is BasicTextEditor)
			{
				fileLocation = BasicTextEditor(model.activeEditor).currentFile;
			}
			treeView.activeFile = fileLocation;
			refreshActiveProject(fileLocation);
		}

		private function onTreeViewChange(event:Event):void
		{
			if (treeView.selectedItem)
			{
				refreshActiveProject(treeView.selectedItem.file);
			}
		}

		private function onTreeViewClose(event:Event):void
		{
			if (treeView.stage == null)
			{
				return;
			}
			LayoutModifier.removeFromSidebar(treeView.parent as IPanelWindow);
		}

		private function refreshActiveProject(file:FileLocation):void
		{
			if(file == null) return;

			var activeProject:ProjectVO = UtilsCore.getProjectByAnyFilePath(file.fileBridge.nativePath);
			if(activeProject != null)
			{
				if(model.activeProject != activeProject)
				{
					model.activeProject = activeProject;
					UtilsCore.setProjectMenuType(activeProject);

					dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.ACTIVE_PROJECT_CHANGED, activeProject));
				}
			}
		}
	
		private function handleNewFolderPopupClose(event:CloseEvent):void
		{
			newFolderWindow.removeEventListener(CloseEvent.CLOSE, handleNewFolderPopupClose);
			newFolderWindow.removeEventListener(NewFileEvent.EVENT_NEW_FOLDER, onFileNewFolderCreationRequested);
			newFolderWindow = null;
		}

		private function onFileNewFolderCreationRequested(event:Event):void
		{
			// @note
			// NewFileEvent calls in case of folder creation, and
			// it's TreeMenuItemEvent in case of file creation

			var isFolderCreationEvent:Boolean = (event is NewFileEvent);
			var fileName:String;
			var newFileLocation:FileLocation;
			var fileSparator:String = model.fileCore.separator;
			var insideLocation:FileWrapper = (event is NewFileEvent) ? NewFileEvent(event).insideLocation : TreeMenuItemEvent(event).data;
			if (isFolderCreationEvent)
			{
				fileName = NewFileEvent(event).fileName;

				newFileLocation = insideLocation.file.fileBridge.resolvePath(fileName);
				if (!newFileLocation.fileBridge.exists) newFileLocation.fileBridge.createDirectory();
			} 
			else if ((event as TreeMenuItemEvent).extra && ((event as TreeMenuItemEvent).extra is FileLocation))
			{
				fileName = (event as TreeMenuItemEvent).menuLabel.replace((event as TreeMenuItemEvent).data.file.fileBridge.nativePath + model.fileCore.separator, "");
				newFileLocation = (event as TreeMenuItemEvent).extra as FileLocation;
			} 
			else
			{
				fileName = (event as TreeMenuItemEvent).menuLabel.replace((event as TreeMenuItemEvent).data.file.fileBridge.nativePath + model.fileCore.separator, "");
				newFileLocation = new FileLocation(TreeMenuItemEvent(event).menuLabel);
			}

			// generates the fileWrappers and add to the parent
			var tmpFolders:Array = (fileName.indexOf(fileSparator) != -1) ? fileName.split(fileSparator) : [fileName];
			var folderWrappers:Array = [];
			var newFile:FileWrapper;
			var tmpNestedFolderPathString:String = "";
			var isRequireFileNameAddition:Boolean;
			
			if (!isFolderCreationEvent && (tmpFolders.length > 1))
			{
				isRequireFileNameAddition = true;
				tmpFolders.pop();
			}
			
			var runCheckFileWrapper:FileWrapper = insideLocation;
			tmpFolders.forEach(function(folderName:String, index:int, arr:Array):void {
				
				var isExists:Boolean = runCheckFileWrapper.children.some(function(element:FileWrapper, index:int, arr:Array):Boolean {
					if (element.file.fileBridge.nativePath == (runCheckFileWrapper.file.fileBridge.nativePath + model.fileCore.separator + folderName))
					{
						runCheckFileWrapper = element;
						return true;
					}
					return false;
				});
				
				tmpNestedFolderPathString += folderName + fileSparator;
				if (isExists)
				{
					newFile = runCheckFileWrapper;
				}
				else
				{
					newFile = new FileWrapper(
						insideLocation.file.fileBridge.resolvePath(tmpNestedFolderPathString), 
						false, 
						insideLocation.projectReference
					);
					newFile.defaultName = folderName;
					newFile.children = [];
				}
				
				if (index == 0) 
				{
					folderWrappers.push(newFile);
				}
				else
				{
					if (!isExists) (folderWrappers[folderWrappers.length - 1] as FileWrapper).children.push(newFile);
					folderWrappers.push(newFile);
				}
			});
			
			if (!isFolderCreationEvent && isRequireFileNameAddition)
			{
				var newFileWrapper:FileWrapper = new FileWrapper(newFileLocation, false, insideLocation.projectReference);
				newFileWrapper.defaultName = newFileLocation.name;
				
				if (newFile)
				{
					newFile.children.push(newFileWrapper);
					newFile = newFileWrapper;
				}
				else
				{
					folderWrappers.push(newFileWrapper);
					newFile = newFileWrapper;
				}
			}
			
			
			var isImmediateExists:Boolean = insideLocation.children.some(function(element:FileWrapper, index:int, arr:Array):Boolean {
				return (element == folderWrappers[0]);
			});
			if (!isImmediateExists) insideLocation.children.push(folderWrappers[0]);

			// Make sure item is open before adding
			treeView.expandItem(insideLocation, true);
			// refresh after creating so that the user can see the
			// change immediately, instead of waiting for the file
			// system watcher, which might take a second or two
			treeView.refreshItem(insideLocation);
			if (isFolderCreationEvent)
			{
				treeView.expandItem(folderWrappers[0], true);
			}

			// refresh the folder section and select
			var timeoutValue:uint = setTimeout(function ():void
			{
				treeView.sortChildren(insideLocation);

				// after a refresh new fileWrapper being created,
				// so we need new instance of the wrapper so we can
				// select and scroll-to-index
				var tmpFileW:FileWrapper = UtilsCore.findFileWrapperAgainstProject(newFile, null, insideLocation);
				treeView.selectedItem = tmpFileW;

				treeView.scrollToItem(tmpFileW);
				clearTimeout(timeoutValue);
			}, 300);
		}
	
		private function refreshByWrapperItem(fileWrapper:FileWrapper):void
		{
			if(!fileWrapper.file.fileBridge.isDirectory)
			{
				treeView.refresh(fileWrapper.file.fileBridge.parent, fileWrapper.isDeleting);
			}
			else
			{
				treeView.refreshItem(fileWrapper);
			}

			if(fileWrapper.sourceController)
			{
				fileWrapper.sourceController.refresh(fileWrapper.file);
			}

			if (fileWrapper.file.fileBridge.isDirectory) 
			{
				treeView.sortChildren(fileWrapper);
			}
		}
	
		private function refreshFileFolder(fileWrapper:FileWrapper, project:ProjectVO = null):void
		{
			if(!project) project = UtilsCore.getProjectFromProjectFolder(fileWrapper);

			if(!ConstantsCoreVO.IS_AIR)
			{
				refreshProjectFromServer(fileWrapper, project);
				return;
			}

			if((project is AS3ProjectVO) && (project as AS3ProjectVO).isVisualEditorProject)
			{
				dispatcher.dispatchEvent(
						new RefreshVisualEditorSourcesEvent(RefreshVisualEditorSourcesEvent.REFRESH_VISUALEDITOR_SRC,
								fileWrapper, (project as AS3ProjectVO))
				);
			} else if(fileWrapper)
			{
				refreshByWrapperItem(fileWrapper);
			}
		}

		private function refreshProjectFromServer(fw:FileWrapper, project:ProjectVO):void
		{
			// determine to which project fileWrapper is belongs to
			var projectIndex:int = -1;
			if(model.selectedprojectFolders.length > 1)
			{
				for (var i:int = 0; i < model.selectedprojectFolders.length; i++)
				{
					if(model.selectedprojectFolders[i] == fw)
					{
						projectIndex = i;
						break;
					}
				}
			} else
			{
				projectIndex = 0;
			}

			model.selectedprojectFolders[projectIndex].isWorking = true;
			var projectPath:String = project.projectFolder.nativePath;
			var tmpProjectVO:ProjectVO = new ProjectVO(new FileLocation(URLDescriptorVO.PROJECT_DIR + projectPath), model.selectedprojectFolders[projectIndex].name, false);
			tmpProjectVO.projectRemotePath = project.projectFolder.nativePath;
			tmpProjectVO.addEventListener(ProjectVO.PROJECTS_DATA_UPDATED, onTmpProjectUpdated, false, 0, true);
			tmpProjectVO.addEventListener(ProjectVO.PROJECTS_DATA_FAULT, onTmpProjectUpdateFault, false, 0, true);

			function onTmpProjectUpdated(event:Event):void
			{
				onTmpProjectUpdateFault(null);

				model.projects[projectIndex] = tmpProjectVO;
				model.selectedprojectFolders[projectIndex] = tmpProjectVO.projectFolder;
				treeView.refreshItem(model.selectedprojectFolders[projectIndex]);
			}

			function onTmpProjectUpdateFault(event:Event):void
			{
				tmpProjectVO.removeEventListener(ProjectVO.PROJECTS_DATA_UPDATED, onTmpProjectUpdated);
				tmpProjectVO.removeEventListener(ProjectVO.PROJECTS_DATA_FAULT, onTmpProjectUpdateFault);
				model.selectedprojectFolders[projectIndex].isWorking = false;
			}
		}

		private function handleNativeMenuItemClick(event:TreeMenuItemEvent):void
		{
			// Might be some sub-menu provider we're dealing with
			if(!(event.data is FileWrapper)) return;

			var project:ProjectVO;
			var fileWrapper:FileWrapper = FileWrapper(event.data);
			var isMultiSelection:Boolean;
			var fw:FileWrapper;

			if((treeView.selectedItems.length > 1)
					&& (treeView.selectedItems.indexOf(fileWrapper) != -1)) isMultiSelection = true;

			switch (event.menuLabel)
			{
				case ProjectTreeContextMenuItem.SETTINGS:
				case ProjectTreeContextMenuItem.PROJECT_SETUP:
				{
					project = UtilsCore.getProjectFromProjectFolder(fileWrapper);
					dispatcher.dispatchEvent(
							new ShowSettingsEvent(project)
					)
					break;
				}
				case ProjectTreeContextMenuItem.OPEN:
				case ProjectTreeContextMenuItem.OPEN_FILE_FOLDER:
				{
					if(isMultiSelection)
					{
						openFileFolder(treeView.selectedItems);
					}
					else
					{
						openFileFolder([fileWrapper]);
					}
					break;
				}
				case ProjectTreeContextMenuItem.CLOSE:
				{
					onFileDeletedOnServer([fileWrapper], event.menuLabel);
					refreshActiveProject(fileWrapper.file);
					break;
				}
				case ProjectTreeContextMenuItem.DELETE:
				case ProjectTreeContextMenuItem.DELETE_PROJECT:
				case ProjectTreeContextMenuItem.DELETE_FILE_FOLDER:
				{
					if(isMultiSelection && isMultiSelectionIsValid())
					{
						Alert.show("Are you sure you want to delete all selected files and folders from the file system?", "Confirm", Alert.YES | Alert.CANCEL, null, onFileDeleteConfirm);
						return;
					} else if(!isMultiSelection)
					{
						if(fileWrapper.isWorking) return;
						if(!fileWrapper.isRoot && fileWrapper.file.fileBridge.exists)
						{
							Alert.show("Are you sure you want to delete '" + fileWrapper.file.fileBridge.name + "' from the file system?", "Confirm", Alert.YES | Alert.CANCEL, null, onFileDeleteConfirm);
						} else
						{
							onFileDeleteConfirm(null);
						}
					}
					break;
				}
				case ProjectTreeContextMenuItem.RENAME:
				{
					renameFileFolder(event.renderer);
					break;
				}
				case ProjectTreeContextMenuItem.DUPLICATE_FILE:
				{
					dispatcher.dispatchEvent(new DuplicateEvent(DuplicateEvent.EVENT_OPEN_DUPLICATE_FILE_VIEW, fileWrapper));
					break;
				}
				case ProjectTreeContextMenuItem.COPY_FILE:
				{
					dispatcher.dispatchEvent(new FileCopyPasteEvent(FileCopyPasteEvent.EVENT_COPY_FILE, isMultiSelection ? treeView.selectedItems : [fileWrapper]));
					break;
				}
				case ProjectTreeContextMenuItem.PASTE_FILE:
				{
					dispatcher.dispatchEvent(new FileCopyPasteEvent(FileCopyPasteEvent.EVENT_PASTE_FILES, fileWrapper.file.fileBridge.isDirectory ? [fileWrapper] : [treeView.getParentItem(fileWrapper)]));
					break;
				}
				case ProjectTreeContextMenuItem.SET_AS_DEFAULT_APPLICATION:
				{
					if(model.activeProject is AS3ProjectVO)
					{
						TemplatingHelper.setFileAsDefaultApplication(fileWrapper, FileWrapper(treeView.getParentItem(fileWrapper)));
					} else if(model.activeProject is JavaProjectVO)
					{
						dispatcher.dispatchEvent(new ProjectActionEvent(ProjectActionEvent.SET_DEFAULT_APPLICATION, fileWrapper.file));
					}
					break;
				}
				case ProjectTreeContextMenuItem.REFRESH:
				{
					refreshFileFolder(fileWrapper);
					break;
				}
				case ProjectTreeContextMenuItem.NEW:
				{
					// Right-clicking a directory creates the file in the dir,
					// otherwise create in same dir as clicked file
					creatingItemIn = (fileWrapper.file.fileBridge.isDirectory || !fileWrapper.file.fileBridge.exists) ?
							fileWrapper : treeView.getParentItem(fileWrapper);
					if(!creatingItemIn.file.fileBridge.checkFileExistenceAndReport())
					{
						return;
					}

					// for new file type creation
					if(event.extra != ProjectTreeContextMenuItem.NEW_FOLDER)
					{
						var newFileEvent:NewFileEvent = new NewFileEvent(event.extra, creatingItemIn.file.fileBridge.nativePath, null, creatingItemIn);
						newFileEvent.ofProject = UtilsCore.getProjectFromProjectFolder(fileWrapper);

						dispatcher.dispatchEvent(newFileEvent);
					} else
					{
						if(!newFolderWindow)
						{
							newFolderWindow = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, NewFolderPopup, true) as NewFolderPopup;
							newFolderWindow.addEventListener(CloseEvent.CLOSE, handleNewFolderPopupClose);
							newFolderWindow.addEventListener(NewFileEvent.EVENT_NEW_FOLDER, onFileNewFolderCreationRequested);
							newFolderWindow.wrapperOfFolderLocation = creatingItemIn;
							newFolderWindow.wrapperBelongToProject = UtilsCore.getProjectFromProjectFolder(fileWrapper);

							PopUpManager.centerPopUp(newFolderWindow);
						}
					}

					break;
				}
				case ProjectTreeContextMenuItem.OPEN_WITH:
				{
					if (event.extra == ProjectTreeContextMenuItem.CONFIGURE_EXTERNAL_EDITORS ||
							event.extra == ProjectTreeContextMenuItem.CONFIGURE_VAGRANT)
					{
						dispatcher.dispatchEvent(new Event(event.extra));
					}
					else
					{
						dispatcher.dispatchEvent(new FilePluginEvent(event.extra, fileWrapper.file));
					}
					break;
				}
				case ProjectTreeContextMenuItem.VAGRANT_GROUP:
				{
					dispatcher.dispatchEvent(new FilePluginEvent(event.extra, fileWrapper.file));
					break;
				}
				case ProjectTreeContextMenuItem.RUN_ANT_SCRIPT:
				{
					model.antScriptFile = new FileLocation(fileWrapper.file.fileBridge.nativePath);
					dispatcher.dispatchEvent(new RunANTScriptEvent(RunANTScriptEvent.ANT_BUILD));
					break;
				}
				case ProjectTreeContextMenuItem.COPY_PATH:
				{
					FileCoreUtil.copyPathToClipboard(fileWrapper.file);
					break;
				}
				case ProjectTreeContextMenuItem.OPEN_PATH_IN_TERMINAL:
				{
					if (ConstantsCoreVO.IS_MACOS)
					{
						dispatcher.dispatchEvent(new FilePluginEvent(event.extra, fileWrapper.file));
					}
					else
					{
						dispatcher.dispatchEvent(new FilePluginEvent(FilePluginEvent.EVENT_OPEN_PATH_IN_TERMINAL, fileWrapper.file));
					}
					break;
				}
				case ProjectTreeContextMenuItem.OPEN_PATH_IN_POWERSHELL:
				{
					dispatcher.dispatchEvent(new FilePluginEvent(FilePluginEvent.EVENT_OPEN_PATH_IN_POWERSHELL, fileWrapper.file));
					break;
				}
				case ProjectTreeContextMenuItem.SHOW_IN_EXPLORER:
				case ProjectTreeContextMenuItem.SHOW_IN_FINDER:
				{
					FileCoreUtil.showInExplorer(fileWrapper.file);
					break;
				}
				case ProjectTreeContextMenuItem.MARK_AS_VISIBLE:
					dispatcher.dispatchEvent(new HiddenFilesEvent(HiddenFilesEvent.MARK_FILES_AS_VISIBLE, fileWrapper));
					break;
				case ProjectTreeContextMenuItem.MARK_AS_HIDDEN:
					dispatcher.dispatchEvent(new HiddenFilesEvent(HiddenFilesEvent.MARK_FILES_AS_HIDDEN, fileWrapper));
					break;
				case ProjectTreeContextMenuItem.PREVIEW:
					dispatcher.dispatchEvent(new PreviewPluginEvent(PreviewPluginEvent.START_VISUALEDITOR_PREVIEW, fileWrapper));
					break;
			}

			/*
			* @local
			* file delete
			*/
			function onFileDeleteConfirm(event2:CloseEvent):void
			{
				if(!event2 || event2.detail == Alert.YES)
				{
					var parentFileWrapper:FileWrapper = treeView.getParentItem(fileWrapper);
					var projectAssociatedWithFile:ProjectVO = UtilsCore.getProjectFromProjectFolder(treeView.selectedItems[0] as FileWrapper);
					dispatcher.dispatchEvent(new DeleteFileEvent(fileWrapper.file, isMultiSelection ? treeView.selectedItems : [fileWrapper], onFileDeletedOnServer, event.showAlert, projectAssociatedWithFile));
					//Alert.show("delete file:"+fileWrapper.file.fileBridge.nativePath);
					var parentFolder:String=fileWrapper.file.fileBridge.parent.fileBridge.nativePath;
					//Alert.show("parentFolder file:"+parentFolder);
					if(UtilsCore.endsWith(parentFolder,"nsfs/nsf-moonshine/odp/Forms")){
						var projectPath:String=parentFolder.substring(0,parentFolder.indexOf("nsfs/nsf-moonshine/odp/Forms"));
						var xmlFilePath:String=projectPath+"visualeditor-src/main/webapp/"+fileWrapper.file.fileBridge.nameWithoutExtension+".xml";
						//Alert.show("xmlFilePath:"+xmlFilePath);
						var xmlFile:FileLocation = new FileLocation(xmlFilePath);
						if(xmlFile.fileBridge.exists){
							xmlFile.fileBridge.deleteFile()
						}
					}
					// refresh after deleting so that the user can see the
					// change immediately, instead of waiting for the file
					// system watcher, which might take a second or two
					if (parentFileWrapper)
					{
						treeView.refreshItem(parentFileWrapper);
					}

				}
			}

			/*
				* @local
				* Rename file/folder
				*/
			function renameFileFolder(rendererObject:FileWrapperHierarchicalItemRenderer):void
			{
				dispatcher.dispatchEvent(new RenameEvent(RenameEvent.EVENT_OPEN_RENAME_FILE_VIEW, rendererObject.data));
			}

			/*
			* @local
			* Checks if multi-selection is valid to proceed
			* against context-menu options
			*/
			function isMultiSelectionIsValid():Boolean
			{
				var hasProjectRoot:Boolean;
				var hasProjectFiles:Boolean;
				for each (var fw:FileWrapper in treeView.selectedItems)
				{
					if(fw.isRoot) hasProjectRoot = true;
					else hasProjectFiles = true;

					// terminate if any file do not exists
					if(!fw.file.fileBridge.exists)
					{
						Alert.show("One or more files to the selection does not exists.", "Error");
						return false;
					}
				}

				// terminates if project and project's files selected at same time
				if(hasProjectFiles && hasProjectRoot)
				{
					Alert.show("Project and files of projects are not allowed to bulk delete.", "Error");
					return false;
				}

				// terminate if multiple projects are trying to delete
				// (based on the current popup confirmation design with files to be deleted - 
				// we should show only confirmation to reduce complexity
				if(hasProjectRoot && treeView.selectedItems.length > 1)
				{
					Alert.show("Multiple projects are are not allowed to bulk delete.", "Error");
					return false;
				}

				return true;
			}

			/*
			* @local
			* opens a folder or open a file
			*/
			function openFileFolder(fws:Array):void
			{
				var tmpFLs:Array = [];
				var tmpFWs:Array = [];
				for each (var fw:FileWrapper in fws)
				{
					if(fw.file.fileBridge.isDirectory && fw.file.fileBridge.isDirectory)
					{
						treeView.expandItem(fw, true);
					}
					else
					{
						tmpFLs.push(fw.file);
						tmpFWs.push(fw);
					}
				}

				if(tmpFLs.length > 0)
				{
					dispatcher.dispatchEvent(new OpenFileEvent(OpenFileEvent.OPEN_FILE, tmpFLs, -1, tmpFWs));
				}
			}
		}
			
		private function onCloseProjectRequest(event:ProjectEvent):void
		{
			onFileDeletedOnServer([event.anObject], ProjectTreeContextMenuItem.CLOSE);
		}
	
		private function onFileDeletedOnServer(value:Array, removalType:String = null):void
		{
			if(!value) return;

			var parentCollection:Array;
			var tmpProject:ProjectVO;
			var lastSelectedItem:Object = treeView.selectedItem;
			var lastProcessedProjectPath:String;
			// if the file/folder is a project root
			if(value[0].isRoot)
			{
				tmpProject = UtilsCore.getProjectFromProjectFolder(value[0]);
				UtilsCore.closeAllRelativeEditors(tmpProject ? tmpProject : value[0], (removalType == ProjectTreeContextMenuItem.CLOSE ? false : true), function ():void
				{
					for each (var project:ProjectVO in model.projects)
					{
						if(project.projectFolder.nativePath === value[0].nativePath)
						{
							model.projects.removeItem(project);
							dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.REMOVE_PROJECT, project));
							break;
						}
					}
				});
			} else
			{
				for each (var fw:FileWrapper in value)
				{
					deleteFileWrapper = fw;
					proceedWithDeletionOfNode(fw);
				}
			}

			function proceedWithDeletionOfNode(value:FileWrapper):void
			{
				// search through open projects as we don't know
				// which project the FileWrapper is belongs to
				for each (var fw:FileWrapper in model.selectedprojectFolders)
				{
					parentCollection = findFilePosition(fw);
					if(parentCollection) break;
				}

				try
				{
					// this is a scenario when both parent and children
					// get selected and called for deletion
					parentCollection.splice(parentCollection.indexOf(value), 1);
					if(lastSelectedItem && lastSelectedItem == value)
					{
						var parentItem:Object = treeView.getParentItem(value);
						treeView.selectedItem = parentItem as FileWrapper;
					}
				} catch (e:Error)
				{
					return;
				}

				fileCollection = null;

				// check if the wrapper is the source folder to the project
				if(lastProcessedProjectPath != value.projectReference.path)
				{
					tmpProject = UtilsCore.getProjectFromProjectFolder(value);
				}
				if(tmpProject && (tmpProject is AS3ProjectVO) && (tmpProject as AS3ProjectVO).sourceFolder)
				{
					if((tmpProject as AS3ProjectVO).sourceFolder.fileBridge.nativePath == value.nativePath)
					{
						(tmpProject as AS3ProjectVO).sourceFolder = null;
					}
				}

				dispatcher.dispatchEvent(new TreeMenuItemEvent(TreeMenuItemEvent.FILE_DELETED, null, deleteFileWrapper));
			}
		}
	
		private function findFilePosition(value:FileWrapper):Array
		{
			var tmpChildren:Array = value.children;

			for (var i:int = 0; i < tmpChildren.length; i++)
			{
				if(tmpChildren[i] == deleteFileWrapper)
				{
					fileCollection = tmpChildren;
					return tmpChildren;
				}

				if(fileCollection) return fileCollection;
				if(tmpChildren[i].children && (tmpChildren[i].children as Array).length > 0)
				{
					findFilePosition(tmpChildren[i]);
				}
			}

			return (fileCollection) ? fileCollection : null;
		}

		private function handleProjectsChange(event:CollectionEvent):void
		{
			var project:ProjectVO = null;
			var timeoutValue:uint;
			switch (event.kind)
			{
				case CollectionEventKind.REMOVE:
				{
					project = event.items[0] as ProjectVO;
					// after a project renaming, and updating its internal fields
					// direct search (i.e. getItemIndex) of fileWrapper object in the collection
					// returns -1 even the fileWrapper object and object inside the collection has same
					// instance id. Thus a different approach it needs to parse by its uid value
					var lastSelectedItem:FileWrapper = treeView.selectedItem;
					var tmpFWIndex:int = UtilsCore.findFileWrapperIndexByID(project.projectFolder, model.selectedprojectFolders);
					model.selectedprojectFolders.removeItemAt(tmpFWIndex);
					timeoutValue = setTimeout(function ():void
					{
						if(treeView.isItemVisible(lastSelectedItem))
						{
							treeView.selectedItem = lastSelectedItem;
						} else if(model.selectedprojectFolders.length != 0)
						{
							try
							{
								treeView.selectedItem = (--tmpFWIndex != -1) ? model.selectedprojectFolders[tmpFWIndex] : model.selectedprojectFolders[++tmpFWIndex];
							}
							catch (e:Error) {}
						}
						clearTimeout(timeoutValue);
						if (treeView.selectedItem)
						{
							refreshActiveProject(treeView.selectedItem.file);
						}
					}, 100);
					break;
				}
				case CollectionEventKind.ADD:
				{
					project = model.projects.getItemAt(event.location) as ProjectVO;
					model.selectedprojectFolders.addItemAt(project.projectFolder, 0);
					
					if (((project is AS3ProjectVO) && (project as AS3ProjectVO).isVisualEditorProject))
					{
						refreshFileFolder(project.projectFolder, project);
					}
					
					timeoutValue = setTimeout(function ():void
					{
						treeView.selectedItem = project.projectFolder;
						clearTimeout(timeoutValue);
						if (treeView.selectedItem)
						{
							refreshActiveProject(treeView.selectedItem.file);
						}
						if(ConstantsCoreVO.STARTUP_PROJECT_OPEN_QUEUE_LEFT > 0) ConstantsCoreVO.STARTUP_PROJECT_OPEN_QUEUE_LEFT--;
					}, 1000);

					break;
				}
			}
		}
	
		private function onNewFilesFoldersCopied(event:TreeMenuItemEvent):void
		{
			var insideLocation:FileWrapper = TreeMenuItemEvent(event).data;

			// refresh the folder section and select
			treeView.selectedItem = insideLocation;
			refreshByWrapperItem(insideLocation);
			treeView.expandItem(insideLocation, true);
		}
	
		private function onProjectRenameRequest(event:RenameApplicationEvent):void
		{
			for each (var as3Project:AS3ProjectVO in model.projects)
			{
				if(as3Project.folderLocation.fileBridge.nativePath == event.from.fileBridge.nativePath)
				{
					as3Project.projectFolder.file = as3Project.folderLocation = as3Project.classpaths[0] = event.to;
					//as3Project.projectFolder.projectReference.name = event.to.fileBridge.name;
					as3Project.projectFolder.projectReference.path = event.to.fileBridge.nativePath;

					refreshByWrapperItem(as3Project.projectFolder);

					var timeoutValue:uint = setTimeout(function ():void
					{
						treeView.selectedItem = as3Project.projectFolder;

						treeView.scrollToItem(as3Project.projectFolder);
						clearTimeout(timeoutValue);
					}, 300);
					break;
				}
			}
		}

        private function handleScrollFromSource(event:ProjectEvent):void
        {
            var basicTextEditor:BasicTextEditor = model.activeEditor as BasicTextEditor;
            if (basicTextEditor)
            {
                var activeEditorFile:FileLocation = basicTextEditor.currentFile;
                var activeFilePath:String = activeEditorFile.fileBridge.nativePath;
                var childrenForOpen:Array = activeFilePath.split(activeEditorFile.fileBridge.separator);
                treeView.expandChildrenByName("name", childrenForOpen);
				var fw:FileWrapper = new FileWrapper(activeEditorFile);
				treeView.scrollToItem(fw);
				treeView.selectedItem = fw;
            }
        }
	
		private function onProjectFilesUpdates(event:ProjectEvent):void
		{
			treeView.refreshItem(event.anObject as FileWrapper);
		}
	
		private function onProjectTreeUpdates(event:ProjectEvent):void
		{
			model.selectedprojectFolders.addItemAt(event.project.projectFolder, 0);

			// I don't know why the heck projectFolders having null value from where
			// is a fix to the probelm for now
			if(!ConstantsCoreVO.IS_AIR)
			{
				for (var i:int = 0; i < model.selectedprojectFolders.length; i++)
				{
					if(model.selectedprojectFolders[i] == null)
					{
						model.selectedprojectFolders.removeItemAt(i);
						i--;
					}
				}
			}
		}

		private function onSelectedProjectFoldersChange(event:CollectionEvent):void
		{
			setFeathersTreeViewData(model.selectedprojectFolders);
		}

		private function onWorkspacesForViewsChange(event:CollectionEvent):void
		{
			setFeathersWorkspaceData(WorkspacePlugin.workspacesForViews);
		}
    }
}