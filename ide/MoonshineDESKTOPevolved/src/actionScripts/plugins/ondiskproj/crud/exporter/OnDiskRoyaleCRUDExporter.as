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
package actionScripts.plugins.ondiskproj.crud.exporter
{
	import flash.events.Event;
	import flash.filesystem.File;
	
	import actionScripts.events.NewProjectEvent;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.plugins.as3project.CreateProject;
	import actionScripts.plugins.as3project.importer.FlashDevelopImporter;
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.AddEditPageGenerator;
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.ListingPageGenerator;
	
	import view.dominoFormBuilder.vo.DominoFormVO;

	public class OnDiskRoyaleCRUDExporter extends CreateProject
	{
		private static const TEMPLATE_PROJECT_PATH:FileLocation = IDEModel.getInstance().fileCore.resolveApplicationDirectoryPath("elements/templates/royaleTabularCRUD/project");
		
		private var formObject:DominoFormVO;
		private var targetDirectory:File;
		
		/**
		 * CONSTRUCTOR
		 */
		public function OnDiskRoyaleCRUDExporter(event:NewProjectEvent)
		{
			super(event);
		}
		
		//--------------------------------------------------------------------------
		//
		//  PUBLIC API
		//
		//--------------------------------------------------------------------------
		
		public function browseToExport(formObject:DominoFormVO):void
		{
			this.formObject = formObject;
			model.fileCore.browseForDirectory("Select Directory to Export", onDirectorySelected, onDirectorySelectionCancelled);
		}
		
		//--------------------------------------------------------------------------
		//
		//  OVERRIDES
		//
		//--------------------------------------------------------------------------
		
		override protected function getProjectWithTemplate(pvo:Object, exportProject:AS3ProjectVO=null):Object
		{
			templateLookup[pvo] = TEMPLATE_PROJECT_PATH;
			return pvo;
		}
		
		override protected function setProjectType(templateName:String):void
		{
			isFlexJSRoyalProject = true;
		}
		
		override protected function onCreateProjectSave(event:Event):void
		{
			var projectName:String = formObject.formName +"_RoyaleApplication";
			
			dispatcher.dispatchEvent(
				new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, "Saving project at: "+ targetDirectory.resolvePath(projectName).nativePath)
			);
			
			project = FlashDevelopImporter.parse(TEMPLATE_PROJECT_PATH.resolvePath("$Settings.as3proj.template"), null, null, false);
			(project as AS3ProjectVO).projectName = projectName;
			(project as AS3ProjectVO).folderLocation = new FileLocation(targetDirectory.nativePath);
			
			project = createFileSystemBeforeSave(project);
			if (project)
			{
				generatePageContents();
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  LISTENERS API
		//
		//--------------------------------------------------------------------------
		
		protected function onDirectorySelected(path:File):void
		{
			targetDirectory = path;
			onCreateProjectSave(null);
		}
		
		protected function onDirectorySelectionCancelled():void
		{
			formObject = null;
		}
		
		//--------------------------------------------------------------------------
		//
		//  PRIVATE API
		//
		//--------------------------------------------------------------------------
		
		private function generatePageContents():void
		{
			// temp
			new ListingPageGenerator((project as AS3ProjectVO).projectFolder.file, formObject);
			// temp
			new AddEditPageGenerator((project as AS3ProjectVO).projectFolder.file, formObject);
			
			// success message
			dispatcher.dispatchEvent(
				new ConsoleOutputEvent(
					ConsoleOutputEvent.CONSOLE_PRINT, 
					"Project saved at: "+ targetDirectory.resolvePath((project as AS3ProjectVO).name).nativePath, 
					false, false, 
					ConsoleOutputEvent.TYPE_SUCCESS
				)
			);
			dispatcher.dispatchEvent(
				new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, "Opening project in Moonshine..")
			);
			
			// open project in Moonshine
			openProjectInMoonshine();
		}
		
		private function openProjectInMoonshine():void
		{
			dispatcher.dispatchEvent(
				new ProjectEvent(ProjectEvent.ADD_PROJECT, project)
			);
			
			dispatcher.dispatchEvent( 
				new OpenFileEvent(OpenFileEvent.OPEN_FILE, [project.targets[0]], -1, [project.projectFolder])
			);
		}
	}
}