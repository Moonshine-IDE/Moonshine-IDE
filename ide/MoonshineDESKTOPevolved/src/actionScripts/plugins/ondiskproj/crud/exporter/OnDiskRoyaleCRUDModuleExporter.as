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
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.templating.TemplatingHelper;
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.ListingPageGenerator;
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.MainContentPageGenerator;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.ResourceVO;
	
	import view.dominoFormBuilder.utils.FormBuilderCodeUtils;
	import view.dominoFormBuilder.vo.DominoFormVO;
	
	public class OnDiskRoyaleCRUDModuleExporter
	{
		private static const TEMPLATE_MODULE_PATH:FileLocation = IDEModel.getInstance().fileCore.resolveApplicationDirectoryPath("elements/templates/royaleTabularCRUD/module");
		
		protected var targetPath:FileLocation;
		protected var project:ProjectVO;
		protected var formObjects:Vector.<DominoFormVO>;
		
		public function OnDiskRoyaleCRUDModuleExporter(targetPath:FileLocation, project:ProjectVO)
		{
			this.targetPath = targetPath;
			this.project = project;
			
			parseModules();
		}
		
		protected function parseModules():void
		{
			var tmpFormObject:DominoFormVO;
			
			// get all available dfb files
			var resources:ArrayCollection = new ArrayCollection();
			UtilsCore.parseFilesList(resources, null, ["dfb"]);
			
			// parse to dfb files to form-object
			// no matter opened or non-opened
			formObjects = new Vector.<DominoFormVO>();
			for each (var resource:ResourceVO in resources)
			{
				tmpFormObject = new DominoFormVO();
				FormBuilderCodeUtils.loadFromFile(resource.sourceWrapper.file.fileBridge.getFile as File, tmpFormObject);
				
				// form with no fields doesn't make sense
				// to being generate in the royale application
				if (tmpFormObject.fields && tmpFormObject.fields.length > 0)
				{
					formObjects.push(tmpFormObject);
				}
			}
			
			// starts generation
			copyModuleTemplates();
		}
		
		protected function copyModuleTemplates():void
		{
			// module specific generation
			for each (var form:DominoFormVO in formObjects)
			{
				copyTemplates(form);
			}
			
			// project specific generation
			generateProjectClasses();
		}
		
		protected function copyTemplates(form:DominoFormVO):void
		{
			var moduleName:String = form.formName;

			var th:TemplatingHelper = new TemplatingHelper();
			th.templatingData["$moduleName"] = moduleName;
			th.templatingData["$packagePath"] = "views.module."+ moduleName +"."+ moduleName +"_services";
			
			th.projectTemplate(TEMPLATE_MODULE_PATH, targetPath);
			generateModuleClasses(form);
		}
		
		protected function generateModuleClasses(form:DominoFormVO):void
		{
			new ListingPageGenerator(project.projectFolder.file, form);
			new AddEditPageGenerator(project).projectFolder.file, form);
		}
		
		protected function generateProjectClasses():void
		{
			//new MainContentPageGenerator(project.projectFolder.file, formObject);
		}
	}
}