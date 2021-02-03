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
package actionScripts.plugin.workspace
{
	import actionScripts.ui.FeathersUIWrapper;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.net.SharedObject;

	import moonshine.plugin.workspace.events.WorkspaceEvent;
	import moonshine.plugin.workspace.view.NewWorkspaceView;

	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	import mx.utils.ObjectUtil;

	import actionScripts.events.ProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.utils.MethodDescriptor;
	import actionScripts.utils.SharedObjectConst;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;
	import feathers.data.ArrayCollection;

	import moonshine.plugin.workspace.view.LoadWorkspaceView;

	public class WorkspacePlugin extends PluginBase
	{
		public static const EVENT_SAVE_AS:String = "saveAsNewWorkspaceEvent";
		public static const EVENT_NEW:String = "newWorkspaceEvent";
		public static const EVENT_LOAD:String = "loadWorkspaceEvent";
		
		private static const LABEL_DEFAULT_WORKSPACE:String = "IDE-Default";
		
		override public function get name():String 			{return "Workspace";}
		override public function get author():String 		{return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team";}
		override public function get description():String 	{return "Workspace manangement for the Moonshine projects.";}
		
		private var cookie:SharedObject;
		private var currentWorkspaceItems:Array;
		private var workspaces:Object; // Dictionary<String, [String]>
		private var methodToCallAfterClosingAllProjects:MethodDescriptor;
		private var closeAllProjectItems:Array;
		
		private var loadWorkspaceView:LoadWorkspaceView;
		private var loadWorkspaceViewWrapper:FeathersUIWrapper;

		private var newWorkspaceView:NewWorkspaceView;
		private var newWorkspaceViewWrapper:FeathersUIWrapper;

		private var _currentWorkspaceLabel:String;
		private function get currentWorkspaceLabel():String
		{
			return _currentWorkspaceLabel;
		}
		private function set currentWorkspaceLabel(value:String):void
		{
			ConstantsCoreVO.CURRENT_WORKSPACE =	_currentWorkspaceLabel = value;
		}
		
		private function get workspaceLabels():Array
		{
			var tmpArray:Array = [];
			for (var label:String in workspaces)
			{
				tmpArray.push(label);
			}
			
			tmpArray.sort(Array.CASEINSENSITIVE);
			return tmpArray;
		}
		
		public function WorkspacePlugin()
		{
			super();
		}
		
		override public function activate():void
		{
			cookie = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_WORKSPACE);
			restoreFromCookie();
			
			dispatcher.addEventListener(EVENT_SAVE_AS, onSaveAsNewWorkspaceEvent, false, 0, true);
			dispatcher.addEventListener(EVENT_NEW, onNewWorkspaceEvent, false, 0, true);
			dispatcher.addEventListener(EVENT_LOAD, onLoadWorkspaceEvent, false, 0, true);
			
			dispatcher.addEventListener(ProjectEvent.ADD_PROJECT, handleAddProject);
			dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, handleRemoveProject);
		}
		
		private function handleAddProject(event:ProjectEvent):void
		{
			if (getPathIndex(event.project.folderLocation.fileBridge.nativePath) == -1)
			{
				currentWorkspaceItems.push(event.project.folderLocation.fileBridge.nativePath);
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
					currentWorkspaceItems.splice(pathIndex, 1);
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
			newWorkspaceView.addEventListener(WorkspaceEvent.NEW_WORKSPACE_WITH_LABEL, handleSaveAsWorkspaceEvent);
		}

		private function onNewWorkspaceEvent(event:Event):void
		{
			var newWorkspaceView:NewWorkspaceView = createNewWorkspaceViewWithTitle("New Workspace");
			newWorkspaceView.addEventListener(WorkspaceEvent.NEW_WORKSPACE_WITH_LABEL, handleNewWorkspaceEvent);
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
			newWorkspaceView.removeEventListener(WorkspaceEvent.NEW_WORKSPACE_WITH_LABEL, handleNewWorkspaceEvent);
			newWorkspaceView.removeEventListener(WorkspaceEvent.NEW_WORKSPACE_WITH_LABEL, handleSaveAsWorkspaceEvent);

			newWorkspaceView = null;
		}
		
		private function handleNewWorkspaceEvent(event:WorkspaceEvent):void
		{
			methodToCallAfterClosingAllProjects = 
				new MethodDescriptor(this, 'changeToNewWorkspace', event.workspaceLabel);
			
			closeAllProjectItems = ObjectUtil.copy(currentWorkspaceItems) as Array;
			closeAllEditorAsync();
		}

		private function createNewWorkspaceViewWithTitle(title:String):NewWorkspaceView
		{
			newWorkspaceView = new NewWorkspaceView();
			newWorkspaceViewWrapper = new FeathersUIWrapper(newWorkspaceView);
			PopUpManager.addPopUp(newWorkspaceViewWrapper, FlexGlobals.topLevelApplication as DisplayObject, false);

			newWorkspaceView.workspaces = new ArrayCollection(workspaceLabels);
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
			PopUpManager.addPopUp(loadWorkspaceViewWrapper, FlexGlobals.topLevelApplication as DisplayObject, false);

			loadWorkspaceView.workspaces = new ArrayCollection(workspaceLabels);
			loadWorkspaceView.selectedWorkspace = currentWorkspaceLabel;
			loadWorkspaceView.addEventListener(Event.CLOSE, handleLoadWorkspacePopupClose);
			loadWorkspaceView.addEventListener(WorkspaceEvent.NEW_WORKSPACE_WITH_LABEL, handleLoadWorkspaceEvent);

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
			loadWorkspaceView.removeEventListener(WorkspaceEvent.NEW_WORKSPACE_WITH_LABEL, handleLoadWorkspaceEvent);
			loadWorkspaceView = null;
		}
		
		private function handleLoadWorkspaceEvent(event:WorkspaceEvent):void
		{
			var requestedWorkspace:String = event.workspaceLabel;
			if (requestedWorkspace != currentWorkspaceLabel)
			{
				methodToCallAfterClosingAllProjects = 
					new MethodDescriptor(this, 'changeToWorkspace', requestedWorkspace);
				
				closeAllProjectItems = ObjectUtil.copy(currentWorkspaceItems) as Array;
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
			
			workspaces = new Object();
			if ("workspaces" in cookie.data)
			{
				workspaces = cookie.data["workspaces"];
			}
			else
			{
				workspaces[LABEL_DEFAULT_WORKSPACE] = [];
			}
			
			currentWorkspaceItems = (workspaces[currentWorkspaceLabel] !== undefined) ? 
				workspaces[currentWorkspaceLabel] : [];
		}
		
		private function getPathIndex(path:String):int
		{
			return currentWorkspaceItems.indexOf(path);
		}
		
		public function changeToWorkspace(label:String):void
		{
			currentWorkspaceLabel = label;
			currentWorkspaceItems = workspaces[currentWorkspaceLabel];
			saveToCookie();
			
			// codes to re-open each projects
			// saved from the active workspace
			var tmpProjectLocation:FileLocation;
			for each (var path:String in currentWorkspaceItems)
			{
				tmpProjectLocation = new FileLocation(path);
				if (tmpProjectLocation.fileBridge.exists)
				{
					dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.EVENT_IMPORT_PROJECT_NO_BROWSE_DIALOG, tmpProjectLocation.fileBridge.getFile));
				}
			}
			
			outputToConsole();
		}
		
		public function changeToNewWorkspace(label:String):void
		{
			currentWorkspaceItems = [];
			currentWorkspaceLabel = label;
			workspaces[currentWorkspaceLabel] = currentWorkspaceItems;
			saveToCookie();
			outputToConsole();
		}
		
		private function duplicateToNewWorkspace(label:String):void
		{
			currentWorkspaceItems = ObjectUtil.clone(currentWorkspaceItems) as Array;
			currentWorkspaceLabel = label;
			workspaces[currentWorkspaceLabel] = currentWorkspaceItems;
			saveToCookie();
			outputToConsole();
		}
		
		private function saveToCookie():void
		{
			workspaces[currentWorkspaceLabel] = currentWorkspaceItems;
			cookie.data["currentWorkspace"] = currentWorkspaceLabel;
			cookie.data["workspaces"] = workspaces;
			
			cookie.flush();
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
				methodToCallAfterClosingAllProjects.callMethod();
				methodToCallAfterClosingAllProjects = null;
				closeAllProjectItems = null;
			}
		}
	}
}