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
package actionScripts.plugin.workspace
{
import actionScripts.events.GeneralEvent;
import actionScripts.plugin.settings.ISettingsProvider;
import actionScripts.plugin.settings.event.LinkOnlySettingsEvent;
import actionScripts.plugin.settings.vo.ISetting;
import actionScripts.plugin.settings.vo.LinkOnlySetting;
import actionScripts.plugin.settings.vo.LinkOnlySettingVO;
import actionScripts.plugin.workspace.settings.WorkspaceItemSetting;

import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.net.SharedObject;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayList;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	import mx.utils.ObjectUtil;
	
	import actionScripts.events.ProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.ui.FeathersUIWrapper;
	import actionScripts.utils.MethodDescriptor;
	import actionScripts.utils.SharedObjectConst;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.WorkspaceVO;
	
	import feathers.data.ArrayCollection;
	
	import moonshine.data.preferences.MoonshinePreferences;
	import moonshine.plugin.workspace.events.WorkspaceEvent;
	import moonshine.plugin.workspace.view.LoadWorkspaceView;
	import moonshine.plugin.workspace.view.NewWorkspaceView;

import spark.components.Alert;

public class WorkspacePlugin extends PluginBase implements ISettingsProvider
	{
		public static const EVENT_SAVE_AS:String = "saveAsNewWorkspaceEvent";
		public static const EVENT_NEW:String = "newWorkspaceEvent";
		public static const EVENT_LOAD:String = "loadWorkspaceEvent";
		public static const EVENT_WORKSPACE_CHANGED:String = "workspaceChangedEvent";
		
		private static const LABEL_DEFAULT_WORKSPACE:String = "IDE-Default";
		
		override public function get name():String 			{return "Workspace";}
		override public function get author():String 		{return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team";}
		override public function get description():String 	{return "Workspace manangement for the Moonshine projects.";}

		[Bindable]
		public static var workspacesForViews:ArrayList;

		private var cookie:SharedObject;
		private var currentWorkspacePaths:Array;
		private var workspaces:Object; // Dictionary<String, [String]>
		private var methodToCallAfterClosingAllProjects:MethodDescriptor;
		private var closeAllProjectItems:Array;
		private var settings:Vector.<ISetting>;
		private var linkOnlySetting:LinkOnlySetting;
		
		private var loadWorkspaceView:LoadWorkspaceView;
		private var loadWorkspaceViewWrapper:FeathersUIWrapper;

		private var newWorkspaceView:NewWorkspaceView;
		private var newWorkspaceViewWrapper:FeathersUIWrapper;

		private var preferences:MoonshinePreferences;
		private var selectedWorkspacesInSettings:Array = [];

		private var _currentWorkspaceLabel:String;
		private function get currentWorkspaceLabel():String
		{
			return _currentWorkspaceLabel;
		}
		private function set currentWorkspaceLabel(value:String):void
		{
			ConstantsCoreVO.CURRENT_WORKSPACE =	_currentWorkspaceLabel = value;
		}
		
		public static function getCurrentWorkspaceForView(label:String):WorkspaceVO
		{
			var workspace:WorkspaceVO;
			workspacesForViews.source.some(function(element:WorkspaceVO, index:int, arr:Array):Boolean
			{
				if (element.label == label) 
				{
					workspace = element;
					return true;
				}
				return false;
			});
			
			return workspace;
		}
		
		public function WorkspacePlugin()
		{
			super();
			preferences = MoonshinePreferences.getLocal();
		}
		
		override public function activate():void
		{
			cookie = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_WORKSPACE);
			restoreFromCookie();
			
			dispatcher.addEventListener(EVENT_SAVE_AS, onSaveAsNewWorkspaceEvent, false, 0, true);
			dispatcher.addEventListener(EVENT_NEW, onNewWorkspaceEvent, false, 0, true);
			dispatcher.addEventListener(EVENT_LOAD, onLoadWorkspaceEvent, false, 0, true);
			dispatcher.addEventListener(WorkspaceEvent.LOAD_WORKSPACE_WITH_LABEL, handleLoadWorkspaceEvent, false, 0, true);
			dispatcher.addEventListener(WorkspaceEvent.NEW_WORKSPACE_WITH_LABEL, handleNewWorkspaceEvent, false, 0, true);
			dispatcher.addEventListener(WorkspaceEvent.SAVE_AS_WORKSPACE_WITH_LABEL, handleSaveAsWorkspaceEvent, false, 0, true);
			
			dispatcher.addEventListener(ProjectEvent.ADD_PROJECT, handleAddProject);
			dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, handleRemoveProject);
		}

		public function getSettingsList():Vector.<ISetting>
		{
			settings = new Vector.<ISetting>();
			linkOnlySetting = new LinkOnlySetting(new <LinkOnlySettingVO>[
				new LinkOnlySettingVO("Add"),
				new LinkOnlySettingVO("Remove"),
				new LinkOnlySettingVO("Switch")
			]);
			linkOnlySetting.addEventListener(LinkOnlySettingsEvent.EVENT_LINK_CLICKED, onLinkItemClicked, false, 0, true);

			settings.push(linkOnlySetting);
			for each (var workspace:WorkspaceVO in workspacesForViews.source)
			{
				settings.push(
						getWorkspaceItemSetting(workspace)
				);
			}

			return settings;
		}

		private function getWorkspaceItemSetting(workspace:WorkspaceVO):WorkspaceItemSetting
		{
			var tmpSetting:WorkspaceItemSetting = new WorkspaceItemSetting(workspace);
			//tmpSetting.addEventListener(ExternalEditorSetting.EVENT_MODIFY, onEditorModify, false, 0, true);
			//tmpSetting.addEventListener(ExternalEditorSetting.EVENT_REMOVE, onEditorSettingRemove, false, 0, true);
			tmpSetting.addEventListener(WorkspaceItemSetting.EVENT_SELECT, onWorkspaceItemSelected, false, 0, true);

			return tmpSetting;
		}

		private function onWorkspaceItemSelected(event:GeneralEvent):void
		{
			var itemIndex:int = selectedWorkspacesInSettings.indexOf(event.value);
			if (itemIndex == -1)
			{
				selectedWorkspacesInSettings.push(event.value);
			}
			else
			{
				selectedWorkspacesInSettings.removeAt(itemIndex);
			}
		}
		
		private function onLinkItemClicked(event:LinkOnlySettingsEvent):void
		{
			if (event.value.label == "Add")
			{
				onNewWorkspaceEvent(null);
			}
			else if (event.value.label == "Remove")
			{
				removeWorkspaces();
			}
			else if (event.value.label == "Switch")
			{
				onLoadWorkspaceEvent(null);
			}
		}

		private function removeWorkspaces():void
		{
			if (selectedWorkspacesInSettings.length == 0)
			{
				Alert.show("Select Workspace(s) to remove.", "Note!");
			}
			else
			{
				Alert.show("Work in-progress", "Note!");
			}
		}
		
		private function handleAddProject(event:ProjectEvent):void
		{
			if (getPathIndex(event.project.folderLocation.fileBridge.nativePath) == -1)
			{
				currentWorkspacePaths.push(event.project.folderLocation.fileBridge.nativePath);
				saveToCookie();
			}
		}
		
		private function handleRemoveProject(event:ProjectEvent):void
		{	
			handleRemoveProjectByPath(event.project.folderLocation.fileBridge.nativePath);
		}
		
		private function handleRemoveProjectByPath(value:String):void
		{
			if (closeAllProjectItems && closeAllProjectItems.length > 0)
			{
				closeAllProjectItems.splice(
					closeAllProjectItems.indexOf(value), 
					1);
				closeAllEditorAsync();
			}
			else
			{
				var pathIndex:int = getPathIndex(value);
				if (pathIndex != -1)
				{
					currentWorkspacePaths.splice(pathIndex, 1);
					saveToCookie();
				}
			}
		}

		private function handleSaveAsWorkspaceEvent(event:WorkspaceEvent):void
		{
			duplicateToNewWorkspace(event.workspaceLabel);
		}

		private function onSaveAsNewWorkspaceEvent(event:Event):void
		{
			var newWorkspaceView:NewWorkspaceView = createNewWorkspaceViewWithTitle("Save As Workspace");
			newWorkspaceView.isSaveAs = true;
		}

		private function onNewWorkspaceEvent(event:Event):void
		{
			createNewWorkspaceViewWithTitle("New Workspace");
		}

		protected function newWorkspaceView_stage_resizeHandler(event:Event):void
		{
			PopUpManager.centerPopUp(newWorkspaceViewWrapper);
		}

		private function handleNewWorkspacePopupClose(event:Event):void
		{
			newWorkspaceViewWrapper.stage.removeEventListener(Event.RESIZE, newWorkspaceView_stage_resizeHandler);
			PopUpManager.removePopUp(newWorkspaceViewWrapper);
			newWorkspaceViewWrapper = null;

			newWorkspaceView.removeEventListener(Event.CLOSE, handleNewWorkspacePopupClose);
			newWorkspaceView = null;
		}
		
		private function handleNewWorkspaceEvent(event:WorkspaceEvent):void
		{
			methodToCallAfterClosingAllProjects = 
				new MethodDescriptor(this, 'changeToNewWorkspace', event.workspaceLabel);
			
			closeAllProjectItems = ObjectUtil.copy(currentWorkspacePaths) as Array;
			closeAllEditorAsync();
		}

		private function createNewWorkspaceViewWithTitle(title:String):NewWorkspaceView
		{
			newWorkspaceView = new NewWorkspaceView();
			newWorkspaceViewWrapper = new FeathersUIWrapper(newWorkspaceView);
			PopUpManager.addPopUp(newWorkspaceViewWrapper, FlexGlobals.topLevelApplication as DisplayObject, false);

			newWorkspaceView.workspaces = new ArrayCollection(workspacesForViews.source);
			newWorkspaceView.title = title;
			newWorkspaceView.addEventListener(Event.CLOSE, handleNewWorkspacePopupClose);

			PopUpManager.centerPopUp(newWorkspaceViewWrapper);
			newWorkspaceViewWrapper.assignFocus("top");
			newWorkspaceViewWrapper.stage.addEventListener(Event.RESIZE, newWorkspaceView_stage_resizeHandler, false, 0, true);

			return newWorkspaceView;
		}

		private function onLoadWorkspaceEvent(event:Event):void
		{
			loadWorkspaceView = new LoadWorkspaceView();
			loadWorkspaceViewWrapper = new FeathersUIWrapper(loadWorkspaceView);

			loadWorkspaceView.workspaces = new ArrayCollection(workspacesForViews.source);
			loadWorkspaceView.selectedWorkspace = getCurrentWorkspaceForView(currentWorkspaceLabel);
			loadWorkspaceView.addEventListener(Event.CLOSE, handleLoadWorkspacePopupClose);

			PopUpManager.addPopUp(loadWorkspaceViewWrapper, FlexGlobals.topLevelApplication as DisplayObject, false);
			PopUpManager.centerPopUp(loadWorkspaceViewWrapper);
			loadWorkspaceViewWrapper.assignFocus("top");
			loadWorkspaceViewWrapper.stage.addEventListener(Event.RESIZE, loadWorkspaceView_stage_resizeHandler, false, 0, true);
		}
		
		private function handleLoadWorkspacePopupClose(event:Event):void
		{
			loadWorkspaceViewWrapper.stage.removeEventListener(Event.RESIZE, loadWorkspaceView_stage_resizeHandler);
			PopUpManager.removePopUp(loadWorkspaceViewWrapper);
			loadWorkspaceViewWrapper = null;

			loadWorkspaceView.removeEventListener(Event.CLOSE, handleLoadWorkspacePopupClose);
			loadWorkspaceView = null;
		}
		
		private function handleLoadWorkspaceEvent(event:WorkspaceEvent):void
		{
			var requestedWorkspace:String = event.workspaceLabel;
			if (requestedWorkspace != currentWorkspaceLabel)
			{
				methodToCallAfterClosingAllProjects = 
					new MethodDescriptor(this, 'changeToWorkspace', requestedWorkspace);
				
				closeAllProjectItems = ObjectUtil.copy(currentWorkspacePaths) as Array;
				closeAllEditorAsync();
			}
		}

		protected function loadWorkspaceView_stage_resizeHandler(event:Event):void
		{
			PopUpManager.centerPopUp(loadWorkspaceViewWrapper);
		}
		//--------------------------------------------------------------------------
		//
		//  GENERAL API
		//
		//--------------------------------------------------------------------------
		
		private function restoreFromCookie():void
		{
			currentWorkspaceLabel = ("currentWorkspace" in cookie.data) ? cookie.data["currentWorkspace"] : LABEL_DEFAULT_WORKSPACE;

			workspacesForViews = new ArrayList();
			workspaces = new Object();
			if ("workspaces" in cookie.data)
			{
				workspaces = cookie.data["workspaces"];
			}
			else
			{
				workspaces[LABEL_DEFAULT_WORKSPACE] = [];
			}

			for (var workspace:String in workspaces)
			{
				workspacesForViews.addItem(new WorkspaceVO(workspace, workspaces[workspace]));
			}

			sortWorkspaces();

			currentWorkspacePaths = (workspaces[currentWorkspaceLabel] !== undefined) ?
				workspaces[currentWorkspaceLabel] : [];
		}
		
		private function getPathIndex(path:String):int
		{
			return currentWorkspacePaths.indexOf(path);
		}
		
		public function changeToWorkspace(label:String):void
		{
			currentWorkspaceLabel = label;
			currentWorkspacePaths = (workspaces[currentWorkspaceLabel] !== undefined) ?
					workspaces[currentWorkspaceLabel] : [];
			saveToCookie();
			
			// codes to re-open each projects
			// saved from the active workspace
			var tmpProjectLocation:FileLocation;
			for each (var path:String in currentWorkspacePaths)
			{
				tmpProjectLocation = new FileLocation(path);
				if (tmpProjectLocation.fileBridge.exists)
				{
					dispatcher.dispatchEvent(
						new ProjectEvent(
							ProjectEvent.EVENT_IMPORT_PROJECT_NO_BROWSE_DIALOG, 
							tmpProjectLocation.fileBridge.getFile,
							WorkspaceEvent.LOAD_PROJECT_BY_WORKSPACE
						)
					);
				}
			}

			dispatcher.dispatchEvent(new Event(EVENT_WORKSPACE_CHANGED));
			outputToConsole();
		}
		
		public function changeToNewWorkspace(label:String):void
		{
			currentWorkspacePaths = [];
			currentWorkspaceLabel = label;
			workspaces[currentWorkspaceLabel] = currentWorkspacePaths;
			workspacesForViews.addItem(new WorkspaceVO(currentWorkspaceLabel, workspaces[currentWorkspaceLabel]));
			sortWorkspaces();
			dispatcher.dispatchEvent(new Event(EVENT_WORKSPACE_CHANGED));
			saveToCookie();
			outputToConsole();
		}
		
		private function duplicateToNewWorkspace(label:String):void
		{
			currentWorkspacePaths = ObjectUtil.clone(currentWorkspacePaths) as Array;
			currentWorkspaceLabel = label;
			workspaces[currentWorkspaceLabel] = currentWorkspacePaths;
			workspacesForViews.addItem(new WorkspaceVO(currentWorkspaceLabel, workspaces[currentWorkspaceLabel]));
			sortWorkspaces();
			dispatcher.dispatchEvent(new Event(EVENT_WORKSPACE_CHANGED));
			saveToCookie();
			outputToConsole();
		}
		
		private function saveToCookie():void
		{
			workspaces[currentWorkspaceLabel] = currentWorkspacePaths;
			cookie.data["currentWorkspace"] = currentWorkspaceLabel;
			cookie.data["workspaces"] = workspaces;
			
			cookie.flush();

			preferences.workspace.current = currentWorkspaceLabel;
			preferences.workspace.workspaces = workspaces;
			preferences.flush();
		}
		
		private function outputToConsole():void
		{
			dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, "Workspace changed to: "+ currentWorkspaceLabel, false, false, ConsoleOutputEvent.TYPE_NOTE));
		}
		
		//--------------------------------------------------------------------------
		//
		//  CLOSING ALL PROJECTS ONE AT A TIME
		//
		//--------------------------------------------------------------------------
		
		private function closeAllEditorAsync():void
		{
			if (closeAllProjectItems.length != 0)
			{
				var projectPath:String = closeAllProjectItems[0];
				var project:ProjectVO = UtilsCore.getProjectByPath(projectPath);
				if (project) dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.CLOSE_PROJECT, project.projectFolder));
				else handleRemoveProjectByPath(projectPath);
			}
			else
			{
				var tmpTimeout:uint = setTimeout(function():void
				{
					clearTimeout(tmpTimeout);
					
					methodToCallAfterClosingAllProjects.callMethod();
					methodToCallAfterClosingAllProjects = null;
					closeAllProjectItems = null;
				}, 1000);
			}
		}

		private function sortWorkspaces():void
		{
			workspacesForViews.source.sortOn(["label"], Array.CASEINSENSITIVE);
		}
	}
}