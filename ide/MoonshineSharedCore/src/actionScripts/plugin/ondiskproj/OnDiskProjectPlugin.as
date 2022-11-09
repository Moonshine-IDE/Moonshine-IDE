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
	
	public class OnDiskProjectPlugin extends PluginBase
	{
		public static const EVENT_NEW_FILE_WINDOW:String = "onOnDiskNewFileWindowRequest";
		
		public var activeType:uint = ProjectType.ONDISK;
		
		override public function get name():String 			{ return "On Disk Project Plugin"; }
		override public function get author():String 		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team"; }
		override public function get description():String 	{ return "On Disk Project importing, exporting & scaffolding."; }
		
		protected var newOnDiskFilePopup:NewOnDiskFilePopup;
		
		override public function activate():void
		{
			dispatcher.addEventListener(NewProjectEvent.CREATE_NEW_PROJECT, createNewProjectHandler, false, 0, true);
			dispatcher.addEventListener(EVENT_NEW_FILE_WINDOW, openOnDiskNewFileWindow, false, 0, true);
			dispatcher.addEventListener(OnDiskBuildEvent.GENERATE_CRUD_ROYALE, onRoyaleCRUDProjectRequest, false, 0, true);
			dispatcher.addEventListener(OnDiskBuildEvent.GENERATE_JAVA_AGENTS, onGenerateCRUDJavaAgentsRequest, false, 0, true);
			
			super.activate();
		}
		
		override public function deactivate():void
		{
			dispatcher.removeEventListener(NewProjectEvent.CREATE_NEW_PROJECT, createNewProjectHandler);
			dispatcher.removeEventListener(EVENT_NEW_FILE_WINDOW, openOnDiskNewFileWindow);
			dispatcher.removeEventListener(OnDiskBuildEvent.GENERATE_CRUD_ROYALE, onRoyaleCRUDProjectRequest);
			dispatcher.removeEventListener(OnDiskBuildEvent.GENERATE_JAVA_AGENTS, onGenerateCRUDJavaAgentsRequest);
			
			super.deactivate();
		}
		
		private function createNewProjectHandler(event:NewProjectEvent):void
		{
			if(!canCreateProject(event))
			{
				return;
			}
			
			model.ondiskCore.createProject(event);
		}

        private function canCreateProject(event:NewProjectEvent):Boolean
        {
            var projectTemplateName:String = event.templateDir.fileBridge.name;
            return projectTemplateName.indexOf(ProjectTemplateType.ONDISK) != -1;
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

		protected function onGenerateCRUDJavaAgentsRequest(event:Event):void
		{
			model.flexCore.generateCRUDJavaAgents();
		}
	}
}