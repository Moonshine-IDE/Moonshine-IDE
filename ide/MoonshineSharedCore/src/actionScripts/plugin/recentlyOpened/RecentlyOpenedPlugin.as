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
package actionScripts.plugin.recentlyOpened
{
	import flash.events.Event;
	import flash.net.SharedObject;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	import actionScripts.events.FilePluginEvent;
	import actionScripts.events.GeneralEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.MenuEvent;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.StartupHelperEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.IMenuPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.genericproj.vo.GenericProjectVO;
	import actionScripts.plugin.settings.providers.Java8SettingsProvider;
	import actionScripts.plugin.settings.providers.JavaSettingsProvider;
	import actionScripts.ui.LayoutModifier;
	import actionScripts.ui.menu.vo.MenuItem;
	import actionScripts.ui.menu.vo.ProjectMenuTypes;
	import actionScripts.utils.OSXBookmarkerNotifiers;
	import actionScripts.utils.ObjectTranslator;
	import actionScripts.utils.SDKUtils;
	import actionScripts.utils.SharedObjectConst;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.MobileDeviceVO;
	import actionScripts.valueObjects.ProjectReferenceVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.SDKReferenceVO;
	import actionScripts.ui.project.ProjectTreeView;

	public class RecentlyOpenedPlugin extends PluginBase implements IMenuPlugin
	{
		public static const RECENT_PROJECT_LIST_UPDATED:String = "RECENT_PROJECT_LIST_UPDATED";
		public static const RECENT_FILES_LIST_UPDATED:String = "RECENT_FILES_LIST_UPDATED";
		
		override public function get name():String			{ return "Recently Opened Plugin"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String	{ return "Stores the last opened file paths."; }
		
		private var cookie:SharedObject;
		private var recentOpenedProjectObject:FileLocation;
		
		private var recentFilesListUpdatedTimeoutID:uint = uint.MAX_VALUE;
		private var recentProjectListUpdatedTimeoutID:uint = uint.MAX_VALUE;

		override public function activate():void
		{
			super.activate();
			
			cookie = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);

			if (model.recentlyOpenedFiles.length == 0)
			{
				restoreFromCookie();
			}
			
			dispatcher.addEventListener(ProjectEvent.ADD_PROJECT, handleAddProject);
			dispatcher.addEventListener(ProjectEvent.EVENT_SAVE_PROJECT_CREATION_FOLDERS, onNewProjectPathBrowse, false, 0, true);
			//dispatcher.addEventListener(ProjectEvent.ADD_PROJECT_AWAY3D, handleAddProject, false, 0, true);
			dispatcher.addEventListener(ProjectEvent.FLEX_SDK_UDPATED, onFlexSDKUpdated);
			dispatcher.addEventListener(ProjectEvent.WORKSPACE_UPDATED, onWorkspaceUpdated);
			dispatcher.addEventListener(SDKUtils.EVENT_SDK_PROMPT_DNS, onSDKExtractDNSUpdated);
			dispatcher.addEventListener(StartupHelperEvent.EVENT_DNS_GETTING_STARTED, onGettingStartedDNSUpdated);
			dispatcher.addEventListener(FilePluginEvent.EVENT_JAVA_TYPEAHEAD_PATH_SAVE, onJavaPathForTypeaheadSave);
			dispatcher.addEventListener(LayoutModifier.SAVE_LAYOUT_CHANGE_EVENT, onSaveLayoutChangeEvent);
			dispatcher.addEventListener(GeneralEvent.DEVICE_UPDATED, onDeviceListUpdated, false, 0, true);
			dispatcher.addEventListener(RecentlyOpenedPlugin.RECENT_PROJECT_LIST_UPDATED, updateRecentProjectList);
			dispatcher.addEventListener(RecentlyOpenedPlugin.RECENT_FILES_LIST_UPDATED, updateRecetFileList);
			// Give other plugins a chance to cancel the event
			dispatcher.addEventListener(FilePluginEvent.EVENT_FILE_OPEN, handleOpenFile, false, -100);
			dispatcher.addEventListener(GeneralEvent.EVENT_FILE_BROWSED, onFileLocationBrowsed, false, 0, true);
			
			if (ConstantsCoreVO.IS_AIR)
			{
				dispatcher.addEventListener("eventOpenRecentProject", onOpenRecentProject, false, 0, true);
				dispatcher.addEventListener("eventOpenRecentFile", onOpenRecentFile, false, 0, true);
			}
		}
		
		public function getMenu():MenuItem
		{
			return UtilsCore.getRecentFilesMenu();
		}
		
		override public function resetSettings():void
		{
			if (cookie.data.hasOwnProperty('recentFiles')) 
				delete cookie.data['recentFiles'];
			if (cookie.data.hasOwnProperty('recentProjects')) 
				delete cookie.data['recentProjects'];
			if (cookie.data.hasOwnProperty('recentProjectsOpenedOption')) 
				delete cookie.data['recentProjectsOpenedOption'];
			if (cookie.data.hasOwnProperty('lastBrowsedLocation')) 
				delete cookie.data['lastBrowsedLocation'];
			cookie.flush();
			
			model.recentlyOpenedFiles = new ArrayCollection();
			model.recentlyOpenedProjects = new ArrayCollection();
			model.recentlyOpenedProjectOpenedOption = new ArrayCollection();
			model.recentSaveProjectPath = new ArrayCollection();

			dispatcher.dispatchEvent(new Event(RECENT_PROJECT_LIST_UPDATED));
			dispatcher.dispatchEvent(new Event(RECENT_FILES_LIST_UPDATED));
		}
		
		private function restoreFromCookie():void
		{
			// Uncomment & run to delete cookie
			//delete cookie.data.recentFiles;
			//delete cookie.data.recentProjects;
			
			// Load & unserialize recent items
			var recentFiles:Array = cookie.data.recentFiles;
			var recent:Array = [];
			var f:FileLocation;
			var file:Object;
			var object:Object;
			var projectReferenceVO:ProjectReferenceVO;
			if (cookie.data.hasOwnProperty('recentFiles'))
			{
				if (!ConstantsCoreVO.IS_AIR)
				{
					model.recentlyOpenedProjectOpenedOption.source = cookie.data.recentProjectsOpenedOption;
				}
				else
				{
					recentFiles = cookie.data.recentFiles;
                    for (var i:int = 0; i < recentFiles.length; i++)
					{
						file = recentFiles[i];
						projectReferenceVO = ProjectReferenceVO.getNewRemoteProjectReferenceVO(file);
						if (projectReferenceVO.path && projectReferenceVO.path != "")
						{
							f = new FileLocation(projectReferenceVO.path);
							if (f.fileBridge.exists)
							{
								recent.push(projectReferenceVO);
                            }
							else
							{
								cookie.data.recentFiles.splice(i, 1);
							}
						}
					}

                    cookie.flush();
					model.recentlyOpenedFiles.source = recent;
				}
			}
			
			if (cookie.data.hasOwnProperty('recentProjects'))
			{
				// git#1230 since I don't have a good way to determine which 
				// entry was suppose to be displayed and which entry duplicated with
				// different 'name', it's problematic to choose between them;
				// thus a force list-clean approach probably helpful to clear-out
				// already cluttered so list with duplicated items; This should run once
				if (!cookie.data.hasOwnProperty("git1230forceClean"))
				{
					cookie.data.recentProjects = [];
					cookie.data.recentProjectsOpenedOption = [];
					cookie.data["git1230forceClean"] = true;
					cookie.flush();
					recentFiles = [];
				}
				
				recentFiles = cookie.data.recentProjects;
				recent = [];

				for (var j:int = 0; j < recentFiles.length; j++)
				{
					file = recentFiles[j];
					projectReferenceVO = ProjectReferenceVO.getNewRemoteProjectReferenceVO(file);
					if (projectReferenceVO.path && projectReferenceVO.path != "")
					{
						f = new FileLocation(projectReferenceVO.path);
						if (f.fileBridge.exists)
						{
							recent.push(projectReferenceVO);
						}
						else
						{
							cookie.data.recentProjects.splice(j, 1);
						}
					}
				}
				cookie.flush();
				model.recentlyOpenedProjects.source = recent;
			}
			
			if (cookie.data.hasOwnProperty('recentProjectsOpenedOption'))
			{
				if (!ConstantsCoreVO.IS_AIR)
				{
					model.recentlyOpenedProjectOpenedOption.source = cookie.data.recentProjectsOpenedOption;
				}
				else
				{
					var recentProjectsOpenedOptions:Array = cookie.data.recentProjectsOpenedOption;
					recent = [];
					for each (object in recentProjectsOpenedOptions)
					{
						f = new FileLocation(object.path);
						if (f.fileBridge.exists) recent.push(object);
					}
					model.recentlyOpenedProjectOpenedOption.source = recent;
				}
			}
			
			if (cookie.data.hasOwnProperty('userSDKs'))
			{
				for each (object in cookie.data.userSDKs)
				{
					var tmpSDK:SDKReferenceVO = SDKReferenceVO.getNewReference(object);
					if (new FileLocation(tmpSDK.path).fileBridge.exists)
					{
						model.userSavedSDKs.addItem(tmpSDK);
					}
				}
			}
			
			if (cookie.data.hasOwnProperty('lastBrowsedLocation')) 
			{
				ConstantsCoreVO.LAST_BROWSED_LOCATION = cookie.data.lastBrowsedLocation;
				if (!model.fileCore.isPathExists(ConstantsCoreVO.LAST_BROWSED_LOCATION))
				{
					ConstantsCoreVO.LAST_BROWSED_LOCATION = null;
				}
				else
				{
					model.fileCore.nativePath = ConstantsCoreVO.LAST_BROWSED_LOCATION;
				}
			}

			if (cookie.data.hasOwnProperty('recentProjectPath'))
			{
				model.recentSaveProjectPath.source = cookie.data.recentProjectPath;
				if (cookie.data.hasOwnProperty('lastSelectedProjectPath'))
				{
					model.lastSelectedProjectPath = cookie.data.lastSelectedProjectPath;
				}
			}
			
			if (cookie.data.hasOwnProperty('moonshineWorkspace'))
			{
				OSXBookmarkerNotifiers.workspaceLocation = new FileLocation(cookie.data.moonshineWorkspace);
			}

			if (cookie.data.hasOwnProperty('isWorkspaceAcknowledged'))
			{
				OSXBookmarkerNotifiers.isWorkspaceAcknowledged = (cookie.data["isWorkspaceAcknowledged"] == "true") ? true : false;
			}

			if (cookie.data.hasOwnProperty('isBundledSDKpromptDNS'))
			{
				ConstantsCoreVO.IS_BUNDLED_SDK_PROMPT_DNS = (cookie.data["isBundledSDKpromptDNS"] == "true") ? true : false;
			}

			if (cookie.data.hasOwnProperty('isSDKhelperPromptDNS'))
			{
				ConstantsCoreVO.IS_SDK_HELPER_PROMPT_DNS = (cookie.data["isSDKhelperPromptDNS"] == "true") ? true : false;
			}

			if (cookie.data.hasOwnProperty('isGettingStartedDNS'))
			{
				ConstantsCoreVO.IS_GETTING_STARTED_DNS = (cookie.data["isGettingStartedDNS"] == "true") ? true : false;
			}

			if (cookie.data.hasOwnProperty('devicesAndroid'))
			{
				ConstantsCoreVO.TEMPLATES_ANDROID_DEVICES = new ArrayCollection();
				ConstantsCoreVO.TEMPLATES_IOS_DEVICES = new ArrayCollection();
				
				for each (object in cookie.data.devicesAndroid)
				{
					ConstantsCoreVO.TEMPLATES_ANDROID_DEVICES.addItem(ObjectTranslator.objectToInstance(object, MobileDeviceVO));
				}
				for each (object in cookie.data.devicesIOS)
				{
					ConstantsCoreVO.TEMPLATES_IOS_DEVICES.addItem(ObjectTranslator.objectToInstance(object, MobileDeviceVO));
				}
			}
			else
			{
				ConstantsCoreVO.generateDevices();
			}
			if (cookie.data.hasOwnProperty('javaPathForTypeahead')) 
			{
				model.javaPathForTypeAhead = new FileLocation(cookie.data["javaPathForTypeahead"]);
				
				var javaSettingsProvider:JavaSettingsProvider = new JavaSettingsProvider();
				javaSettingsProvider.currentJavaPath = model.javaPathForTypeAhead.fileBridge.nativePath;
			}
			if (cookie.data.hasOwnProperty('java8Path')) 
			{
				model.java8Path = new FileLocation(cookie.data["java8Path"]);
				
				var java8SettingsProvider:Java8SettingsProvider = new Java8SettingsProvider();
				java8SettingsProvider.currentJava8Path = model.java8Path.fileBridge.nativePath;
			}
			
			LayoutModifier.parseCookie(cookie);
		}

		private function handleAddProject(event:ProjectEvent):void
		{
			// Find & remove project if already present
			//var f:File = (event.project.projectFile) ? event.project.projectFile : event.project.folder;
			var f:FileLocation = event.project.folderLocation;
			var toRemove:int = -1;
			for each (var projectReference:Object in model.recentlyOpenedProjects)
			{
				if ((projectReference.name == event.project.name) && 
					(projectReference.path == f.fileBridge.nativePath))
				{
					toRemove = model.recentlyOpenedProjects.getItemIndex(projectReference);
					break;
				}
			}
			if (toRemove != -1) 
			{
				model.recentlyOpenedProjects.removeItemAt(toRemove);
				model.recentlyOpenedProjectOpenedOption.removeItemAt(toRemove);
			}
			
			var customSDKPath:String = null;
			if(event.project is AS3ProjectVO)
			{
				customSDKPath = (event.project as AS3ProjectVO).buildOptions.customSDKPath;
			}
			var tmpSOReference: ProjectReferenceVO = new ProjectReferenceVO();
			tmpSOReference.sdk = customSDKPath ? customSDKPath : (model.defaultSDK ? model.defaultSDK.fileBridge.nativePath : null);
			tmpSOReference.path = event.project.folderLocation.fileBridge.nativePath;
			tmpSOReference.sourceFolder = event.project.sourceFolder;
			tmpSOReference.name = event.project.name;
			//tmpSOReference.projectId = event.project.projectId;
			//tmpSOReference.isAway3D = (event.type == ProjectEvent.ADD_PROJECT_AWAY3D);
			
			model.recentlyOpenedProjects.addItemAt(tmpSOReference, 0);
			model.recentlyOpenedProjectOpenedOption.addItemAt({path:f.fileBridge.nativePath, option:(event.extras ? event.extras[0] : "")}, 0);
			
			//Moon-166 fix: This will set selected project in the tree view
			/*var tmpTreeView:ProjectTreeView = model.mainView.getTreeViewPanel();
			tmpTreeView.selectedItem = model.activeProject.projectFolder;*/
			
			var timeoutValue:uint = setTimeout(function():void{
				var tmpTreeView:ProjectTreeView = model.mainView.getTreeViewPanel();
				if (tmpTreeView && model.activeProject)
				{
					tmpTreeView.selectedItem = model.activeProject.projectFolder;
                }
				clearTimeout(timeoutValue);
			}, 200);

			// when the recently opened projects collection is updated, we need
			// to dispatch RECENT_PROJECT_LIST_UPDATED. the listener(s) for this
			// event are somewhat expensive, so we should wait to see if any
			// more projects have been opened before dispatching it, so that we
			// trigger the expensive code as little as possible.
			if (recentProjectListUpdatedTimeoutID != uint.MAX_VALUE)
			{
				clearTimeout(recentProjectListUpdatedTimeoutID);
				recentProjectListUpdatedTimeoutID = uint.MAX_VALUE;
			}
			recentProjectListUpdatedTimeoutID = setTimeout(function():void
			{
				recentProjectListUpdatedTimeoutID = uint.MAX_VALUE;
				dispatcher.dispatchEvent(new Event(RECENT_PROJECT_LIST_UPDATED));
			}, 300);
		}
		
		private function handleOpenFile(event:FilePluginEvent):void
		{
			if (event.isDefaultPrevented()) return;

			// File might have been removed
			var f:FileLocation = event.file;
			if (!f || !f.fileBridge.exists) return;			
			
			// Find item & remove it if already present (path-based, since it's two different File objects)
			var toRemove:int = -1;
			for each (var file:Object in model.recentlyOpenedFiles)
			{
				if (file.path == f.fileBridge.nativePath)
				{
					toRemove = model.recentlyOpenedFiles.getItemIndex(file);
					break;
				}
			}
			if (toRemove != -1) model.recentlyOpenedFiles.removeItemAt(toRemove);
			
			var tmpSOReference: ProjectReferenceVO = new ProjectReferenceVO();
			//tmpSOReference.name = f.fileBridge.name;
			tmpSOReference.path = f.fileBridge.nativePath;
			model.recentlyOpenedFiles.addItemAt(tmpSOReference, 0);
			//model.selectedprojectFolders
			
			// when the recently opened files collection is updated, we need
			// to dispatch RECENT_FILES_LIST_UPDATED. the listener(s) for this
			// event are somewhat expensive, so we should wait to see if any
			// more projects have been opened before dispatching it, so that we
			// trigger the expensive code as little as possible.
			if (recentFilesListUpdatedTimeoutID != uint.MAX_VALUE)
			{
				clearTimeout(recentFilesListUpdatedTimeoutID);
				recentFilesListUpdatedTimeoutID = uint.MAX_VALUE;
			}
			recentFilesListUpdatedTimeoutID = setTimeout(function():void
			{
				recentFilesListUpdatedTimeoutID = uint.MAX_VALUE;
				dispatcher.dispatchEvent(new Event(RECENT_FILES_LIST_UPDATED));
			}, 300);
		}
		
		private function onFileLocationBrowsed(event:GeneralEvent):void
		{
			cookie.data['lastBrowsedLocation'] = ConstantsCoreVO.LAST_BROWSED_LOCATION;
			cookie.flush();
		}
		
		private function updateRecentProjectList(event:Event):void
		{
			save(model.recentlyOpenedProjects.source, 'recentProjects');
			save(model.recentlyOpenedProjectOpenedOption.source, 'recentProjectsOpenedOption');
		}
		
		private function updateRecetFileList(event:Event):void
		{
			save(model.recentlyOpenedFiles.source, 'recentFiles');
		}
		
		private function onFlexSDKUpdated(event:ProjectEvent):void
		{
			// we need some works here, we don't 
			// wants any bundled SDKs to be saved in 
			// the saved list
			var tmpArr:Array = [];
			for each (var i:SDKReferenceVO in model.userSavedSDKs)
			{
				if (i.status != SDKUtils.BUNDLED) tmpArr.push(i);
			}
			
			// and then save
			save(tmpArr, 'userSDKs');
		}
		
		private function onWorkspaceUpdated(event:ProjectEvent):void
		{
			if ((OSXBookmarkerNotifiers.workspaceLocation != null) && OSXBookmarkerNotifiers.workspaceLocation.fileBridge.exists) cookie.data["moonshineWorkspace"] = OSXBookmarkerNotifiers.workspaceLocation.fileBridge.nativePath;
			cookie.data["isWorkspaceAcknowledged"] = OSXBookmarkerNotifiers.isWorkspaceAcknowledged.toString();
			cookie.flush();
		}
		
		private function onSDKExtractDNSUpdated(event:Event):void
		{
			cookie.data["isBundledSDKpromptDNS"] = ConstantsCoreVO.IS_BUNDLED_SDK_PROMPT_DNS.toString();
			cookie.data["isSDKhelperPromptDNS"] = ConstantsCoreVO.IS_SDK_HELPER_PROMPT_DNS.toString();
			cookie.flush();
		}
		
		private function onGettingStartedDNSUpdated(event:Event):void
		{
			cookie.data["isGettingStartedDNS"] = ConstantsCoreVO.IS_GETTING_STARTED_DNS.toString();
			cookie.flush();
		}
		
		private function onJavaPathForTypeaheadSave(event:FilePluginEvent):void
		{
			if (event.file)
			{
				cookie.data["javaPathForTypeahead"] = event.file.fileBridge.nativePath;
			}
			else
			{
				delete cookie.data["javaPathForTypeahead"];
			}
			cookie.flush();
		}
		
		private function onSaveLayoutChangeEvent(event:GeneralEvent):void
		{
			cookie.data[event.value.label] = event.value.value;
			cookie.flush();
		}
		
		private function onDeviceListUpdated(event:GeneralEvent):void
		{
			cookie.data["devicesAndroid"] = ConstantsCoreVO.TEMPLATES_ANDROID_DEVICES.source;
			cookie.data["devicesIOS"] = ConstantsCoreVO.TEMPLATES_IOS_DEVICES.source;
			cookie.flush();
		}

		private function onNewProjectPathBrowse(event:Event):void
		{
			cookie.data["lastSelectedProjectPath"] = model.lastSelectedProjectPath;
			cookie.data["recentProjectPath"] = model.recentSaveProjectPath.source;
			cookie.flush();
		}
		
		private function save(recent:Array, key:String):void
		{
			// Only save the ten latest files
			/*if (recent.length > 10)
			{
				recent = recent.slice(0, 10);
			}*/
			// Serialize down to paths
			var toSave:Array = [];
			for each (var f:Object in recent)
			{
				if (f is FileLocation)
				{
					toSave.push(f.fileBridge.nativePath);
				}
				else if (f is ProjectReferenceVO)
				{
					var projectRef:ProjectReferenceVO = ProjectReferenceVO(f);
					toSave.push(ProjectReferenceVO.serializeForSharedObject(projectRef));
				}
				else
				{
					toSave.push(f);
				}
			}
			
			// Add to LocalObject
			cookie.data[key] = toSave;
			cookie.flush();
		}
		
		private function onOpenRecentProject(menuEvent:MenuEvent):void
		{
			openRecentItem(menuEvent.data as ProjectReferenceVO);
		}
		
		private function onOpenRecentFile(menuEvent:MenuEvent):void
		{
			openRecentItem(menuEvent.data as ProjectReferenceVO);
		}
		
		protected function openRecentItem(refVO:ProjectReferenceVO):void
		{
			// do not open an already opened project
			if(model.mainView.getTreeViewPanel() && UtilsCore.checkProjectIfAlreadyOpened(refVO.path)) return;
			
			// desktop
			if(ConstantsCoreVO.IS_AIR)
			{
				recentOpenedProjectObject = new FileLocation(refVO.path);
				
				if(!FileLocation(recentOpenedProjectObject).fileBridge.exists)
				{
					Alert.show("Can't import: The file does not exist anymore.", "Error!");
					return;
				}
				
				if(recentOpenedProjectObject.fileBridge.isDirectory)
				{
					var project:ProjectVO;
					var lastOpenedOption:String;
					
					// check if any last opend option is associated with the project
					for each (var i:Object in model.recentlyOpenedProjectOpenedOption)
					{
						if(i.path == recentOpenedProjectObject.fileBridge.nativePath)
						{
							lastOpenedOption = i.option;
							break;
						}
					}
					
					project = getProjectBasedOnFileOption(lastOpenedOption, refVO.name);
					
					if(!project)
					{
						Alert.show("Can't import: Not a valid " + ConstantsCoreVO.MOONSHINE_IDE_LABEL + " project directory.", "Error!");
						return;
					}
					
					// save old sdk details to the project
					if(project is AS3ProjectVO)
					{
						var as3Project:AS3ProjectVO = AS3ProjectVO(project);
						as3Project.buildOptions.oldDefaultSDKPath = refVO.sdk;
					}
					
					// trigger the project to open
					GlobalEventDispatcher.getInstance().dispatchEvent(
						new ProjectEvent(ProjectEvent.ADD_PROJECT, project, lastOpenedOption));
				} else
				{
					GlobalEventDispatcher.getInstance().dispatchEvent(
						new OpenFileEvent(OpenFileEvent.OPEN_FILE, [recentOpenedProjectObject as FileLocation])
					);
				}
			}
		}
		
		private function getProjectBasedOnFileOption(lastOpenedOption:String, projectName:String):ProjectVO
		{
			var projectFile:Object = recentOpenedProjectObject.fileBridge.getFile;
			var projectFileLocation:FileLocation;
			
			if(!lastOpenedOption ||
				lastOpenedOption == ProjectEvent.LAST_OPENED_AS_FB_PROJECT ||
				lastOpenedOption == ProjectEvent.LAST_OPENED_AS_FD_PROJECT)
			{
				try
				{
					var project:ProjectVO = model.projectCore.parseProject(recentOpenedProjectObject);
					if (project)
					{
						return project;
					}
				}
				catch(e:Error)
				{
					error("Failed to open project: " + recentOpenedProjectObject.fileBridge.nativePath);
					error(e.message +"\n"+ e.getStackTrace());
					return null;
				}
			}
			
			return null;
		}
	}
}