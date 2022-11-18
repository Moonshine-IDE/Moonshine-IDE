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
package actionScripts.plugin.ondiskproj
{
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
	import actionScripts.plugin.ondiskproj.vo.OnDiskProjectVO;
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
	import actionScripts.utils.DominoUtils;
	
	public class CreateOnDiskProject extends ConsoleOutputter
	{
		public function CreateOnDiskProject(event:NewProjectEvent)
		{
			createGrailsProject(event);
		}
		
		private var project:OnDiskProjectVO;
		private var newProjectNameSetting:StringSetting;
		private var newProjectPathSetting:PathSetting;
		private var isInvalidToSave:Boolean;
		private var cookie:SharedObject;
		private var templateLookup:Object = {};
		
		private var model:IDEModel = IDEModel.getInstance();
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		
		private var _currentCauseToBeInvalid:String;
		
		private function createGrailsProject(event:NewProjectEvent):void
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
			
			// Remove spaces from project name
			var projectName:String = (event.templateDir.fileBridge.name.indexOf("(") != -1) ? event.templateDir.fileBridge.name.substr(0, event.templateDir.fileBridge.name.indexOf("(")) : event.templateDir.fileBridge.name;
			projectName = "New" + projectName.replace(/ /g, "");
			
			project = new OnDiskProjectVO(event.templateDir, projectName);
			//project.isDominoVisualEditorProject=true;
			var tmpProjectSourcePath:String = (lastSelectedProjectPath && model.recentSaveProjectPath.getItemIndex(lastSelectedProjectPath) != -1) ?
				lastSelectedProjectPath : model.recentSaveProjectPath.source[model.recentSaveProjectPath.length - 1];
			project.folderLocation = new FileLocation(tmpProjectSourcePath);
			
			var settingsView:SettingsView = new SettingsView();
			settingsView.exportProject = event.exportProject;
			settingsView.Width = 150;
			settingsView.defaultSaveLabel = event.isExport ? "Export" : "Create";
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
		
		private function getProjectSettings(project:OnDiskProjectVO, eventObject:NewProjectEvent):SettingsWrapper
		{
			var historyPaths:ArrayCollection = ObjectUtil.copy(model.recentSaveProjectPath) as ArrayCollection;
			if (historyPaths.length == 0)
			{
				historyPaths.addItem(project.folderPath);
			}
			
			newProjectNameSetting = new StringSetting(project, 'projectName', 'Project name', '^ ~`!@#$%\\^&*()\\-+=[{]}\\\\|:;\'",<.>/?');
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
			var tmpFile:FileLocation = OnDiskImporter.test(value);
			if (!tmpFile && value.fileBridge.exists)
			{
				tmpFile = value;
			}
			
			if (tmpFile) 
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
				isInvalidToSave = tmpFile ? true : false;
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
			var project:OnDiskProjectVO = view.associatedData as OnDiskProjectVO;
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
			
			project = createFileSystemBeforeSave(project, view.exportProject as OnDiskProjectVO);
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
		
		private function createFileSystemBeforeSave(pvo:OnDiskProjectVO, exportProject:OnDiskProjectVO = null):OnDiskProjectVO
		{	
			var templateDir:FileLocation = templateLookup[pvo];
			//Alert.show("templateDir:"+templateDir.fileBridge.nativePath);
			var projectName:String = pvo.projectName;
			var sourceFileWithExtension:String = pvo.projectName + ".dve";
			var sourcePath:String = "src" + model.fileCore.separator + "main";
			var sourceDominoVisualFormPath:String="nsfs"+ model.fileCore.separator + "nsf-moonshine"+ model.fileCore.separator +"odp"+model.fileCore.separator +"Forms"+model.fileCore.separator +pvo.projectName + ".form";
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
			targetFolder.fileBridge.createDirectory();
			
			// Time to do the templating thing!
			var th:TemplatingHelper = new TemplatingHelper();
			th.isProjectFromExistingSource = false;
			th.templatingData["$ProjectName"] = projectName;
			
			var pattern:RegExp = new RegExp(/(_)/g);
			th.templatingData["$ProjectID"] = projectName.replace(pattern, "");
			th.templatingData["$Settings"] = projectName;
			th.templatingData["$SourcePath"] = sourcePath;
			th.templatingData["$SourceFile"] = sourceFileWithExtension ? (sourcePath + model.fileCore.separator +"visualeditor"+ model.fileCore.separator + sourceFileWithExtension) : "";
			
			var tmpDate:Date = new Date();	
			
			th.templatingData["$createdOn"] = tmpDate.toString();
			th.templatingData["$revisedOn"] = tmpDate.toString();
			th.templatingData["$lastAccessedOn"] = tmpDate.toString();
			th.templatingData["$addedOn"] = tmpDate.toString();
			
			th.projectTemplate(templateDir, targetFolder);
			//this line will remove old .dve file and generate new dxl file template follow domino visual format.
			fixVisualDveFileToDominoVisualTemplate(targetFolder.resolvePath(th.templatingData["$SourceFile"]),pvo.projectName,sourceDominoVisualFormPath,targetFolder)
			
			var projectSettingsFileName:String = projectName + ".ondiskproj";
			var settingsFile:FileLocation = targetFolder.resolvePath(projectSettingsFileName);
			pvo = OnDiskImporter.parse(targetFolder, projectName, settingsFile);
			
			if (OnDiskMavenSettingsExporter.mavenSettingsPath && OnDiskMavenSettingsExporter.mavenSettingsPath.fileBridge.exists)
			{
				pvo.mavenBuildOptions.settingsFilePath = OnDiskMavenSettingsExporter.mavenSettingsPath.fileBridge.nativePath; 
			}

			OnDiskExporter.export(pvo);

			//pvo.isDominoVisualEditorProject=true;
			//Alert.show(":"+pvo.isDominoVisualEditorProject)
			
			return pvo;
		}


		private function fixVisualDveFileToDominoVisualTemplate(dveFile:FileLocation,title:String,sourceDominoVisualFormPath:String,targetFolder:FileLocation):void{
			//var dveFile:FileLocation = TemplatingHelper.getCustomFileFor(filePath);
			var dveFilePath:String=dveFile.fileBridge.nativePath;
			//Alert.show("dveFilePath:"+dveFilePath);
			if (dveFile.fileBridge.exists)
			{
				dveFile.fileBridge.deleteFile();
			}

			var xml:XML=DominoUtils.getDominoParentContent(title,title);
			dveFile.fileBridge.writeToFile(xml.toXMLString());

			if(dveFile.fileBridge.exists){
				var newFormFile:FileLocation =  targetFolder.resolvePath(sourceDominoVisualFormPath); 
				dveFile.fileBridge.copyTo(newFormFile, true); 
			}
		}
	}
}