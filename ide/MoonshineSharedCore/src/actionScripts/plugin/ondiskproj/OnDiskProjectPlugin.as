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
package actionScripts.plugin.ondiskproj
{
    import flash.display.DisplayObject;
    import flash.events.Event;
    
    import mx.core.FlexGlobals;
    import mx.events.CloseEvent;
    import mx.managers.PopUpManager;
    
    import actionScripts.events.GeneralEvent;
    import actionScripts.events.NewFileEvent;
    import actionScripts.events.NewProjectEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.project.ProjectTemplateType;
    import actionScripts.plugin.project.ProjectType;
    import actionScripts.plugin.templating.TemplatingPlugin;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.FileWrapper;
    
    import components.popup.newFile.NewOnDiskFilePopup;
	
	public class OnDiskProjectPlugin extends PluginBase
	{
		public static const EVENT_NEW_FILE_WINDOW:String = "onNewFileWindowRequest";
		
		public var activeType:uint = ProjectType.ONDISK;
		
		override public function get name():String 			{ return "On Disk Project Plugin"; }
		override public function get author():String 		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team"; }
		override public function get description():String 	{ return "On Disk Project importing, exporting & scaffolding."; }
		
		protected var newOnDiskFilePopup:NewOnDiskFilePopup;
		
		override public function activate():void
		{
			dispatcher.addEventListener(NewProjectEvent.CREATE_NEW_PROJECT, createNewProjectHandler);
			dispatcher.addEventListener(EVENT_NEW_FILE_WINDOW, openOnDiskNewFileWindow);
			
			super.activate();
		}
		
		override public function deactivate():void
		{
			dispatcher.removeEventListener(NewProjectEvent.CREATE_NEW_PROJECT, createNewProjectHandler);
			
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
		
		protected function openOnDiskNewFileWindow(event:GeneralEvent):void
		{
			newOnDiskFilePopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, NewOnDiskFilePopup, true) as NewOnDiskFilePopup;
			newOnDiskFilePopup.fromTemplate = event.value as FileLocation;
			newOnDiskFilePopup.addEventListener(CloseEvent.CLOSE, handleNewFilePopupClose);
			newOnDiskFilePopup.addEventListener(NewFileEvent.EVENT_NEW_FILE, onNewFileCreateRequest);
			
			// newFileEvent sends by TreeView when right-clicked
			// context menu
			if (event is NewFileEvent)
			{
				newOnDiskFilePopup.folderLocation = new FileLocation((event as NewFileEvent).filePath);
				newOnDiskFilePopup.wrapperOfFolderLocation = (event as NewFileEvent).insideLocation;
				newOnDiskFilePopup.wrapperBelongToProject = UtilsCore.getProjectFromProjectFolder((event as NewFileEvent).insideLocation);
			}
			else
			{
				// try to check if there is any selection in
				// TreeView item
				var treeSelectedItem:FileWrapper = model.mainView.getTreeViewPanel().tree.selectedItem as FileWrapper;
				if (treeSelectedItem)
				{
					var creatingItemIn:FileWrapper = (treeSelectedItem.file.fileBridge.isDirectory) ? treeSelectedItem : FileWrapper(model.mainView.getTreeViewPanel().tree.getParentItem(treeSelectedItem));
					newOnDiskFilePopup.folderLocation = creatingItemIn.file;
					newOnDiskFilePopup.wrapperOfFolderLocation = creatingItemIn;
					newOnDiskFilePopup.wrapperBelongToProject = UtilsCore.getProjectFromProjectFolder(creatingItemIn);
				}
			}
			
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
			
			// TO-DO
			// 1. Generate intermediate dfb/dve
			
			// 2. Generate final files under 'odp'
		}
	}
}