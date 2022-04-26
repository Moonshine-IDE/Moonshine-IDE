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
	import actionScripts.plugin.genericproj.events.GenericProjectEvent;
	import actionScripts.plugin.genericproj.vo.GenericProjectVO;

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
	
	public class GenericProjectPlugin extends PluginBase
	{
		public var activeType:uint = ProjectType.ONDISK;
		
		override public function get name():String 			{ return "Generic Project Plugin"; }
		override public function get author():String 		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team"; }
		override public function get description():String 	{ return "Generic Project importing, exporting & scaffolding."; }
		
		protected var newOnDiskFilePopup:NewOnDiskFilePopup;
		
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
			new CreateGenericProject(
				new NewProjectEvent(NewProjectEvent.IMPORT_AS_NEW_PROJECT, null, null, event.value as FileLocation)
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