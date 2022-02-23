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
package actionScripts.plugin.project
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.net.SharedObject;
	
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import __AS3__.vec.Vector;
	
	import actionScripts.events.AddTabEvent;
	import actionScripts.events.CustomCommandsEvent;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.RefreshTreeEvent;
	import actionScripts.events.ShowSettingsEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.SettingsView;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	import actionScripts.ui.LayoutModifier;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.menu.MenuPlugin;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.utils.SharedObjectUtil;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.FileWrapper;
	import actionScripts.valueObjects.ProjectReferenceVO;
	import actionScripts.valueObjects.ProjectVO;
	
	import components.popup.RunCommandPopup;
	import components.views.project.OpenResourceView;
	import components.views.project.TreeView;
	import actionScripts.events.WatchedFileChangeEvent;

    public class ProjectPlugin extends PluginBase implements IPlugin, ISettingsProvider
	{
		public static const EVENT_PROJECT_SETTINGS:String = "projectSettingsEvent";
		public static const EVENT_SHOW_OPEN_RESOURCE:String = "showOpenResource";
		
		override public function get name():String 	{return "Project Plugin";}
		override public function get author():String 		{return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team";}
		override public function get description():String 	{return "Provides project settings.";}
		
		private var treeView:TreeView;
		private var openResourceView:OpenResourceView;
		private var lastActiveProjectMenuType:String;
		private var customCommandPopup:RunCommandPopup;

		public function ProjectPlugin()
		{
			treeView = new TreeView();
			treeView.projects = model.projects;
		}

		override public function activate():void
		{
			super.activate(); 
			_activated = true;
			
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
		}

        private function handleScrollFromSource(event:ProjectEvent):void
        {
            var basicTextEditor:BasicTextEditor = model.activeEditor as BasicTextEditor;
            if (basicTextEditor)
            {
                var activeEditorFile:FileLocation = basicTextEditor.currentFile;
                var activeFilePath:String = activeEditorFile.fileBridge.nativePath;
                var childrenForOpen:Array = activeFilePath.split(activeEditorFile.fileBridge.separator);
                treeView.tree.expandChildrenByName("name", childrenForOpen);
            }
        }

		override public function deactivate():void
		{
			super.deactivate();
			_activated = false;			
			
			dispatcher.removeEventListener(EVENT_SHOW_OPEN_RESOURCE, handleShowOpenResource);
		}
		
		public function getSettingsList():Vector.<ISetting>	
		{
			return new Vector.<ISetting>();
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

		private function handleWatchedFileCreatedEvent(event:WatchedFileChangeEvent):void
		{
			//need to refresh the parent directory listing
			treeView.refresh(event.file.fileBridge.parent);
		}

		private function handleWatchedFileDeletedEvent(event:WatchedFileChangeEvent):void
		{
			//need to refresh the parent directory listing
			treeView.refresh(event.file.fileBridge.parent);
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
                            projectReferenceVO.name = project.name;
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
                    var projectFileLocation:FileLocation = model.flexCore.testFlashDevelop(projectFile);

                    if (projectFileLocation)
                    {
                        project = model.flexCore.parseFlashDevelop(null, projectFileLocation, projectLocationInfo.name);
                    }
					
					if (!project)
					{
	                    projectFileLocation = model.flexCore.testFlashBuilder(projectFile);
	                    if (projectFileLocation)
	                    {
	                        project = model.flexCore.parseFlashBuilder(projectLocation);
	                    }
					}
					
					if (!project)
					{
	                    projectFileLocation = model.javaCore.testJava(projectFile);
	                    if (projectFileLocation)
	                    {
							var javaSettingsFile:FileLocation = model.javaCore.getSettingsFile(projectFile);
	                        project = model.javaCore.parseJava(
									projectLocation,
									null,
									javaSettingsFile
							);
	                    }
					}
					
					if (!project)
					{
	                    projectFileLocation = model.groovyCore.testGrails(projectFile);
	                    if (projectFileLocation)
	                    {
	                        project = model.groovyCore.parseGrails(projectLocation, null, projectFileLocation);
	                    }
					}
					
					if (!project)
					{
	                    projectFileLocation = model.haxeCore.testHaxe(projectFile);
	                    if (projectFileLocation)
	                    {
	                        project = model.haxeCore.parseHaxe(projectLocation);
	                    }
					}
					
					if (!project)
					{
						projectFileLocation = model.ondiskCore.testOnDisk(projectFile);
						if (projectFileLocation)
						{
							project = model.ondiskCore.parseOnDisk(projectLocation);
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
    }
}