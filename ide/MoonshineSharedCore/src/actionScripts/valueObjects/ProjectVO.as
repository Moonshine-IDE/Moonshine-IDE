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
package actionScripts.valueObjects
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	import actionScripts.controllers.DataAgent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	
	public class ProjectVO extends EventDispatcher
	{
		public static const PROJECTS_DATA_UPDATED: String = "PROJECTS_DATA_UPDATED";
		public static const PROJECTS_DATA_FAULT: String = "PROJECTS_DATA_FAULT";
		
		[Bindable] public var folderNamesOnly:Vector.<String> = new Vector.<String>();
		
		public var folderLocation: FileLocation;
		public var projectFile: FileLocation;
		public var projectRemotePath:String;
		public var projectName:String;
		public var fileNamesOnly:Vector.<String>;
		public var classFilesInProject: ArrayCollection;
		
		private var _projectFolder: FileWrapper;
		
		private var loader: DataAgent;
		private var projectConfigurationFile: FileWrapper;
		private var projectReference: ProjectReferenceVO;
		private var shallUpdateToTreeView:Boolean;
		private var isFlashDevelopProject:Boolean;
		private var isFlashBuilderProject:Boolean;
		private var rootFound:Boolean;
		
		public function ProjectVO(folder:FileLocation, projectName:String=null, updateToTreeView:Boolean=true)
		{
			//if (ConstantsCoreVO.IS_AIR && !folderLocation) folder = folder.getDirectoryListing();
			classFilesInProject = new ArrayCollection();
			folderLocation = folder;
			
			// we need to keep a reference of owner project to every
			// filewrapper reference for later use, i.e. to determine
			// a filewrapper belongs to which project
			projectReference = new ProjectReferenceVO();
			projectReference.name = projectName;
			projectReference.path = folder.fileBridge.nativePath;
			
			folderLocation.fileBridge.name = this.projectName = projectName;
			shallUpdateToTreeView = updateToTreeView;
			
			// download the directory structure from remote
			// for the project if a Web run
			if (!ConstantsCoreVO.IS_AIR && !_projectFolder)
			{
				loader = new DataAgent(folder.fileBridge.nativePath, onProjectDataLoaded, onFault);
			}
		}
		
		[Bindable] public function get projectFolder():FileWrapper
		{
			if (ConstantsCoreVO.IS_AIR && (!_projectFolder || _projectFolder.file.fileBridge.nativePath != folderLocation.fileBridge.nativePath)) _projectFolder = new FileWrapper(folderLocation, true, projectReference, shallUpdateToTreeView);
			return _projectFolder;
		}
		public function set projectFolder(value:FileWrapper):void
		{
			_projectFolder = value;
		}
		
		public function get name():String 
		{
			return folderLocation.fileBridge.name;
		}
		
		public function get folderPath():String 
		{
			return folderLocation.fileBridge.nativePath;
		}
		public function set folderPath(v:String):void 
		{
			folderLocation.fileBridge.nativePath = v;
		}
		
		public function saveSettings():void	
		{
			throw new Error("saveSettings() not implemented yet");
		}
		
		public function getSettings():Vector.<SettingsWrapper>
		{
			return Vector.<SettingsWrapper>([]);
		}
		
		//--------------------------------------------------------------------------
		//
		//  WEB API
		//
		//--------------------------------------------------------------------------
		
		public function getFileByName(wrapper:FileWrapper, value:String):void
		{
			if ((wrapper.children is Array) && (wrapper.children as Array).length > 0) 
			{
				var tmpSubChildren:Array = [];
				for each (var c:FileWrapper in wrapper.children)
				{
					if (c.file.fileBridge.name == value) 
					{
						projectConfigurationFile = c;
						return;
					}
					getFileByName(c, value);
				}
			}
		}
		
		private function onProjectDataLoaded(value:Object, message:String=null):void
		{
			// probable termination
			if (!value) return;
			
			fileNamesOnly = new Vector.<String>();
			
			var jsonString: String = String(value);
			var jsonObj:Object;
			try
			{
				jsonObj = JSON.parse(jsonString);
			}
			catch(e:Error)
			{
				if (jsonString) Alert.show(jsonString, "Error!");
				return;
			}
			
			// before moving any further let's check
			// if the project has created by FlashDevelop or FlashBuilder
			// @note
			// if both file types are persent in directory
			// we'll go to load FlashDevelop configuration
			if (jsonString.indexOf(".as3proj") != -1)
			{
				isFlashDevelopProject = true;
			}
			else if (jsonString.indexOf(".actionScriptProperties") != -1)
			{
				isFlashBuilderProject = true;	
			}
			
			folderLocation.fileBridge.name = projectName;
			folderLocation.fileBridge.isDirectory = true;
			_projectFolder = parseChildrens(jsonObj);
			loader = null;
			
			if (shallUpdateToTreeView) GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.TREE_DATA_UPDATES, this));
			else dispatchEvent(new Event(PROJECTS_DATA_UPDATED));
			loader = null;
			
			// continue loading project configuration
			var tmpConfigName:String;
			if (isFlashDevelopProject) tmpConfigName = projectName+".as3proj";
			else if (isFlashBuilderProject) tmpConfigName = ".actionScriptProperties";
			else return;
			getFileByName(projectFolder, tmpConfigName);
			setTimeout(loadConfiguration, 1000);
		}
		
		private function loadConfiguration():void
		{
			if (!projectConfigurationFile) return;
			
			var successFunction:Function;
			successFunction = (isFlashDevelopProject) ? onFDProjectLoaded : onFBProjectLoaded;
			loader = new DataAgent(URLDescriptorVO.FILE_OPEN, successFunction, onFault, {path:projectConfigurationFile.file.fileBridge.nativePath});
		}
		
		private function onFDProjectLoaded(value:Object, message:String=null):void
		{
			var rawData:String = String(value);
			var jsonObj:Object = JSON.parse(rawData);
			
			ConstantsCoreVO.AS3PROJ_CONFIG_SOURCE = XML(jsonObj.text);
			IDEModel.getInstance().flexCore.parseFlashDevelop(IDEModel.getInstance().activeProject as AS3ProjectVO);
		}
		
		private function onFBProjectLoaded(value:Object, message:String=null):void
		{
			trace(value);
		}
		
		private function onFault(message:String):void
		{
			loader = null;
			dispatchEvent(new Event(PROJECTS_DATA_FAULT));
		}
		
		private function parseChildrens(value:Object):FileWrapper
		{
			if (!value) return null;
			if (value.error)
			{
				Alert.show(value.error, "Error!");
				return null;
			}
			
			var tmpLocation: FileLocation = new FileLocation(value.nativePath);
			tmpLocation.fileBridge.isDirectory = (value.isDirectory.toString() == "true") ? true : false;
			tmpLocation.fileBridge.isHidden = (value.isHidden.toString() == "true") ? true : false;
			tmpLocation.fileBridge.name = (!rootFound) ? folderLocation.fileBridge.name : String(value.name);
			tmpLocation.fileBridge.extension = String(value.extension);
			tmpLocation.fileBridge.exists = true;
			
			if (!tmpLocation.fileBridge.isDirectory) fileNamesOnly.push(tmpLocation.fileBridge.nativePath);
			
			var tmpFW: FileWrapper = new FileWrapper(tmpLocation, !rootFound, projectReference);
			rootFound = true;
			if ((value.children is Array) && (value.children as Array).length > 0) 
			{
				var tmpSubChildren:Array = [];
				for each (var c:Object in value.children)
				{
					tmpSubChildren.push(parseChildrens(c));
				}
				
				tmpFW.children = tmpSubChildren;
			}
			
			if (tmpFW.children.length == 0 && !tmpFW.file.fileBridge.isDirectory) tmpFW.children = null;
			return tmpFW;
		}
	}
}