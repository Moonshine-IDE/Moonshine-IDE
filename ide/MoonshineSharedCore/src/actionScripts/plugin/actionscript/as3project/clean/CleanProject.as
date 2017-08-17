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
package actionScripts.plugin.actionscript.as3project.clean
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	import actionScripts.controllers.DataAgent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.RefreshTreeEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.plugin.core.compiler.CompilerEventBase;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;
	
	import components.popup.SelectOpenedFlexProject;
	import components.views.project.TreeView;

	public class CleanProject extends PluginBase implements IPlugin
	{
		private var loader: DataAgent;
		private var selectProjectPopup:SelectOpenedFlexProject;
		
		override public function get name():String { return "Clean Project"; }
		override public function get author():String { return "Moonshine Project Team"; }
		override public function get description():String { return "Clean swf file from output dir."; }
		
		public function CleanProject()
		{
			super();
		}
		
		override public function activate():void 
		{
			super.activate();
			dispatcher.addEventListener(CompilerEventBase.CLEAN_PROJECT, cleanSelectedProject);
		}
		
		override public function deactivate():void 
		{
			super.deactivate();
			dispatcher.removeEventListener(CompilerEventBase.CLEAN_PROJECT, cleanSelectedProject);
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
					var projectReference:AS3ProjectVO = tmpTreeView.getProjectBySelection();
					if (projectReference)
					{
						cleanActiveProject(projectReference as ProjectVO);
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
		private function cleanActiveProject(pvo:ProjectVO):void
		{
			//var pvo:ProjectVO = IDEModel.getInstance().activeProject;
			// Don't compile if there is no project. Don't warn since other compilers might take the job.
			if (!pvo) return  
			
			if (!ConstantsCoreVO.IS_AIR && !loader)
			{
				GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleOutputEvent("Clean project: "+ pvo.name +". Invoking compiler on remote server..."));
				//	loader = new DataAgent(URLDescriptorVO.PROJECT_COMPILE, onBuildCompleted, onFault);
			}
			else if (ConstantsCoreVO.IS_AIR)
			{
				if (!(pvo is actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO)) return;
				
				var as3Provo:AS3ProjectVO = pvo as AS3ProjectVO; 
				var outputFile:FileLocation;
				var swfPath:FileLocation;
				
				if (as3Provo.swfOutput.path)
				{
					outputFile = as3Provo.swfOutput.path;
					swfPath = outputFile.fileBridge.parent;
				}
				
				if (swfPath.fileBridge.exists) 
				{
					var directoryItems:Array = swfPath.fileBridge.getDirectoryListing();
					for each (var i:Object in directoryItems)
					{
						if (i.isDirectory) i.deleteDirectory(true);
						else i.deleteFile();
					}
					
					dispatcher.dispatchEvent(new RefreshTreeEvent(swfPath));
				}
				
				if (as3Provo.FlexJS)
				{
					var binFolder:FileLocation = as3Provo.folderLocation.fileBridge.resolvePath("bin");
					if (binFolder.fileBridge.exists)
					{
						setTimeout(function():void
						{
							var deletableFolder:FileLocation = binFolder.resolvePath("js-debug");
							if (deletableFolder.fileBridge.exists) deletableFolder.fileBridge.deleteDirectory(true);
							deletableFolder = binFolder.resolvePath("js-release");
							if (deletableFolder.fileBridge.exists) deletableFolder.fileBridge.deleteDirectory(true);
							dispatcher.dispatchEvent(new RefreshTreeEvent(binFolder));
						}, 300);
					}
				}
				
				GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleOutputEvent("Project cleaned successfully : "+ pvo.name ));
			}				
		}
	}
}