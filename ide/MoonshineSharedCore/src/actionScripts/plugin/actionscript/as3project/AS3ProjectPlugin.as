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
package actionScripts.plugin.actionscript.as3project
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import actionScripts.events.MenuEvent;
	import actionScripts.events.NewProjectEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.templating.TemplatingHelper;
	import actionScripts.plugin.templating.event.TemplateEvent;
	import actionScripts.utils.FileCoreUtil;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;
	
	import components.popup.OpenFlexProject;
	
	public class AS3ProjectPlugin extends PluginBase 
	{
		public static const EVENT_IMPORT_FLASHBUILDER_PROJECT:String = "importFBProjectEvent";
		public static const EVENT_IMPORT_FLASHDEVELOP_PROJECT:String = "importFDProjectEvent";
		public static const AS3PROJ_AS_AIR:uint = 1;
		public static const AS3PROJ_AS_WEB:uint = 2;
		
		public var activeType:uint = AS3PROJ_AS_AIR;
		
		// projectvo:templatedir
		private var importProjectPopup:OpenFlexProject;
		private var flashBuilderProjectFile:FileLocation;
		private var flashDevelopProjectFile:FileLocation;
		private var nonProjectFolderLocation:FileLocation;
		
		override public function get name():String 			{return "AS3 Project Plugin";}
		override public function get author():String 		{return "Moonshine Project Team";}
		override public function get description():String 	{return "AS3 project importing, exporting & scaffolding.";}
		
		
		public function AS3ProjectPlugin()
		{
			super();
		}
		
		override public function activate():void
		{
			dispatcher.addEventListener(NewProjectEvent.CREATE_NEW_PROJECT, createAS3Project);
			dispatcher.addEventListener(ProjectEvent.EVENT_IMPORT_FLASHBUILDER_PROJECT, importProject);
			dispatcher.addEventListener(TemplateEvent.REQUEST_ADDITIONAL_DATA, handleTemplatingDataRequest);
			
			super.activate();
		}
		
		override public function deactivate():void
		{
			dispatcher.removeEventListener(NewProjectEvent.CREATE_NEW_PROJECT, createAS3Project);
			dispatcher.removeEventListener(ProjectEvent.EVENT_IMPORT_FLASHBUILDER_PROJECT, importProject);
			dispatcher.removeEventListener(TemplateEvent.REQUEST_ADDITIONAL_DATA, handleTemplatingDataRequest);
			
			super.deactivate();
		}
		
		// If user opens project file, open project automagically
		private function importFDProject(projectFile:FileLocation=null, openWithChoice:Boolean=false):void
		{
			// Is file in an already opened project?
			for each (var p:ProjectVO in model.projects)
			{
				if ( projectFile.fileBridge.nativePath.indexOf(p.folderLocation.fileBridge.nativePath) == 0 )
				{
					warning("Project already opened. Ignoring.");
					return;
				}
			}
			
			// Assume user wants to open project by clicking settings file
			openProject(projectFile, openWithChoice);
		}
		
		private function openProject(projectFile:FileLocation, openWithChoice:Boolean=false):void
		{
			var p:AS3ProjectVO = model.flexCore.parseFlashDevelop(null, projectFile);
			p.projectFile = projectFile;
			model.activeProject = p;
			
			dispatcher.dispatchEvent(
				new ProjectEvent(ProjectEvent.ADD_PROJECT, p, (openWithChoice) ? ProjectEvent.LAST_OPENED_AS_FD_PROJECT : null)
			);
		}
		
		private function importProject(event:Event):void
		{
			// for AIR
			if (ConstantsCoreVO.IS_AIR)
			{
				flashBuilderProjectFile = new FileLocation();
				flashBuilderProjectFile.fileBridge.browseForDirectory("Flex Project Directory", openFile, onFileSelectionCancelled);
			}
			// for WEB
			else
			{
				importProjectPopup = new OpenFlexProject();
				importProjectPopup.jumptToLoadProject = MenuEvent(event).data;
				PopUpManager.addPopUp(importProjectPopup, FlexGlobals.topLevelApplication as DisplayObject, false);
				PopUpManager.centerPopUp(importProjectPopup);
			}
		}
		
		private function onFileSelectionCancelled():void
		{
			/*event.target.removeEventListener(Event.SELECT, openFile);
			event.target.removeEventListener(Event.CANCEL, onFileSelectionCancelled);*/
		}
		
		private function openFile(dir:Object):void
		{
			//onFileSelectionCancelled(event);
			// probable termination due to error at objC side
			if (!dir) return;
			
			var isFBProject: Boolean;
			var isFDProject: Boolean;
			flashDevelopProjectFile = model.flexCore.testFlashDevelop(dir);
			flashBuilderProjectFile = model.flexCore.testFlashBuilder(dir);
			if (flashBuilderProjectFile) isFBProject = true;
			if (flashDevelopProjectFile) isFDProject = true;
			
			if (!isFBProject && !isFDProject)
			{
				nonProjectFolderLocation = new FileLocation(dir.nativePath);
				Alert.show("This directory is missing the Moonshine project configuration files. Do you want to generate a new project by locating existing source?", "Error!", Alert.YES|Alert.NO, null, onExistingSourceProjectConfirm);
			}
			else if (isFBProject && isFDProject)
			{
				// @santanu
				// check change log in AS3ProjectVO.as against
				// commenting the following process
				
				/*Alert.okLabel = "Flash Builder Project";
				Alert.yesLabel = "FlashDevelop Project";
				Alert.buttonWidth = 150;
				
				Alert.show("Project directory contains different types of Flex projects. Please, choose an option how you want it to be open.", "Project Type Choice", Alert.OK|Alert.YES|Alert.CANCEL, null, projectChoiceHandler);
				Alert.okLabel = "OK";
				Alert.yesLabel = "YES";
				Alert.buttonWidth = 65;*/
				
				importFDProject(flashDevelopProjectFile);
			}
			else if (isFBProject) importFBProject();
			else if (isFDProject) importFDProject(flashDevelopProjectFile);
		}
		
		private function onExistingSourceProjectConfirm(event:CloseEvent):void
		{
			if (event.detail == Alert.YES)
			{
				createAS3Project(new NewProjectEvent("", "as3proj", null, nonProjectFolderLocation));
			}
			
			nonProjectFolderLocation = null;
		}
		
		private function projectChoiceHandler(event:CloseEvent):void
		{
			setTimeout(function():void
			{
				if (event.detail == Alert.OK) importFBProject(true);
				else if (event.detail == Alert.YES) importFDProject(flashDevelopProjectFile, true);
			}, 300);
		}
		
		private function importFBProject(openWithChoice:Boolean=false):void
		{
			var p:AS3ProjectVO = model.flexCore.parseFlashBuilder(flashBuilderProjectFile);
			dispatcher.dispatchEvent(
				new ProjectEvent(ProjectEvent.ADD_PROJECT, p, (openWithChoice) ? ProjectEvent.LAST_OPENED_AS_FB_PROJECT : null)
			);
		}
		
		private function handleTemplatingDataRequest(event:TemplateEvent):void
		{
			if (TemplatingHelper.getExtension(event.template) == "as")
			{
				if (ConstantsCoreVO.IS_AIR && event.location)
				{
					// Find project it belongs to
					for each (var p:ProjectVO in model.projects)
					{
						if (p is AS3ProjectVO && p.projectFolder.containsFile(event.location))
						{
							// Populate templating data
							event.templatingData = getTemplatingData(event.location, p as AS3ProjectVO);
							return;
						}
					}
				}
				
				// If nothing is found - guess the data
				event.templatingData = {};
				event.templatingData['$projectName'] = "New";
				event.templatingData['$packageName'] = "";
				event.templatingData['$fileName'] = "New";
			}
		}
		
		private function getTemplatingData(file:FileLocation, project:AS3ProjectVO):Object
		{
			var toRet:Object = {};
			toRet['$projectName'] = project.name;
			
			// Figure out package name
			if (ConstantsCoreVO.IS_AIR)
			{
				for each (var dir:FileLocation in project.classpaths)
				{
					if (FileCoreUtil.contains(dir, flashBuilderProjectFile))
					{
						// Convert path to package name in dot-style
						var relativePath:String = dir.fileBridge.getRelativePath(flashBuilderProjectFile);
						var packagePath:String = relativePath.substring(0, relativePath.indexOf(flashBuilderProjectFile.fileBridge.name));
						if (packagePath.charAt(packagePath.length-1) == model.fileCore.separator)
						{
							packagePath = packagePath.substring(0, packagePath.length-1);
						}
						var packageName:String = packagePath.split(model.fileCore.separator).join(".");
						toRet['$packageName'] = packageName; 
						break;
					}
				}
				
				var name:String = flashBuilderProjectFile.fileBridge.name.split(".")[0];
				toRet['$fileName'] = name;
			}
			
			return toRet;
		}
		
		// Create new AS3 Project
		private function createAS3Project(event:NewProjectEvent):void
		{
			model.flexCore.createAS3Project(event);
		}
	}
}
