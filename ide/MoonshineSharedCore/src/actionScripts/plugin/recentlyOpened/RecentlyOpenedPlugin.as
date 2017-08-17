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
package actionScripts.plugin.recentlyOpened
{
	import flash.events.Event;
	import flash.net.SharedObject;
	import flash.utils.setTimeout;
	
	import actionScripts.events.FilePluginEvent;
	import actionScripts.events.GeneralEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.ui.LayoutModifier;
	import actionScripts.utils.OSXBookmarkerNotifiers;
	import actionScripts.utils.ObjectTranslator;
	import actionScripts.utils.SDKUtils;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectReferenceVO;
	
	import components.views.project.TreeView;

	public class RecentlyOpenedPlugin extends PluginBase
	{
		public static const RECENT_PROJECT_LIST_UPDATED:String = "RECENT_PROJECT_LIST_UPDATED";
		public static const RECENT_FILES_LIST_UPDATED:String = "RECENT_FILES_LIST_UPDATED";
		
		override public function get name():String			{ return "Recently Opened Plugin"; }
		override public function get author():String		{ return "Moonshine Project Team"; }
		override public function get description():String	{ return "Stores the last opened file paths."; }
		
		private var cookie:SharedObject;
		
		override public function activate():void
		{
			super.activate();
			
			cookie = SharedObject.getLocal("moonshine-ide-local");

			if (model.recentlyOpenedFiles.length == 0)
			{
				restoreFromCookie();
			}
			
			dispatcher.addEventListener(ProjectEvent.ADD_PROJECT, handleAddProject);
			dispatcher.addEventListener(ProjectEvent.FLEX_SDK_UDPATED, onFlexSDKUpdated);
			dispatcher.addEventListener(ProjectEvent.WORKSPACE_UPDATED, onWorkspaceUpdated);
			dispatcher.addEventListener(SDKUtils.EVENT_SDK_PROMPT_DNS, onSDKExtractDNSUpdated);
			dispatcher.addEventListener(FilePluginEvent.EVENT_JAVA_TYPEAHEAD_PATH_SAVE, onJavaPathForTypeaheadSave);
			dispatcher.addEventListener(LayoutModifier.SAVE_LAYOUT_CHANGE_EVENT, onSaveLayoutChangeEvent);
			// Give other plugins a chance to cancel the event
			dispatcher.addEventListener(FilePluginEvent.EVENT_FILE_OPEN, handleOpenFile, false, -100);
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
			var tmpNewRefVO: ProjectReferenceVO;
			if (cookie.data.hasOwnProperty('recentFiles'))
			{
				if (!ConstantsCoreVO.IS_AIR)
				{
					model.recentlyOpenedProjectOpenedOption.source = cookie.data.recentProjectsOpenedOption;
				}
				else
				{
					recentFiles = cookie.data.recentFiles;
					for each (file in recentFiles)
					{
						tmpNewRefVO = ProjectReferenceVO.getNewRemoteProjectReferenceVO(file);
						if (tmpNewRefVO.path && tmpNewRefVO.path != "")
						{
							f = new FileLocation(tmpNewRefVO.path);
							if (f.fileBridge.exists) recent.push(tmpNewRefVO);
						}
					}
					model.recentlyOpenedFiles.source = recent;
				}
			}
			
			if (cookie.data.hasOwnProperty('recentProjects'))
			{
				recentFiles = cookie.data.recentProjects;
				recent = [];
				for each (file in recentFiles)
				{
					tmpNewRefVO = ProjectReferenceVO.getNewRemoteProjectReferenceVO(file);
					if (tmpNewRefVO.path && tmpNewRefVO.path != "")
					{
						f = new FileLocation(tmpNewRefVO.path);
						if (ConstantsCoreVO.IS_AIR && f.fileBridge.exists) recent.push(tmpNewRefVO);
						else if (!ConstantsCoreVO.IS_AIR) recent.push(tmpNewRefVO);
					}
				}
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
					model.userSavedSDKs.addItem(ObjectTranslator.objectToInstance(object, ProjectReferenceVO));
				}
			}
			
			if (cookie.data.hasOwnProperty('moonshineWorkspace')) OSXBookmarkerNotifiers.workspaceLocation = new FileLocation(cookie.data.moonshineWorkspace);
			if (cookie.data.hasOwnProperty('isWorkspaceAcknowledged')) OSXBookmarkerNotifiers.isWorkspaceAcknowledged = (cookie.data["isWorkspaceAcknowledged"] == "true") ? true : false;
			if (cookie.data.hasOwnProperty('isBundledSDKpromptDNS')) ConstantsCoreVO.IS_BUNDLED_SDK_PROMPT_DNS = (cookie.data["isBundledSDKpromptDNS"] == "true") ? true : false;
			if (cookie.data.hasOwnProperty('isSDKhelperPromptDNS')) ConstantsCoreVO.IS_SDK_HELPER_PROMPT_DNS = (cookie.data["isSDKhelperPromptDNS"] == "true") ? true : false;
			if (cookie.data.hasOwnProperty('javaPathForTypeahead')) model.javaPathForTypeAhead = new FileLocation(cookie.data["javaPathForTypeahead"]);
			
			LayoutModifier.parseCookie(cookie);
			
			// initiate bundled SDK if exists
			/*setTimeout(function():void
			{
				SDKUtils.openSDKUnzipPrompt();
			}, 2000);*/
		}
		
		private function handleAddProject(event:ProjectEvent):void
		{
			// Find & remove project if already present
			//var f:File = (event.project.projectFile) ? event.project.projectFile : event.project.folder;
			var f:FileLocation = event.project.folderLocation;
			var toRemove:int = -1;
			for each (var file:Object in model.recentlyOpenedProjects)
			{
				if (file.path == f.fileBridge.nativePath)
				{
					toRemove = model.recentlyOpenedProjects.getItemIndex(file);
					break;
				}
			}
			if (toRemove != -1) 
			{
				model.recentlyOpenedProjects.removeItemAt(toRemove);
				model.recentlyOpenedProjectOpenedOption.removeItemAt(toRemove);
			}
			
			var customSDKPath:String = (event.project as AS3ProjectVO).buildOptions.customSDKPath;
			var tmpSOReference: ProjectReferenceVO = new ProjectReferenceVO();
			tmpSOReference.name = event.project.name;
			tmpSOReference.sdk = customSDKPath ? customSDKPath : (model.defaultSDK ? model.defaultSDK.fileBridge.nativePath : null);
			tmpSOReference.path = event.project.folderLocation.fileBridge.nativePath;
			model.recentlyOpenedProjects.addItemAt(tmpSOReference, 0);
			model.recentlyOpenedProjectOpenedOption.addItemAt({path:f.fileBridge.nativePath, option:(event.extras ? event.extras[0] : "")}, 0);
			
			//Moon-166 fix: This will set selected project in the tree view
			/*var tmpTreeView:TreeView = model.mainView.getTreeViewPanel();
			tmpTreeView.tree.selectedItem = model.activeProject.projectFolder;*/
			
			setTimeout(function():void{var tmpTreeView:TreeView = model.mainView.getTreeViewPanel();
				tmpTreeView.tree.selectedItem = model.activeProject.projectFolder;}, 200);
			
			save(model.recentlyOpenedProjects.source, 'recentProjects');
			save(model.recentlyOpenedProjectOpenedOption.source, 'recentProjectsOpenedOption');
			
			setTimeout(function():void
			{
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
			tmpSOReference.name = (f.fileBridge.name.indexOf(".") == -1) ? f.fileBridge.name +"."+ f.fileBridge.extension : f.fileBridge.name;
			tmpSOReference.path = f.fileBridge.nativePath;
			model.recentlyOpenedFiles.addItemAt(tmpSOReference, 0);
			//model.selectedprojectFolders
			
			// Persist to disk
			save(model.recentlyOpenedFiles.source, 'recentFiles');
			
			setTimeout(function():void
			{
				dispatcher.dispatchEvent(new Event(RECENT_FILES_LIST_UPDATED));
			}, 300);
		}
		
		private function onFlexSDKUpdated(event:ProjectEvent):void
		{
			// we need some works here, we don't 
			// wants any bundled SDKs to be saved in 
			// the saved list
			var tmpArr:Array = [];
			for each (var i:ProjectReferenceVO in model.userSavedSDKs)
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
		
		private function onJavaPathForTypeaheadSave(event:FilePluginEvent):void
		{
			cookie.data["javaPathForTypeahead"] = event.file.fileBridge.nativePath;
			cookie.flush();
		}
		
		private function onSaveLayoutChangeEvent(event:GeneralEvent):void
		{
			cookie.data[event.value.label] = event.value.value;
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
				if (f is FileLocation) toSave.push(f.fileBridge.nativePath);
				else toSave.push(f);
			}
			
			// Add to LocalObject
			cookie.data[key] = toSave;
			cookie.flush();
		}
	}
}