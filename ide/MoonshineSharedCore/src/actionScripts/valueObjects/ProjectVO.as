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
package actionScripts.valueObjects
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.clearTimeout;
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
	import actionScripts.plugin.actionscript.as3project.importer.FlashDevelopImporter;
	
	public class ProjectVO extends EventDispatcher
	{
		public static const PROJECTS_DATA_UPDATED: String = "PROJECTS_DATA_UPDATED";
		public static const PROJECTS_DATA_FAULT: String = "PROJECTS_DATA_FAULT";
		
		[Bindable] public var folderNamesOnly:Vector.<String> = new Vector.<String>();
		
		private var _folderLocation: FileLocation;
		public function get folderLocation():FileLocation
		{
			return _folderLocation;
		}
		public function set folderLocation(value:FileLocation):void
		{
			_folderLocation = value;
		}
		
		private var _sourceFolder:FileLocation;
		public function get sourceFolder():FileLocation
		{
			return _sourceFolder;
		}
		public function set sourceFolder(value:FileLocation):void
		{
			projectReference.sourceFolder = _sourceFolder = value;
			projectFolder.updateChildren(); // this will help rendered the 's' icon in already opened tree
		}

		public function get customSDKs():EnvironmentUtilsCusomSDKsVO
		{
			return null;
		}

		public var projectFile: FileLocation;
		public var projectRemotePath:String;
		public var projectName:String;
		public var fileNamesOnly:Vector.<String>;
		public var classFilesInProject: ArrayCollection;
		public var hasVersionControlType:String; // of VersionControlTypes
		public var menuType:String = "";
		public var projectWithExistingSourcePaths:Vector.<FileLocation>;
		public var isTrustServerCertificateSVN:Boolean;

		private var _projectFolder: FileWrapper;
		
		private var loader: DataAgent;
		private var projectConfigurationFile: FileWrapper;
		private var shallUpdateToTreeView:Boolean;
		private var isFlashDevelopProject:Boolean;
		private var isFlashBuilderProject:Boolean;
		private var rootFound:Boolean;

		private var timeoutProjectConfigValue:uint;
		
        protected var projectReference: ProjectReferenceVO;

		protected var model:IDEModel = IDEModel.getInstance();

		public function ProjectVO(folder:FileLocation, projectName:String=null, updateToTreeView:Boolean=true)
		{
			classFilesInProject = new ArrayCollection();

			folderLocation = folder;
			projectFolder = null;
			
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
		
		[Bindable(event="projectFolderChanged")]
		public function get projectFolder():FileWrapper
		{
			if (ConstantsCoreVO.IS_AIR && (!_projectFolder ||
				_projectFolder.file.fileBridge.nativePath != folderLocation.fileBridge.nativePath))
			{
				_projectFolder = new FileWrapper(folderLocation, true, projectReference, shallUpdateToTreeView);
			}

			return _projectFolder;
		}

		public function set projectFolder(value:FileWrapper):void
		{
			if (_projectFolder != value)
			{
				_projectFolder = value;
				dispatchEvent(new Event("projectFolderChanged"));
			}
		}
		
		public function get name():String 
		{
			return folderLocation.fileBridge.name;
		}
		
		public function get folderPath():String 
		{
			return folderLocation.fileBridge.nativePath;
		}
		public function set folderPath(value:String):void
		{
			folderLocation.fileBridge.nativePath = value;
		}
		
		public function projectFileDelete(fw:FileWrapper):void
		{
		}
		
		public function saveSettings():void	
		{
			throw new Error("saveSettings() not implemented yet");
		}
		
		public function cancelledSettings():void
		{
		}
		
		public function closedSettings():void
		{
		}
		
		public function getSettings():Vector.<SettingsWrapper>
		{
			return Vector.<SettingsWrapper>([]);
		}

		public function getProjectFilesToDelete():Array
		{
			return null;
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
			
			if (shallUpdateToTreeView)
			{
				GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.TREE_DATA_UPDATES, this));
            }
			else
			{
				dispatchEvent(new Event(PROJECTS_DATA_UPDATED));
            }
			loader = null;
			
			// continue loading project configuration
			var tmpConfigName:String;
			if (isFlashDevelopProject) tmpConfigName = projectName+".as3proj";
			else if (isFlashBuilderProject) tmpConfigName = ".actionScriptProperties";
			else return;
			getFileByName(projectFolder, tmpConfigName);
            timeoutProjectConfigValue = setTimeout(loadConfiguration, 1000);
		}
		
		private function loadConfiguration():void
		{
			if (!projectConfigurationFile) return;
			
			var successFunction:Function;
			successFunction = (isFlashDevelopProject) ? onFDProjectLoaded : onFBProjectLoaded;
			loader = new DataAgent(URLDescriptorVO.FILE_OPEN, successFunction, onFault, {path:projectConfigurationFile.file.fileBridge.nativePath});

			clearTimeout(timeoutProjectConfigValue);
		}
		
		private function onFDProjectLoaded(value:Object, message:String=null):void
		{
			var rawData:String = String(value);
			var jsonObj:Object = JSON.parse(rawData);
			
			ConstantsCoreVO.AS3PROJ_CONFIG_SOURCE = XML(jsonObj.text);
			FlashDevelopImporter.parse(null);
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