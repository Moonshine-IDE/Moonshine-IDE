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
package actionScripts.plugins.ondiskproj.exporter
{
	import flash.events.Event;
	import flash.filesystem.File;
	
	import actionScripts.events.NewProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugins.as3project.CreateProject;
	import actionScripts.plugins.as3project.importer.FlashDevelopImporter;
	
	import view.dominoFormBuilder.vo.DominoFormVO;

	public class OnDiskRoyaleCRUDExporter extends CreateProject
	{
		private static const TEMPLATE_PROJECT_PATH:FileLocation = IDEModel.getInstance().fileCore.resolveApplicationDirectoryPath("elements/templates/royaleTabularCRUD/project");
		
		private var formObject:DominoFormVO;
		private var model:IDEModel = IDEModel.getInstance();
		private var targetDirectory:File;
		
		public function OnDiskRoyaleCRUDExporter(event:NewProjectEvent)
		{
			super(event);
		}
		
		public function browseToExport(formObject:DominoFormVO):void
		{
			this.formObject = formObject;
			model.fileCore.browseForDirectory("Select Directory to Export", onDirectorySelected, onDirectorySelectionCancelled);
		}
		
		protected function onDirectorySelected(path:File):void
		{
			targetDirectory = path;
			onCreateProjectSave(null);
		}
		
		protected function onDirectorySelectionCancelled():void
		{
			formObject = null;
		}
		
		override protected function getProjectWithTemplate(pvo:Object, exportProject:AS3ProjectVO=null):Object
		{
			var templateSettingsName:String = "$Settings.as3proj.template";
			var tmpLocation:FileLocation = pvo.folderLocation;
			var tmpName:String = pvo.projectName;
			
			templateLookup[pvo] = TEMPLATE_PROJECT_PATH;
			pvo = FlashDevelopImporter.parse(TEMPLATE_PROJECT_PATH.resolvePath(templateSettingsName), null, null, false, projectTemplateType);
			pvo.folderLocation = tmpLocation;
			pvo.projectName = tmpName;
			
			return pvo;
		}
		
		override protected function setProjectType(templateName:String):void
		{
			isFlexJSRoyalProject = true;
		}
		
		override protected function onCreateProjectSave(event:Event):void
		{
			project = FlashDevelopImporter.parse(TEMPLATE_PROJECT_PATH.resolvePath("$Settings.as3proj.template"), null, null, false);
			(project as AS3ProjectVO).projectName = formObject.formName +"_RoyaleApplication";
			(project as AS3ProjectVO).folderLocation = new FileLocation(targetDirectory.nativePath);
			
			project = createFileSystemBeforeSave(project);
		}
	}
}