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
package actionScripts.plugin.genericproj
{
	import actionScripts.events.GradleBuildEvent;
	import actionScripts.events.MavenBuildEvent;
import actionScripts.interfaces.IActionItemsProvider;
import actionScripts.plugin.core.compiler.JavaBuildEvent;
	import actionScripts.plugin.genericproj.events.GenericProjectEvent;
	import actionScripts.plugin.genericproj.vo.GenericProjectVO;
import actionScripts.ui.actionbar.vo.ActionItemTypes;
import actionScripts.ui.actionbar.vo.ActionItemVO;
import actionScripts.valueObjects.TemplateVO;

	import flash.display.DisplayObject;
    import flash.events.Event;

	import mx.collections.ArrayCollection;

	import mx.core.FlexGlobals;
    import mx.events.CloseEvent;
    import mx.managers.PopUpManager;
    
    import actionScripts.events.NewFileEvent;
    import actionScripts.events.NewProjectEvent;
    import actionScripts.events.OnDiskBuildEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.project.ProjectTemplateType;
    import actionScripts.plugin.project.ProjectType;
    import actionScripts.plugin.templating.TemplatingHelper;
    import actionScripts.plugin.templating.TemplatingPlugin;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.ConstantsCoreVO;
    
    import components.popup.newFile.NewOnDiskFilePopup;
    import actionScripts.plugin.IProjectTypePlugin;
    import actionScripts.plugin.genericproj.importer.GenericProjectImporter;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.ui.menu.vo.MenuItem;
    import mx.resources.ResourceManager;
    import mx.resources.IResourceManager;
    import actionScripts.ui.menu.vo.ProjectMenuTypes;
    import flash.ui.Keyboard;
	
	public class GenericProjectPlugin extends PluginBase implements IProjectTypePlugin, IActionItemsProvider
	{
		public var activeType:uint = ProjectType.ONDISK;
		
		override public function get name():String 			{ return "Generic Project Plugin"; }
		override public function get author():String 		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team"; }
		override public function get description():String 	{ return "Generic Project importing, exporting & scaffolding."; }
		
		protected var newOnDiskFilePopup:NewOnDiskFilePopup;
		private var _projectMenu:Vector.<MenuItem>;
        private var resourceManager:IResourceManager = ResourceManager.getInstance();

		public function get projectClass():Class
		{
			return GenericProjectVO;
		}

		public function getActionItems(project:ProjectVO):Vector.<ActionItemVO>
		{
			var genericProject:GenericProjectVO = GenericProjectVO(project);
			var actionItems:Vector.<ActionItemVO> = new Vector.<ActionItemVO>();
			if (genericProject.hasPom())
			{
				actionItems.push(
					new ActionItemVO(resourceManager.getString('resources', 'BUILD_WITH_APACHE_MAVEN'), ActionItemTypes.BUILD, MavenBuildEvent.START_MAVEN_BUILD)
				);
			}
			if (genericProject.isAntFileAvailable)
			{
				actionItems.push(
					new ActionItemVO(resourceManager.getString('resources', 'BUILD_WITH_APACHE_ANT'), ActionItemTypes.BUILD, "selectedProjectAntBuild")
				);
			}
			if (genericProject.hasGradleBuild())
			{
				actionItems.push(
					new ActionItemVO(resourceManager.getString('resources', 'RUN_GRADLE_TASKS'), ActionItemTypes.RUN, GradleBuildEvent.START_GRADLE_BUILD)
				);
			}

			return actionItems;
		}

		public function getProjectMenuItems(project:ProjectVO):Vector.<MenuItem>
		{
			var genericProject:GenericProjectVO = GenericProjectVO(project);
            // re-generate every time based on
            // project's availabilities
            _projectMenu = new Vector.<MenuItem>();
            if (genericProject.hasPom())
            {
                _projectMenu.push(
                        new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_MAVEN'), null, [ProjectMenuTypes.GENERIC], MavenBuildEvent.START_MAVEN_BUILD)
                );
            }
            if (genericProject.hasGradleBuild())
            {
                _projectMenu.push(
                    new MenuItem(resourceManager.getString('resources', 'RUN_GRADLE_TASKS'), null, [ProjectMenuTypes.GENERIC], GradleBuildEvent.START_GRADLE_BUILD,
                        'b', [Keyboard.COMMAND],
                        'b', [Keyboard.CONTROL])
                );
            }
            if (genericProject.isAntFileAvailable)
            {
                _projectMenu.push(
                    new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_ANT'), null, [ProjectMenuTypes.GENERIC], "selectedProjectAntBuild")
                );
            }

            if (_projectMenu.length > 0)
            {
                _projectMenu.insertAt(0, new MenuItem(null));
            }

            _projectMenu.forEach(function(item:MenuItem, index:int, vector:Vector.<MenuItem>):void
			{
				item.dynamicItem = true;
			});

            return _projectMenu;
		}
		
		override public function activate():void
		{
			dispatcher.addEventListener(NewProjectEvent.CREATE_NEW_PROJECT, createNewProjectHandler, false, 0, true);
			dispatcher.addEventListener(GenericProjectEvent.EVENT_OPEN_PROJECT, onGenericProjectImport, false, 0, true);

			super.activate();
		}
		
		override public function deactivate():void
		{
			dispatcher.removeEventListener(NewProjectEvent.CREATE_NEW_PROJECT, createNewProjectHandler);
			dispatcher.removeEventListener(GenericProjectEvent.EVENT_OPEN_PROJECT, onGenericProjectImport);

			super.deactivate();
		}

		public function testProjectDirectory(dir:FileLocation):FileLocation
		{
			return GenericProjectImporter.test(dir);
		}

		public function parseProject(projectFolder:FileLocation, projectName:String = null, settingsFileLocation:FileLocation = null):ProjectVO
		{
			return GenericProjectImporter.parse(projectFolder, projectName, settingsFileLocation);
		}
		
		private function createNewProjectHandler(event:NewProjectEvent):void
		{
			if(!canCreateProject(event))
			{
				return;
			}
			
			new CreateGenericProject(event);
		}

		private function onGenericProjectImport(event:GenericProjectEvent):void
		{
			var genericTemplateDirectory:FileLocation;
			ConstantsCoreVO.TEMPLATES_PROJECTS.source.some(function(element:TemplateVO, index:int, arr:Array):Boolean
			{
				if (element.title.toLowerCase().indexOf("generic project") != -1)
				{
					genericTemplateDirectory = element.file;
					return true;
				}
				return false;
			});

			new CreateGenericProject(
				new NewProjectEvent(NewProjectEvent.IMPORT_AS_NEW_PROJECT, null, null, genericTemplateDirectory),
				event.value as FileLocation
			);
		}

        private function canCreateProject(event:NewProjectEvent):Boolean
        {
            var projectTemplateName:String = event.templateDir.fileBridge.name;
            return projectTemplateName.indexOf(ProjectTemplateType.GENERIC) != -1;
        }
		
		protected function openOnDiskNewFileWindow(event:NewFileEvent):void
		{
			newOnDiskFilePopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, NewOnDiskFilePopup, true) as NewOnDiskFilePopup;
			newOnDiskFilePopup.fromTemplate = event.fromTemplate;
			newOnDiskFilePopup.folderLocation = new FileLocation((event as NewFileEvent).filePath);
			newOnDiskFilePopup.wrapperOfFolderLocation = (event as NewFileEvent).insideLocation;
			newOnDiskFilePopup.wrapperBelongToProject = UtilsCore.getProjectFromProjectFolder((event as NewFileEvent).insideLocation);
			
			newOnDiskFilePopup.addEventListener(CloseEvent.CLOSE, handleNewFilePopupClose);
			newOnDiskFilePopup.addEventListener(NewFileEvent.EVENT_NEW_FILE, onNewFileCreateRequest);
			
			PopUpManager.centerPopUp(newOnDiskFilePopup);
		}
		
		protected function handleNewFilePopupClose(event:CloseEvent):void
		{
			newOnDiskFilePopup.removeEventListener(CloseEvent.CLOSE, handleNewFilePopupClose);
			newOnDiskFilePopup.removeEventListener(NewFileEvent.EVENT_NEW_FILE, onNewFileCreateRequest);
			newOnDiskFilePopup = null;
		}
		
		protected function onNewFileCreateRequest(event:NewFileEvent):void
		{
			handleNewFilePopupClose(null);
			TemplatingPlugin.checkAndUpdateIfTemplateModified(event);
			
			var fileContent:String = event.fromTemplate.fileBridge.read() as String;
			var th:TemplatingHelper = new TemplatingHelper();
			var sourceFileWithExtension:String = event.fileName +"."+ event.fileExtension;
			var tmpDate:Date = new Date();	
			
			th.templatingData["$createdOn"] = tmpDate.toString();
			th.templatingData["$revisedOn"] = tmpDate.toString();
			th.templatingData["$lastAccessedOn"] = tmpDate.toString();
			th.templatingData["$addedOn"] = tmpDate.toString();
			
			// TO-DO
			// 1. Generate intermediate dfb/dve
			
			// POPULATE XML from 'fileContent' TO MODIFY IN XML
			
			var targetFile:FileLocation = event.insideLocation.file.fileBridge.resolvePath(sourceFileWithExtension)
			th.fileTemplate(event.fromTemplate, targetFile);
			
			// 2. Generate final files under 'odp/Forms'
			
			
			// open to editor and refresh tree
			var tmpNewFileEvent:NewFileEvent = new NewFileEvent(NewFileEvent.EVENT_FILE_CREATED, null, null, event.insideLocation);
			tmpNewFileEvent.isOpenAfterCreate = true;
			tmpNewFileEvent.newFileCreated = targetFile;
			dispatcher.dispatchEvent(tmpNewFileEvent);
		}
		
		protected function onRoyaleCRUDProjectRequest(event:Event):void
		{
			model.flexCore.generateTabularRoyaleProject();
		}
	}
}