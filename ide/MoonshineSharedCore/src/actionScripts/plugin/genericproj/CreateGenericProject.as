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
package actionScripts.plugin.genericproj
{
	import actionScripts.plugin.genericproj.exporter.GenericProjectExporter;
	import actionScripts.plugin.genericproj.importer.GenericProjectImporter;
	import actionScripts.plugin.genericproj.vo.GenericProjectVO;
	import actionScripts.plugin.ondiskproj.*;
	import actionScripts.ui.menu.vo.ProjectMenuTypes;
	import actionScripts.valueObjects.ProjectVO;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.net.SharedObject;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	
	import actionScripts.events.AddTabEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.NewProjectEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.RefreshTreeEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.plugin.ondiskproj.exporter.OnDiskExporter;
	import actionScripts.plugin.ondiskproj.exporter.OnDiskMavenSettingsExporter;
	import actionScripts.plugin.ondiskproj.importer.OnDiskImporter;
	import actionScripts.plugin.settings.SettingsView;
	import actionScripts.plugin.settings.vo.AbstractSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	import actionScripts.plugin.settings.vo.StaticLabelSetting;
	import actionScripts.plugin.settings.vo.StringSetting;
	import actionScripts.plugin.templating.TemplatingHelper;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.utils.SharedObjectConst;
	//import utils.MainApplicationCodeUtils;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import actionScripts.utils.DominoUtils;
	
	public class CreateGenericProject extends ConsoleOutputter
	{
		public function CreateGenericProject(event:NewProjectEvent, importProjectLocation:FileLocation=null)
		{
			createGenericProject(event, importProjectLocation);
		}
		
		private var project:GenericProjectVO;
		private var newProjectNameSetting:StringSetting;
		private var newProjectPathSetting:PathSetting;
		private var isInvalidToSave:Boolean;
		private var cookie:SharedObject;
		private var templateLookup:Object = {};
		private var isImportProjectCall:Boolean;
		
		private var model:IDEModel = IDEModel.getInstance();
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		
		private var _currentCauseToBeInvalid:String;
		
		private function createGenericProject(event:NewProjectEvent, importProjectLocation:FileLocation=null):void
		{
			var lastSelectedProjectPath:String;
			
			CONFIG::OSX
				{
					if (model.osxBookmarkerCore.availableBookmarkedPaths == "") model.osxBookmarkerCore.removeFlashCookies();
				}
				
				cookie = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);
			if (cookie.data.hasOwnProperty('recentProjectPath'))
			{
				model.recentSaveProjectPath.source = cookie.data.recentProjectPath;
				if (cookie.data.hasOwnProperty('lastSelectedProjectPath')) lastSelectedProjectPath = cookie.data.lastSelectedProjectPath;
			}
			else
			{
				lastSelectedProjectPath = model.fileCore.documentsDirectory.nativePath;
				if (!model.recentSaveProjectPath.contains(lastSelectedProjectPath)) 
				{
					model.recentSaveProjectPath.addItem(lastSelectedProjectPath);
				}
			}

			// in case of new project
			if (event.type != NewProjectEvent.IMPORT_AS_NEW_PROJECT)
			{
				// Remove spaces from project name
				var projectName:String = (event.templateDir.fileBridge.name.indexOf("(") != -1) ? event.templateDir.fileBridge.name.substr(0, event.templateDir.fileBridge.name.indexOf("(")) : event.templateDir.fileBridge.name;
				projectName = "New" + projectName.replace(/ /g, "");

				project = new GenericProjectVO(event.templateDir, projectName);

				//project.isDominoVisualEditorProject=true;
				var tmpProjectSourcePath:String = (lastSelectedProjectPath && model.recentSaveProjectPath.getItemIndex(lastSelectedProjectPath) != -1) ?
					lastSelectedProjectPath : model.recentSaveProjectPath.source[model.recentSaveProjectPath.length - 1];
				project.folderLocation = new FileLocation(tmpProjectSourcePath);

				var settingsView:SettingsView = new SettingsView();
				settingsView.exportProject = event.exportProject;
				settingsView.Width = 150;
				settingsView.defaultSaveLabel = "Create";
				settingsView.isNewProjectSettings = true;

				settingsView.addCategory("");

				var settings:SettingsWrapper = getProjectSettings(project, event);

				settingsView.addEventListener(SettingsView.EVENT_SAVE, createSave);
				settingsView.addEventListener(SettingsView.EVENT_CLOSE, createClose);
				settingsView.addSetting(settings, "");

				settingsView.label = "New Project";
				settingsView.associatedData = project;

				dispatcher.dispatchEvent(new AddTabEvent(settingsView));
				templateLookup[project] = event.templateDir;
			}
			else
			{
				isImportProjectCall = true;
				project = new GenericProjectVO(importProjectLocation.fileBridge.parent, importProjectLocation.fileBridge.name);
				templateLookup[project] = event.templateDir;

				project = createFileSystemBeforeSave(project);

				// Open main file for editing
				dispatcher.dispatchEvent(
						new ProjectEvent(ProjectEvent.ADD_PROJECT, project)
				);

				dispatcher.dispatchEvent(new RefreshTreeEvent(project.folderLocation));
			}
		}
		
		private function getProjectSettings(project:GenericProjectVO, eventObject:NewProjectEvent):SettingsWrapper
		{
			var historyPaths:ArrayCollection = ObjectUtil.copy(model.recentSaveProjectPath) as ArrayCollection;
			if (historyPaths.length == 0)
			{
				historyPaths.addItem(project.folderPath);
			}
			
			newProjectNameSetting = new StringSetting(project, 'projectName', 'Project name', '^ ~`!@#$%\\^&*()\\+=[{]}\\\\|:;\'",<.>/?');
			newProjectPathSetting = new PathSetting(project, 'folderPath', 'Parent directory', true, null, false, true);
			newProjectPathSetting.dropdownListItems = historyPaths;
			newProjectPathSetting.addEventListener(AbstractSetting.PATH_SELECTED, onProjectPathChanged);
			newProjectNameSetting.addEventListener(StringSetting.VALUE_UPDATED, onProjectNameChanged);
			
			return new SettingsWrapper("Name & Location", Vector.<ISetting>([
				new StaticLabelSetting('New '+ eventObject.templateDir.fileBridge.name),
				newProjectNameSetting, // No space input either plx
				newProjectPathSetting,
			]));
		}
		
		private function checkIfProjectDirectory(value:FileLocation):void
		{
			var tmpFile:FileLocation = GenericProjectImporter.test(value.fileBridge.getFile);
			if (value.fileBridge.exists && tmpFile)
			{
				newProjectPathSetting.setMessage((_currentCauseToBeInvalid = "Project can not be created to an existing project directory:\n"+ value.fileBridge.nativePath), AbstractSetting.MESSAGE_CRITICAL);
			}
			else
			{
				newProjectPathSetting.setMessage(value.fileBridge.nativePath);
			}
			
			if (newProjectPathSetting.stringValue == "") 
			{
				isInvalidToSave = true;
				_currentCauseToBeInvalid = 'Unable to access Project Directory:\n'+ value.fileBridge.nativePath +'\nPlease try to create the project again and use the "Change" link to open the target directory again.';
			}
			else
			{
				isInvalidToSave = (value.fileBridge.exists && tmpFile);
			}
		}
		
		private function onProjectPathChanged(event:Event, makeNull:Boolean=true):void
		{
			if (makeNull) project.projectFolder = null;
			project.folderLocation = new FileLocation(newProjectPathSetting.stringValue);
			newProjectPathSetting.label = "Parent Directory";
			checkIfProjectDirectory(project.folderLocation.resolvePath(newProjectNameSetting.stringValue));
		}
		
		private function onProjectNameChanged(event:Event):void
		{
			checkIfProjectDirectory(project.folderLocation.resolvePath(newProjectNameSetting.stringValue));
		}
		
		private function createClose(event:Event):void
		{
			var view:SettingsView = event.target as SettingsView;
			
			view.removeEventListener(SettingsView.EVENT_CLOSE, createClose);
			view.removeEventListener(SettingsView.EVENT_SAVE, createSave);
			if (newProjectPathSetting) 
			{
				newProjectPathSetting.removeEventListener(AbstractSetting.PATH_SELECTED, onProjectPathChanged);
				newProjectNameSetting.removeEventListener(StringSetting.VALUE_UPDATED, onProjectNameChanged);
			}
			
			delete templateLookup[view.associatedData];
			
			dispatcher.dispatchEvent(
				new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, view as DisplayObject)
			);
		}
		
		private function createSave(event:Event):void
		{
			if (isInvalidToSave) 
			{
				throwError();
				return;
			}
			
			var view:SettingsView = event.target as SettingsView;
			var project:GenericProjectVO = view.associatedData as GenericProjectVO;
			//project.isDominoVisualEditorProject=true;
			//save project path in shared object
			cookie = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);
			var tmpParent:FileLocation = project.folderLocation;
			
			if (!model.recentSaveProjectPath.contains(tmpParent.fileBridge.nativePath))
			{
				model.recentSaveProjectPath.addItem(tmpParent.fileBridge.nativePath);
			}
			
			cookie.data["lastSelectedProjectPath"] = project.folderLocation.fileBridge.nativePath;
			cookie.data["recentProjectPath"] = model.recentSaveProjectPath.source;
			cookie.flush();
			
			project = createFileSystemBeforeSave(project);
			if (!project)
			{
				return;
			}
			
			this.project = project;
			
			// Open main file for editing
			dispatcher.dispatchEvent(
				new ProjectEvent(ProjectEvent.ADD_PROJECT, project)
			);
			
			dispatcher.dispatchEvent(new RefreshTreeEvent(project.folderLocation));
			
		}
		
		private function throwError():void
		{
			Alert.show(_currentCauseToBeInvalid +" Project creation terminated.", "Error!");
		}
		
		private function createFileSystemBeforeSave(pvo:GenericProjectVO):GenericProjectVO
		{	
			var templateDir:FileLocation = templateLookup[pvo];
			var projectName:String = pvo.projectName;
			var targetFolder:FileLocation = pvo.folderLocation;
			
			// Create project root directory
			CONFIG::OSX
				{
					if (!model.osxBookmarkerCore.isPathBookmarked(targetFolder.fileBridge.nativePath))
					{
						_currentCauseToBeInvalid = 'Unable to access Parent Directory:\n'+ targetFolder.fileBridge.nativePath +'\nPlease try to create the project again and use the "Change" link to open the target directory again.';
						throwError();
						return null;
					}
				}
				
			targetFolder = targetFolder.resolvePath(projectName);
			if (!targetFolder.fileBridge.exists)
				targetFolder.fileBridge.createDirectory();

			var th:TemplatingHelper = new TemplatingHelper();
			th.isProjectFromExistingSource = false;
			th.templatingData["$ProjectName"] = projectName;

			var pattern:RegExp = new RegExp(/(_)/g);
			th.templatingData["$ProjectID"] = projectName.replace(pattern, "");
			th.templatingData["$Settings"] = projectName;
			th.templatingData["$SourcePath"] = project.folderLocation.fileBridge.nativePath;

			var tmpDate:Date = new Date();

			th.templatingData["$createdOn"] = tmpDate.toString();
			th.templatingData["$revisedOn"] = tmpDate.toString();
			th.templatingData["$lastAccessedOn"] = tmpDate.toString();
			th.templatingData["$addedOn"] = tmpDate.toString();

			th.projectTemplate(templateDir, targetFolder);

			var projectSettingsFileName:String = projectName + ".genericproj";
			var settingsFile:FileLocation = targetFolder.resolvePath(projectSettingsFileName);
			pvo = GenericProjectImporter.parse(targetFolder, projectName, settingsFile);

			/*if (OnDiskMavenSettingsExporter.mavenSettingsPath && OnDiskMavenSettingsExporter.mavenSettingsPath.fileBridge.exists)
			{
				pvo.mavenBuildOptions.settingsFilePath = OnDiskMavenSettingsExporter.mavenSettingsPath.fileBridge.nativePath;
			}*/

			GenericProjectExporter.export(pvo);

			return pvo;
		}
	}
}