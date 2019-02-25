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
    import actionScripts.factory.FileLocation;

    import flash.display.DisplayObject;
	import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.utils.clearTimeout;
    import flash.utils.setTimeout;
	
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	import actionScripts.controllers.DataAgent;
	import actionScripts.events.RefreshTreeEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
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
			if (!pvo) return;
			
			if (!ConstantsCoreVO.IS_AIR && !loader)
			{
				print("Clean project: "+ pvo.name +". Invoking compiler on remote server...");
			}
			else if (ConstantsCoreVO.IS_AIR)
			{
				if (!(pvo is AS3ProjectVO)) return;
				
				var as3Provo:AS3ProjectVO = pvo as AS3ProjectVO; 
				var outputFile:FileLocation;
				var swfPath:FileLocation;

				if (as3Provo.swfOutput.path)
				{
					outputFile = as3Provo.swfOutput.path;
					swfPath = outputFile.fileBridge.parent;
				}

				var folderSwfCount:int = 0;
                var onSWFFolderCompleteHandler:Function = function(event:Event):void
                {
                    event.target.removeEventListener(Event.COMPLETE, onSWFFolderCompleteHandler);
                    folderSwfCount--;
                    if (folderSwfCount == 0)
                    {
                        dispatcher.dispatchEvent(new RefreshTreeEvent(swfPath, true));
                        success("SWF project files cleaned successfully : " + pvo.name);
                    }
                }

				if (swfPath.fileBridge.exists) 
				{
					var directoryItems:Array = swfPath.fileBridge.getDirectoryListing();
					for each (var directory:Object in directoryItems)
					{
                        folderSwfCount++;
                        directory.addEventListener(IOErrorEvent.IO_ERROR, onCleanProjectIOException);
                        directory.addEventListener(Event.COMPLETE, onSWFFolderCompleteHandler);

						if (directory.isDirectory)
						{
							directory.deleteDirectoryAsync(true);
                        }
						else
						{
							directory.deleteFileAsync();
                        }
					}

                    if (folderSwfCount == 0)
                    {
                        dispatcher.dispatchEvent(new RefreshTreeEvent(swfPath, true));
                        success("SWF project files cleaned successfully : " + pvo.name);
                    }
				}
				
				if (as3Provo.isFlexJS || as3Provo.isRoyale)
				{
					var binFolder:FileLocation = as3Provo.folderLocation.resolvePath(as3Provo.jsOutputPath).resolvePath("bin");
					if (!binFolder.fileBridge.exists)
					{
						binFolder = as3Provo.folderLocation.fileBridge.resolvePath("bin");
					}

					if (binFolder.fileBridge.exists)
					{
						var timeoutValue:uint = setTimeout(function():void
						{
                            var folderCount:int = 0;
                            var jsDebugFolder:FileLocation = binFolder.resolvePath("js-debug");
							var jsDebugFolderExists:Boolean = jsDebugFolder.fileBridge.exists;
							if (jsDebugFolderExists) folderCount++;

                            var jsReleaseFolder:FileLocation = binFolder.resolvePath("js-release");
                            var jsReleaseFolderExists:Boolean = jsReleaseFolder.fileBridge.exists;
                            if (jsReleaseFolderExists) folderCount++;

							var onJSFolderCompleteHandler:Function = null;

                            if (folderCount > 0)
                            {
                                onJSFolderCompleteHandler = function(event:Event):void
                                {
									event.target.removeEventListener(Event.COMPLETE, onJSFolderCompleteHandler);
                                    folderCount--;
                                    if (folderCount == 0)
                                    {
                                        dispatcher.dispatchEvent(new RefreshTreeEvent(binFolder, true));
                                        success("JavaScript project files cleaned successfully : " + pvo.name);
                                    }
                                }
                            }

							if (jsDebugFolderExists)
							{
                                jsDebugFolder.fileBridge.getFile.addEventListener(IOErrorEvent.IO_ERROR, onCleanProjectIOException);
                                jsDebugFolder.fileBridge.getFile.addEventListener(Event.COMPLETE, onJSFolderCompleteHandler);
                                jsDebugFolder.fileBridge.deleteDirectoryAsync(true);
                            }

							if (jsReleaseFolderExists)
							{
                                jsDebugFolder.fileBridge.getFile.addEventListener(IOErrorEvent.IO_ERROR, onCleanProjectIOException);
                                jsReleaseFolder.fileBridge.getFile.addEventListener(Event.COMPLETE, onJSFolderCompleteHandler);
                                jsReleaseFolder.fileBridge.deleteDirectoryAsync(true);
                            }

							if (folderCount == 0)
							{
                                dispatcher.dispatchEvent(new RefreshTreeEvent(binFolder, true));
                    			success("JavaScript project files cleaned successfully : " + pvo.name);
							}

							clearTimeout(timeoutValue);
						}, 300);
					}
					else if ((!swfPath || !swfPath.fileBridge.exists) && !binFolder.fileBridge.exists)
					{
                        success("Project files cleaned successfully : " + pvo.name);
					}
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